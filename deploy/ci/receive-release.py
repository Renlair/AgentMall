#!/usr/bin/python3
"""Root-owned, forced-command receiver for the dedicated CI SSH key."""
import fcntl, hashlib, json, os, re, shutil, signal, subprocess, sys, tarfile, tempfile, time, uuid
from pathlib import Path
from urllib.request import Request, build_opener, ProxyHandler

ROOT=Path('/root/agentmall')
STATE=Path('/var/lib/agentmall-deploy')
MAX_PACKAGE=2*1024**3

class DeploymentError(Exception): pass

def run(args, log, **kwargs):
    result=subprocess.run(args, stdout=log, stderr=log, **kwargs)
    if result.returncode: raise DeploymentError('Deployment command failed; details saved privately on server.')

def inspect_image(name):
    result=subprocess.run(['docker','image','inspect',name],stdout=subprocess.PIPE,stderr=subprocess.DEVNULL,universal_newlines=True)
    if result.returncode: raise DeploymentError('Expected image is missing.')
    data=json.loads(result.stdout)[0]
    if data.get('Os')!='linux' or data.get('Architecture')!='amd64': raise DeploymentError('Expected Linux amd64 images.')

def copy_bounded(source, dest, maximum):
    total=0
    while True:
        chunk=source.read(1024*1024)
        if not chunk: break
        total+=len(chunk)
        if total>maximum: raise DeploymentError('Release package exceeds size limit.')
        dest.write(chunk)
    return total

def unpack_package(package, directory):
    with tarfile.open(str(package),'r:') as archive:
        members=archive.getmembers()
        if sorted(m.name for m in members)!=['images.tar.gz','release.json']: raise DeploymentError('Unexpected release package members.')
        for member in members:
            maximum=16384 if member.name=='release.json' else MAX_PACKAGE
            if not member.isfile() or member.size>maximum: raise DeploymentError('Invalid release package member.')
            with archive.extractfile(member) as src, (directory/member.name).open('wb') as dst:
                copy_bounded(src,dst,maximum)
    metadata=json.loads((directory/'release.json').read_text())
    commit=metadata.get('commit','')
    if not re.fullmatch('[0-9a-f]{40}',commit): raise DeploymentError('Invalid release commit.')
    digest=hashlib.sha256()
    with (directory/'images.tar.gz').open('rb') as src:
        for chunk in iter(lambda:src.read(1024*1024),b''): digest.update(chunk)
    if digest.hexdigest()!=metadata.get('sha256'): raise DeploymentError('Release checksum mismatch.')
    expected={'agentmall-backend:git-'+commit,'agentmall-web:git-'+commit}
    with tarfile.open(str(directory/'images.tar.gz'),'r:gz') as images:
        manifests=[m for m in images.getmembers() if m.name=='manifest.json']
        if len(manifests)!=1 or not manifests[0].isfile() or manifests[0].size>65536: raise DeploymentError('Invalid Docker image manifest.')
        manifest=json.load(images.extractfile(manifests[0]))
        tags=[tag for image in manifest for tag in image.get('RepoTags',[])]
        if len(manifest)!=2 or len(tags)!=2 or set(tags)!=expected: raise DeploymentError('Release must contain exactly the two expected application images.')
    return commit

def compose(override):
    args=['docker','compose','--project-name','agentmall','--project-directory',str(ROOT),'-f',str(ROOT/'compose.yaml')]
    public=ROOT/'compose.override.yaml'
    if public.exists(): args+=['-f',str(public)]
    return args+['-f',str(override)]

def health_check():
    # A nonexistent username exercises the login SQL path without storing admin credentials in CI.
    opener=build_opener(ProxyHandler({}))
    body=json.dumps({'username':'deploy_probe_'+uuid.uuid4().hex,'password':uuid.uuid4().hex}).encode()
    for attempt in range(60):
        try:
            with opener.open('http://127.0.0.1:8080/login',timeout=5) as response:
                html=response.read()
            if b'<html' not in html.lower() or b'/assets/' not in html: raise ValueError()
            request=Request('http://127.0.0.1:8080/api/user/login',data=body,headers={'Content-Type':'application/json'})
            with opener.open(request,timeout=5) as response: payload=json.load(response)
            if payload.get('code')!='5004': raise ValueError()
            return
        except Exception:
            if attempt==59: raise DeploymentError('Application health check failed; rolling back.')
            time.sleep(2)

def deploy(directory,commit):
    release=STATE/'releases'/commit
    release.mkdir(parents=True,exist_ok=True,mode=0o700)
    log_path=release/('deploy-'+str(int(time.time()))+'.log')
    with log_path.open('w') as log:
        run(['docker','load','-i',str(directory/'images.tar.gz')],log,timeout=240)
        for name in ['agentmall-backend','agentmall-web']: inspect_image(name+':git-'+commit)
        previous={}
        for service in ['backend','web']:
            result=subprocess.check_output(['docker','inspect','-f','{{.Config.Image}}','agentmall-'+service+'-1'],universal_newlines=True).strip()
            previous[service]={'image':result}
        db_before=subprocess.check_output(['docker','inspect','-f','{{.Id}}','agentmall-db-1'],universal_newlines=True).strip()
        previous_file=release/'previous.yaml'
        previous_file.write_text(json.dumps({'services':previous}))
        active=ROOT/'compose.ci.yaml'
        old=active.read_bytes() if active.exists() else None
        candidate=directory/'compose.ci.yaml'
        candidate.write_text(json.dumps({'services':{'backend':{'image':'agentmall-backend:git-'+commit},'web':{'image':'agentmall-web:git-'+commit}}}))
        try:
            run(compose(candidate)+['up','-d','--no-deps','--force-recreate','backend','web'],log,timeout=180)
            health_check()
            db_after=subprocess.check_output(['docker','inspect','-f','{{.Id}}','agentmall-db-1'],universal_newlines=True).strip()
            if db_before!=db_after: raise DeploymentError('Database container unexpectedly changed.')
            shutil.copyfile(str(candidate),str(active))
            os.chmod(str(active),0o600)
            (STATE/'current.json').write_text(json.dumps({'commit':commit,'deployed_at':int(time.time()),'rollback':str(previous_file)}))
            print('PASS: frontend, backend login SQL path, and unchanged database container.')
            print('Deployed AgentMall commit '+commit)
        except Exception:
            print('Deployment unsuccessful; restoring previous application images.',flush=True)
            run(compose(previous_file)+['up','-d','--no-deps','--force-recreate','backend','web'],log,timeout=180)
            health_check()
            if old is not None: active.write_bytes(old)
            elif active.exists(): active.unlink()
            raise DeploymentError('Previous application images restored. Inspect private deployment log on server.')

def main():
    if os.geteuid()!=0 or len(sys.argv)!=1: raise DeploymentError('Use the restricted deployment account.')
    os.umask(0o077)
    STATE.mkdir(mode=0o700,exist_ok=True)
    if not (ROOT/'.env').exists() or not (ROOT/'compose.yaml').exists(): raise DeploymentError('Existing AgentMall installation required.')
    with (STATE/'deploy.lock').open('a') as lock:
        try: fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
        except BlockingIOError: raise DeploymentError('Another deployment is running.')
        if shutil.disk_usage(str(STATE)).free<5*1024**3: raise DeploymentError('At least 5 GiB free disk space is required.')
        signal.alarm(1200)
        with tempfile.TemporaryDirectory(prefix='incoming-',dir=str(STATE)) as name:
            directory=Path(name)
            package=directory/'release.tar'
            with package.open('wb') as dest: copy_bounded(sys.stdin.buffer,dest,MAX_PACKAGE)
            commit=unpack_package(package,directory)
            package.unlink()
            deploy(directory,commit)

if __name__=='__main__':
    try: main()
    except Exception as exc:
        print(str(exc) if isinstance(exc,DeploymentError) else 'Deployment failed; inspect server-side logs privately.',file=sys.stderr)
        sys.exit(1)

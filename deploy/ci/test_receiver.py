import contextlib, hashlib, importlib.util, io, json, tarfile, tempfile, unittest
from unittest.mock import patch
from pathlib import Path

spec=importlib.util.spec_from_file_location('receiver',Path(__file__).with_name('receive-release.py'))
receiver=importlib.util.module_from_spec(spec);spec.loader.exec_module(receiver)
SHA='a'*40

def add(archive,name,data,link=False):
    member=tarfile.TarInfo(name)
    if link: member.type=tarfile.SYMTYPE;member.linkname='/etc/passwd'
    else: member.size=len(data)
    archive.addfile(member,None if link else io.BytesIO(data))

def package(root,tags=None,extra=False,bad_digest=False,link=False):
    inner=root/'image-fixture.tar.gz'
    with tarfile.open(inner,'w:gz') as archive:
        manifest=[{'RepoTags':[name],'Config':'config.json','Layers':[]} for name in (tags or ['agentmall-backend:git-'+SHA,'agentmall-web:git-'+SHA])]
        add(archive,'manifest.json',json.dumps(manifest).encode())
    content=inner.read_bytes()
    metadata={'commit':SHA,'sha256':'0'*64 if bad_digest else hashlib.sha256(content).hexdigest()}
    path=root/'package.tar'
    with tarfile.open(path,'w:') as archive:
        add(archive,'release.json',json.dumps(metadata).encode(),link)
        add(archive,'images.tar.gz',content)
        if extra:add(archive,'../../etc/passwd',b'bad')
    return path

class ReceiverTests(unittest.TestCase):
    def check(self,**kwargs):
        with tempfile.TemporaryDirectory() as name:
            root=Path(name);out=root/'out';out.mkdir()
            return receiver.unpack_package(package(root,**kwargs),out)
    def test_exact_release(self):self.assertEqual(self.check(),SHA)
    def test_path_traversal(self):
        with self.assertRaises(receiver.DeploymentError):self.check(extra=True)
    def test_symlink(self):
        with self.assertRaises(receiver.DeploymentError):self.check(link=True)
    def test_checksum(self):
        with self.assertRaises(receiver.DeploymentError):self.check(bad_digest=True)
    def test_unexpected_image(self):
        with self.assertRaises(receiver.DeploymentError):self.check(tags=['mysql:latest','agentmall-web:git-'+SHA])
class DeploymentTests(unittest.TestCase):
    def exercise(self,fail=False):
        with tempfile.TemporaryDirectory() as name:
            root=Path(name);app=root/'app';app.mkdir();state=root/'state';state.mkdir();incoming=root/'incoming';incoming.mkdir()
            active=app/'compose.ci.yaml';active.write_text('old-override')
            calls=[]
            def inspect(args,**kwargs):
                return ('old-backend' if args[-1]=='agentmall-backend-1' else 'old-web' if args[-1]=='agentmall-web-1' else 'database-id')+'\n'
            health=[receiver.DeploymentError('not healthy'),None] if fail else [None]
            with patch.object(receiver,'ROOT',app),patch.object(receiver,'STATE',state),patch.object(receiver,'inspect_image'),patch.object(receiver,'run',side_effect=lambda args,log,**kwargs:calls.append(args)),patch.object(receiver.subprocess,'check_output',side_effect=inspect),patch.object(receiver,'health_check',side_effect=health),contextlib.redirect_stdout(io.StringIO()):
                if fail:
                    with self.assertRaises(receiver.DeploymentError):receiver.deploy(incoming,SHA)
                else:receiver.deploy(incoming,SHA)
            updates=[args for args in calls if 'up' in args]
            self.assertEqual(len(updates),2 if fail else 1)
            for args in updates:
                self.assertEqual(args[-2:],['backend','web'])
                self.assertIn('--no-deps',args)
                self.assertNotIn('down',args)
            previous=json.loads((state/'releases'/SHA/'previous.yaml').read_text())
            self.assertEqual(previous['services']['backend']['image'],'old-backend')
            if fail:
                self.assertEqual(active.read_text(),'old-override')
                self.assertFalse((state/'current.json').exists())
            else:
                self.assertEqual(json.loads(active.read_text())['services']['web']['image'],'agentmall-web:git-'+SHA)
                self.assertEqual(json.loads((state/'current.json').read_text())['commit'],SHA)
    def test_success_preserves_database(self):self.exercise()
    def test_failed_health_rolls_back(self):self.exercise(fail=True)

if __name__=='__main__':unittest.main()

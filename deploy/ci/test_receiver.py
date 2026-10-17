import hashlib, importlib.util, io, json, tarfile, tempfile, unittest
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
if __name__=='__main__':unittest.main()

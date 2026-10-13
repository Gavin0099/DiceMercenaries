"""Compare retained tested bytes and packaged bytes with this checkout."""
from pathlib import Path
import hashlib
import json
import zipfile

root = Path(__file__).resolve().parents[3]
native = json.loads((root / 'artifacts/evidence/tact-01/native-check.json').read_text(encoding='utf-8'))
assert native['ok'], 'Native checks did not pass'
for name, expected in native['source_files_sha256'].items():
    path = root / name.replace('\\', '/')
    assert hashlib.sha256(path.read_bytes()).hexdigest() == expected, f'Tested source changed: {name}'
package = root / 'build/DiceMercenaries_TACT01_Windows.zip'
with zipfile.ZipFile(package) as archive:
    manifest = json.loads(archive.read('DiceMercenaries/source-hashes.json'))
    for name, expected in manifest.items():
        assert hashlib.sha256((root / name.replace('\\', '/')).read_bytes()).hexdigest() == expected, f'Packaged source changed: {name}'
print('SOURCE_BINDING_PASS: retained native and Windows package gameplay bytes match checkout')
print('Windows ZIP SHA256:', hashlib.sha256(package.read_bytes()).hexdigest())

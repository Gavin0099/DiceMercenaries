"""Verify a fresh extracted development package; never relies on local .godot."""
import argparse
import json
from pathlib import Path
import subprocess
import tempfile
import zipfile


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--zip', required=True)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    checks = []
    with tempfile.TemporaryDirectory(prefix='dm01-package-') as directory:
        with zipfile.ZipFile(args.zip) as archive:
            archive.extractall(directory)
        folder = Path(directory) / 'DiceMercenaries'
        engine = folder / 'Godot.exe'
        game = folder / 'game'
        for suffix in (['--editor', '--import'], ['--quit-after', '8']):
            log = Path(directory) / ('import.log' if '--import' in suffix else 'startup.log')
            result = subprocess.run([str(engine), '--headless', '--path', str(game), '--log-file', str(log), *suffix], capture_output=True, timeout=90)
            text = log.read_text(encoding='utf-8', errors='replace') if log.exists() else ''
            ok = result.returncode == 0 and log.exists() and 'SCRIPT ERROR:' not in text and 'ERROR:' not in text
            checks.append({'arguments': suffix, 'returncode': result.returncode, 'ok': ok, 'log': text})
    output = Path(args.output)
    output.write_text(json.dumps({'ok': all(c['ok'] for c in checks), 'checks': checks}, indent=2), encoding='utf-8')
    if not all(c['ok'] for c in checks):
        raise SystemExit('Extracted package native check failed')
    print('DM01_PACKAGE_PASS')


if __name__ == '__main__':
    main()

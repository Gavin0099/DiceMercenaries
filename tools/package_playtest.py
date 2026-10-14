"""Create a portable development playtest; no Steam/release publication."""
from pathlib import Path
import argparse
import hashlib
import json
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--engine', required=True)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    engine = Path(args.engine)
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED) as archive:
        archive.write(engine, 'DiceMercenaries/Godot.exe')
        for folder in ('scripts', 'scenes'):
            for path in sorted((ROOT / folder).rglob('*')):
                if path.is_file() and path.suffix in ('.gd', '.tscn', '.uid'):
                    archive.write(path, 'DiceMercenaries/game/' + str(path.relative_to(ROOT)))
        archive.write(ROOT / 'project.godot', 'DiceMercenaries/game/project.godot')
        archive.writestr('DiceMercenaries/Play.cmd', '@echo off\r\ncd /d "%~dp0"\r\nstart /wait "Import" Godot.exe --headless --editor --path "%~dp0game" --import\r\nif errorlevel 1 (\r\n  pause\r\n  exit /b 1\r\n)\r\nstart "Dice Mercenaries" Godot.exe --path "%~dp0game"\r\n')
        archive.writestr('DiceMercenaries/README.txt', 'DM-01 development playtest (Godot editor engine in game mode, not an exported release).\nDouble-click Play.cmd. First launch imports source scripts locally.\nA/D: move; Space: jump; hold left mouse and release: fire; Esc: cancel; R: reset.\nFixed terrain; no D20, terrain destruction, enemy turns or saves.\nPlease report: can you aim without instruction? Can you intentionally hit and push a target into a wall?\n')
        manifest = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                    for p in [ROOT / 'project.godot', *sorted((ROOT / 'scripts').rglob('*.gd')),
                              *sorted((ROOT / 'scenes').rglob('*.tscn'))]}
        archive.writestr('DiceMercenaries/source-hashes.json', json.dumps(manifest, indent=2))
    print(output)


if __name__ == '__main__':
    main()

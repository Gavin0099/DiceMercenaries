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
        archive.writestr('DiceMercenaries/README.txt', 'TACT-01 warrior development playtest (Godot editor engine in game mode, not an exported release).\nDouble-click Play.cmd. First launch imports source scripts locally.\nA/D or click ground: move up to 240 pixels per turn.\n1: movement; 2: shield bash; 3: charge. Click an enemy to attack; charge can also break amber terrain.\nE: end turn; Esc: cancel skill selection; R: reset; M: reduce decorative effects.\nRed zones show enemy sweeps for the coming response. Push an enemy more than 80 pixels to interrupt.\nButtons 3/10/17/20 select fixed comparison rolls before moving. This is not the full D20/fate system.\nNo saves, equipment or map. Please report whether flanking and terrain change your choices.\n')
        manifest = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                    for p in [ROOT / 'project.godot', *sorted((ROOT / 'scripts').rglob('*.gd')),
                              *sorted((ROOT / 'scenes').rglob('*.tscn'))]}
        archive.writestr('DiceMercenaries/source-hashes.json', json.dumps(manifest, indent=2))
    print(output)


if __name__ == '__main__':
    main()

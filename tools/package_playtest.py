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
        archive.writestr('DiceMercenaries/README.txt', '骰子傭兵團：戰士對護衛與法師（開發測試包，非正式發行版）。\n雙擊 Play.cmd 啟動；首次啟動會匯入專案。\nA／D 或點地面移動；每回合共 240 移動額度。\n1 移動；2 盾擊；3 衝鋒；4 格擋。選招後點敵人攻擊。\nE 結束回合；Esc 切回移動；R 重開；M 減少動態。\n法師奇數回合施法，偶數回合恢復；紫區法術造成 3 傷害，藍色掩體可阻擋。\n護衛紅區揮擊造成 2 傷害；掩體不阻擋護衛。格擋減少每個敵人的傷害 2，會消耗攻擊。\n命中蓄力法師可打斷；衝鋒使用後下一回合冷卻。\n3／10／17／20 按鈕是固定骰點測試，尚未實作完整隨機 D20 與命運值。\n請比較突進打斷與掩體等待兩條路線；沒有存檔、裝備或冒險地圖。\n')
        manifest = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                    for p in [ROOT / 'project.godot', *sorted((ROOT / 'scripts').rglob('*.gd')),
                              *sorted((ROOT / 'scenes').rglob('*.tscn'))]}
        archive.writestr('DiceMercenaries/source-hashes.json', json.dumps(manifest, indent=2))
    print(output)


if __name__ == '__main__':
    main()

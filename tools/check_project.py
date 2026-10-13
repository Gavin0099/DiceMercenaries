"""Pinned native checks; DM-01 rules and scene integration. Python stdlib."""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import platform
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def run(command: list[str], timeout: int = 90) -> dict:
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True,
                            encoding='utf-8', errors='replace', timeout=timeout)
    output = result.stdout + result.stderr
    # Godot can return zero even after reporting a script parse error.
    ok = result.returncode == 0 and not any(
        token in output for token in ('SCRIPT ERROR:', 'Parse Error:', 'ERROR:'))
    return {'command': command, 'returncode': result.returncode,
            'ok': ok, 'output': output}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--godot', required=True)
    parser.add_argument('--output', default='artifacts/evidence/dm-01/native-check.json')
    args = parser.parse_args()
    evidence = {'slice': 'DM-01', 'platform': platform.platform(),
                'source_commit': subprocess.check_output(
                    ['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
                'worktree_changes': subprocess.check_output(
                    ['git', 'status', '--porcelain'], cwd=ROOT, text=True).splitlines(),
                'source_files_sha256': {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                    for p in [ROOT / 'project.godot', Path(__file__).resolve(),
                              *sorted((ROOT / 'scripts').rglob('*.gd')),
                              *sorted((ROOT / 'scenes').rglob('*.tscn')),
                              ROOT / 'tests/unit/test_shot_rules.gd',
                              ROOT / 'tests/integration/test_physics_lab.gd']},
                'checks': [], 'ok': False,
                'not_claimed': ['gameplay', 'Windows when run on Linux', 'Owner acceptance']}
    try:
        version = run([args.godot, '--version'])
        evidence['checks'].append(version)
        if not version['ok'] or not version['output'].strip().startswith('4.7.2.stable.'):
            raise RuntimeError('Official Godot 4.7.2 stable required')
        for suffix in (
            ['--headless', '--editor', '--import'],
            ['--headless', '--script', 'res://tests/unit/test_shot_rules.gd'],
            ['--headless', '--script', 'res://tests/integration/test_physics_lab.gd'],
            ['--headless', '--quit-after', '3'],
        ):
            check = run([args.godot, '--path', str(ROOT), *suffix])
            evidence['checks'].append(check)
            if not check['ok']:
                raise RuntimeError('Native Godot check failed')
            if '--script' in suffix:
                sentinel = 'DM01_RULES_PASS' if '/unit/' in suffix[-1] else 'DM01_PHYSICS_PASS'
                if sentinel not in check['output']:
                    raise RuntimeError('Native test success sentinel missing')
        evidence['ok'] = True
    except (OSError, subprocess.SubprocessError, RuntimeError) as exc:
        evidence['error'] = str(exc)
    output = ROOT / args.output
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(evidence, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    print(f"DM-01: {'PASS' if evidence['ok'] else 'FAIL'}; evidence={output}")
    return 0 if evidence['ok'] else 1


if __name__ == '__main__':
    sys.exit(main())

"""Pinned DM-00/DM-01 native checks. Python stdlib."""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import platform
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def acceptance_profile() -> tuple[str, list[Path], list[tuple[str, str]]]:
    entries = re.findall(r'^run/main_scene="([^"]+)"\s*$',
                         (ROOT / 'project.godot').read_text(encoding='utf-8'), re.MULTILINE)
    if entries == ['res://scenes/ui/bootstrap.tscn']:
        return 'DM-00', [ROOT / 'scenes/ui/bootstrap.tscn',
                         ROOT / 'tests/integration/test_bootstrap.gd'], [
            ('res://tests/integration/test_bootstrap.gd', 'DM00_BOOTSTRAP_PASS')]
    if entries == ['res://scenes/battle/physics_lab.tscn']:
        return 'DM-01', [*sorted((ROOT / 'scripts').rglob('*.gd')),
                         *sorted((ROOT / 'scenes').rglob('*.tscn')),
                         ROOT / 'tests/unit/test_shot_rules.gd',
                         ROOT / 'tests/integration/test_physics_lab.gd'], [
            ('res://tests/unit/test_shot_rules.gd', 'DM01_RULES_PASS'),
            ('res://tests/integration/test_physics_lab.gd', 'DM01_PHYSICS_PASS')]
    raise ValueError('Exactly one supported main scene is required')


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
    parser.add_argument('--output', default='memory/evidence/native-adoption/native-check.json')
    args = parser.parse_args()
    evidence = {'slice': 'unknown', 'platform': platform.platform(),
                'source_commit': subprocess.check_output(
                    ['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
                'worktree_changes': subprocess.check_output(
                    ['git', 'status', '--porcelain'], cwd=ROOT, text=True).splitlines(),
                'source_files_sha256': {},
                'checks': [], 'ok': False,
                'not_claimed': ['gameplay', 'Windows when run on Linux', 'Owner acceptance']}
    try:
        slice_name, sources, scripts = acceptance_profile()
        evidence['slice'] = slice_name
        evidence['source_files_sha256'] = {
            str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in [ROOT / 'project.godot', Path(__file__).resolve(), *sources]}
        version = run([args.godot, '--version'])
        evidence['checks'].append(version)
        if not version['ok'] or not version['output'].strip().startswith('4.7.2.stable.'):
            raise RuntimeError('Official Godot 4.7.2 stable required')
        for suffix in (
            ['--headless', '--editor', '--import'],
            *[['--headless', '--script', script] for script, _ in scripts],
            ['--headless', '--quit-after', '3'],
        ):
            check = run([args.godot, '--path', str(ROOT), *suffix])
            evidence['checks'].append(check)
            if not check['ok']:
                raise RuntimeError('Native Godot check failed')
            if '--script' in suffix:
                sentinel = dict(scripts)[suffix[-1]]
                if sentinel not in check['output']:
                    raise RuntimeError('Native test success sentinel missing')
        evidence['ok'] = True
    except (OSError, subprocess.SubprocessError, RuntimeError, ValueError) as exc:
        evidence['error'] = str(exc)
    output = ROOT / args.output
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(evidence, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    print(f"{evidence['slice']}: {'PASS' if evidence['ok'] else 'FAIL'}; evidence={output}")
    return 0 if evidence['ok'] else 1


if __name__ == '__main__':
    sys.exit(main())

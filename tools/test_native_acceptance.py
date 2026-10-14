"""Replay the actual engine through pre/post-task checks in disposable copies."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
CANDIDATE_FILES = (
    'contract.yaml', 'PLAN.md', 'tools/check_governance.py',
    'governance/validators/native_project.py', 'tests/governance/test_native_validator.py',
    'governance/rules/dm-native-check/acceptance.md',
)
GAME_FILES = ('project.godot', 'scenes/ui/bootstrap.tscn', 'tests/integration/test_bootstrap.gd')


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--godot', required=True)
    parser.add_argument('--framework-root', type=Path, default=ROOT / '.ai-governance-framework')
    parser.add_argument('--output', type=Path, default=ROOT / 'memory/evidence/native-adoption/native-cases.json')
    args = parser.parse_args()
    before = {name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest() for name in GAME_FILES}
    report = {'ok': False, 'cases': [], 'not_claimed': ['gameplay', 'hosted CI', 'pinned adoption']}
    with tempfile.TemporaryDirectory(prefix='dm-native-cases-') as directory:
        for case in ('healthy', 'missing_engine', 'bad_script', 'bad_scene'):
            target = Path(directory) / case
            subprocess.run(['git', '-c', 'core.longpaths=true', 'clone', '--quiet', '--shared',
                            '--no-hardlinks', str(ROOT), str(target)], check=True,
                           capture_output=True, text=True)
            for name in CANDIDATE_FILES:
                destination = target / name
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(ROOT / name, destination)
            if case == 'bad_script':
                (target / 'tests/integration/test_bootstrap.gd').write_text(
                    'extends SceneTree\nfunc _initialize(:\n', encoding='utf-8')
            elif case == 'bad_scene':
                (target / 'scenes/ui/bootstrap.tscn').write_text(
                    '[gd_scene format=3]\n[node name="Broken" type="Node"]\n', encoding='utf-8')
            output = target / 'memory/evidence/native-adoption/runtime.json'
            engine = str(target / 'engine-does-not-exist') if case == 'missing_engine' else args.godot
            command = [sys.executable, str(target / 'tools/check_governance.py'),
                       '--godot', engine, '--framework-root', str(args.framework_root.resolve()),
                       '--output', str(output)]
            result = subprocess.run(command, cwd=target, capture_output=True, text=True,
                                    encoding='utf-8', errors='replace', timeout=420)
            runtime = json.loads(output.read_text(encoding='utf-8'))
            validators = runtime.get('post_task', {}).get('domain_validator_results', [])
            expected_ok = case == 'healthy'
            matched = (runtime.get('pre_task', {}).get('ok') is True
                       and len(validators) == 1
                       and validators[0].get('ok') is expected_ok
                       and runtime['ok'] is expected_ok
                       and (result.returncode == 0) is expected_ok)
            report['cases'].append({'case': case, 'expected_ok': expected_ok, 'matched': matched,
                                    'returncode': result.returncode, 'runtime': runtime})
            print(f"{case}: {'PASS' if matched else 'FAIL'} (native verdict={runtime['ok']})")
    after = {name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest() for name in GAME_FILES}
    report['source_preserved'] = after == before
    report['ok'] = report['source_preserved'] and all(case['matched'] for case in report['cases'])
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    return 0 if report['ok'] else 1


if __name__ == '__main__':
    sys.exit(main())

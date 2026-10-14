"""Run existing pre/post-task checks with fresh native slice acceptance."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--godot', required=True)
    parser.add_argument('--framework-root', type=Path, default=ROOT / '.ai-governance-framework')
    parser.add_argument('--output', type=Path, default=ROOT / 'memory/evidence/native-adoption/runtime.json')
    args = parser.parse_args()
    framework = args.framework_root.resolve()
    report = {'ok': False, 'framework_root': str(framework),
              'candidate_framework_override': framework != (ROOT / '.ai-governance-framework').resolve(),
              'source_commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
              'not_claimed': ['gameplay', 'Owner acceptance', 'full adoption', 'hosted CI']}
    try:
        report['consumer_adapter_source_sha256'] = {
            name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
            for name in ('contract.yaml', 'governance/validators/native_project.py',
                         'tools/check_governance.py', 'tests/governance/test_native_validator.py')}
        sys.path.insert(0, str(framework))
        from governance_tools.contract_validator import VALID_LANG
        from runtime_hooks.core.pre_task_check import run_pre_task_check
        from runtime_hooks.core.post_task_check import run_post_task_check
        from governance_tools import output_tier
        # The consumer owns the evidence destination; do not scatter L2 traces
        # in the worktree root. This changes storage only, not tier/gate policy.
        args.output.parent.mkdir(parents=True, exist_ok=True)
        output_tier.GOVERNANCE_AUDIT_DIR = args.output.resolve().parent / 'audit'
        if 'GDScript' not in VALID_LANG:
            raise ValueError('Framework does not yet support GDScript; publish/adopt the reviewed S1/S2 candidate first')
        # Record exactly which candidate bytes are being exercised locally.
        report['framework_source_sha256'] = {
            name: hashlib.sha256((framework / name).read_bytes()).hexdigest()
            for name in ('governance_tools/contract_validator.py', 'governance_tools/rule_pack_loader.py',
                         'governance_tools/rule_pack_suggester.py', 'governance/rules/gdscript/coding.md')}
        for name in ('SYSTEM_PROMPT.md', 'AGENT.md', 'TESTING.md'):
            (framework / 'governance' / name).read_text(encoding='utf-8')
        rules = 'common,gdscript,dm-native-check'
        dm01 = 'res://scenes/battle/physics_lab.tscn' in (ROOT / 'project.godot').read_text(encoding='utf-8')
        slice_name = 'DM-01' if dm01 else 'DM-00'
        level = 'L2' if dm01 else 'L1'
        loaded = 'SYSTEM_PROMPT, AGENT, TESTING'
        if dm01:
            (framework / 'governance/ARCHITECTURE.md').read_text(encoding='utf-8')
            loaded += ', ARCHITECTURE'
        changed_files = ['project.godot', 'tools/check_project.py'] + (
            ['scenes/battle/physics_lab.tscn', 'tests/integration/test_physics_lab.gd',
             'tests/unit/test_shot_rules.gd',
             *[p.relative_to(ROOT).as_posix() for p in sorted((ROOT / 'scripts').rglob('*.gd'))]]
            if dm01 else ['scenes/ui/bootstrap.tscn', 'tests/integration/test_bootstrap.gd'])
        report['pre_task'] = run_pre_task_check(ROOT, rules=rules, risk='medium',
            oversight='review-required', memory_mode='candidate', task_level=level,
            contract_file=ROOT / 'contract.yaml', task_text=f'Verify {slice_name} native acceptance')
        if not report['pre_task']['ok']:
            raise ValueError('Pre-task check failed; native acceptance was not run')
        test_command = [sys.executable, '-m', 'unittest', 'discover', '-s', 'tests/governance', '-v']
        test_env = dict(os.environ, DM_FRAMEWORK_ROOT=str(framework))
        test_result = subprocess.run(test_command, cwd=ROOT, env=test_env,
            capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=60)
        test_output = test_result.stdout + test_result.stderr
        report['interface_tests'] = {'command': test_command, 'returncode': test_result.returncode,
            'output': test_output, 'claim_ceiling': 'validator interface tests with stub evidence only'}
        if test_result.returncode != 0:
            raise ValueError('Validator interface tests failed')
        test_names = re.findall(r'^(test_\w+)\s+\(', test_output, re.MULTILINE)
        memory_path = ROOT / 'memory/01_active_task.md'
        content = memory_path.read_text(encoding='utf-8') if memory_path.exists() else ''
        contract = '\n'.join([
            '[Governance Contract]', 'LANG = GDScript, Python', f'LEVEL = {level}', 'SCOPE = tooling',
            f'PLAN = PLAN.md / {slice_name} native acceptance', f'LOADED = {loaded}',
            f'CONTEXT = {slice_name} -> native import/test/startup; NOT: gameplay or full adoption',
            f'PRESSURE = SAFE ({len(content.splitlines())}/200 lines; {len(content)} chars)',
            f'RULES = {rules}', 'RISK = medium', 'OVERSIGHT = review-required', 'MEMORY_MODE = candidate',
        ])
        report['post_task'] = run_post_task_check(contract, risk='medium',
            oversight='review-required', memory_mode='candidate',
            project_root=ROOT, contract_file=ROOT / 'contract.yaml',
            checks={'godot_path': args.godot, 'test_names': test_names,
                    'changed_files': changed_files})
        validators = report['post_task'].get('domain_validator_results', [])
        if (len(validators) != 1 or validators[0].get('rule_ids') != ['dm-native-check']
                or validators[0].get('ok') is not True):
            raise ValueError('Bound native validator did not execute successfully')
        report['ok'] = report['post_task']['ok']
    except (OSError, ValueError, ImportError, subprocess.SubprocessError) as exc:
        report['error'] = str(exc)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    print(f"DM native governance: {'PASS' if report['ok'] else 'FAIL'}; evidence={args.output}")
    return 0 if report['ok'] else 1


if __name__ == '__main__':
    sys.exit(main())

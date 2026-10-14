"""Interface tests; stub evidence is not Godot or gameplay evidence."""
from __future__ import annotations

import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import unittest

ROOT = Path(__file__).resolve().parents[2]
FRAMEWORK = Path(os.environ.get('DM_FRAMEWORK_ROOT', ROOT / '.ai-governance-framework'))
sys.path.insert(0, str(FRAMEWORK.resolve()))
SPEC = importlib.util.spec_from_file_location('dm_native', ROOT / 'governance/validators/native_project.py')
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class NativeValidatorTests(unittest.TestCase):
    def evidence(self):
        godot = 'fixture-godot'
        commands = [
            [godot, '--version'],
            [godot, '--path', str(ROOT), '--headless', '--editor', '--import'],
            [godot, '--path', str(ROOT), '--headless', '--script', 'res://tests/integration/test_bootstrap.gd'],
            [godot, '--path', str(ROOT), '--headless', '--quit-after', '3'],
        ]
        return {'slice': 'DM-00', 'ok': True,
                'source_commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
                'source_files_sha256': {name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
                    for name in ('project.godot', 'scenes/ui/bootstrap.tscn',
                                 'tests/integration/test_bootstrap.gd', 'tools/check_project.py')},
                'checks': [{'command': command, 'ok': True, 'returncode': 0,
                            'output': '4.7.2.stable.fixture' if index == 0 else
                                      ('DM00_BOOTSTRAP_PASS' if index == 2 else '')}
                           for index, command in enumerate(commands)]}

    def validate(self, evidence, *, returncode=0, write=True):
        def runner(command, **kwargs):
            if write:
                Path(command[-1]).write_text(json.dumps(evidence), encoding='utf-8')
            return subprocess.CompletedProcess(command, returncode, stdout='', stderr='')
        return MODULE.NativeProjectValidator(runner=runner).validate({'checks': {'godot_path': 'fixture-godot'}})

    def test_complete_fresh_checker_output_passes_interface(self):
        result = self.validate(self.evidence())
        self.assertTrue(result.ok)
        self.assertEqual(result.rule_ids, ['dm-native-check'])
        self.assertEqual(result.violations, [])

    def test_missing_engine_declaration_fails(self):
        result = MODULE.NativeProjectValidator().validate({'checks': {}})
        self.assertFalse(result.ok)
        self.assertIn('godot_path', result.violations[0])

    def test_windows_relative_source_paths_are_equivalent(self):
        evidence = self.evidence()
        evidence['source_files_sha256'] = {name.replace('/', '\\'): value
                                          for name, value in evidence['source_files_sha256'].items()}
        self.assertTrue(self.validate(evidence).ok)

    def test_missing_fresh_output_fails(self):
        result = self.validate(self.evidence(), write=False)
        self.assertFalse(result.ok)
        self.assertIn('fresh', result.violations[0])

    def test_failed_checker_cannot_be_overridden_by_success_json(self):
        self.assertFalse(self.validate(self.evidence(), returncode=1).ok)

    def test_stale_head_or_source_hash_fails(self):
        for field, replacement in (('source_commit', '0' * 40), ('source_files_sha256', {})):
            with self.subTest(field=field):
                evidence = self.evidence()
                evidence[field] = replacement
                self.assertFalse(self.validate(evidence).ok)

    def test_bad_script_zero_exit_incomplete_or_missing_sentinel_fails(self):
        for defect in ('parse_error', 'incomplete', 'sentinel', 'wrong_version'):
            with self.subTest(defect=defect):
                evidence = self.evidence()
                if defect == 'parse_error':
                    evidence['checks'][2]['output'] = 'SCRIPT ERROR: Parse Error: bad script'
                elif defect == 'incomplete':
                    evidence['checks'].pop()
                elif defect == 'sentinel':
                    evidence['checks'][2]['output'] = ''
                else:
                    evidence['checks'][0]['output'] = '4.6.stable.fixture'
                self.assertFalse(self.validate(evidence).ok)

    def test_domain_loader_discovers_and_executes_bound_validator(self):
        from governance_tools.domain_validator_loader import preflight_domain_validators, run_domain_validators
        preflight = preflight_domain_validators(ROOT / 'contract.yaml')
        self.assertTrue(preflight['ok'])
        self.assertEqual(preflight['count'], 1)
        results = run_domain_validators(contract_file=ROOT / 'contract.yaml',
            payload={'checks': {}}, active_rule_ids=['common', 'dm-native-check'])
        self.assertEqual(len(results), 1)
        self.assertFalse(results[0]['ok'])
        self.assertEqual(run_domain_validators(contract_file=ROOT / 'contract.yaml',
            payload={'checks': {}}, active_rule_ids=['common']), [])


if __name__ == '__main__':
    unittest.main()

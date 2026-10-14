"""Interface tests; stub evidence is not Godot or gameplay evidence."""
from __future__ import annotations

import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import shutil
import unittest

ROOT = Path(__file__).resolve().parents[2]
FRAMEWORK = Path(os.environ.get('DM_FRAMEWORK_ROOT', ROOT / '.ai-governance-framework'))
sys.path.insert(0, str(FRAMEWORK.resolve()))
SPEC = importlib.util.spec_from_file_location('dm_native', ROOT / 'governance/validators/native_project.py')
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class NativeValidatorTests(unittest.TestCase):
    def evidence(self, root=ROOT, dm00=None):
        if dm00 is None:
            dm00 = 'res://scenes/ui/bootstrap.tscn' in (root / 'project.godot').read_text(encoding='utf-8')
        godot = 'fixture-godot'
        commands = [
            [godot, '--version'],
            [godot, '--path', str(root), '--headless', '--editor', '--import'],
            *([[godot, '--path', str(root), '--headless', '--script', 'res://tests/integration/test_bootstrap.gd']]
              if dm00 else [
                [godot, '--path', str(root), '--headless', '--script', 'res://tests/unit/test_shot_rules.gd'],
                [godot, '--path', str(root), '--headless', '--script', 'res://tests/integration/test_physics_lab.gd']]),
            [godot, '--path', str(root), '--headless', '--quit-after', '3'],
        ]
        names = ('project.godot', 'scenes/ui/bootstrap.tscn',
                 'tests/integration/test_bootstrap.gd', 'tools/check_project.py') if dm00 else (
            'project.godot', 'tools/check_project.py',
            'scripts/domain/shot_rules.gd', 'scripts/combat/player_body.gd',
            'scripts/combat/projectile_body.gd', 'scripts/combat/target_body.gd',
            'scripts/presentation/physics_lab.gd', 'scenes/battle/physics_lab.tscn',
            'scenes/ui/bootstrap.tscn', 'tests/unit/test_shot_rules.gd',
            'tests/integration/test_physics_lab.gd')
        outputs = ['4.7.2.stable.fixture', '', 'DM00_BOOTSTRAP_PASS', ''] if dm00 else [
            '4.7.2.stable.fixture', '', 'DM01_RULES_PASS', 'DM01_PHYSICS_PASS', '']
        return {'slice': 'DM-00' if dm00 else 'DM-01', 'ok': True,
                'source_commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
                'source_files_sha256': {name: hashlib.sha256((root / name).read_bytes()).hexdigest()
                                       for name in names},
                'checks': [{'command': command, 'ok': True, 'returncode': 0,
                            'output': outputs[index]}
                           for index, command in enumerate(commands)]}

    def validate(self, evidence, *, returncode=0, write=True, root=ROOT):
        def runner(command, **kwargs):
            if write:
                Path(command[-1]).write_text(json.dumps(evidence), encoding='utf-8')
            return subprocess.CompletedProcess(command, returncode, stdout='', stderr='')
        return MODULE.NativeProjectValidator(project_root=root, runner=runner).validate({'checks': {'godot_path': 'fixture-godot'}})

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
        defects = ['parse_error', 'incomplete', 'rules_sentinel', 'wrong_version']
        if self.evidence()['slice'] == 'DM-01':
            defects.append('physics_sentinel')
        for defect in defects:
            with self.subTest(defect=defect):
                evidence = self.evidence()
                if defect == 'parse_error':
                    evidence['checks'][2]['output'] = 'SCRIPT ERROR: Parse Error: bad script'
                elif defect == 'incomplete':
                    evidence['checks'].pop()
                elif defect == 'rules_sentinel':
                    evidence['checks'][2]['output'] = ''
                elif defect == 'physics_sentinel':
                    evidence['checks'][3]['output'] = ''
                else:
                    evidence['checks'][0]['output'] = '4.6.stable.fixture'
                self.assertFalse(self.validate(evidence).ok)

    def test_wrong_slice_command_or_duplicate_source_fails(self):
        for defect in ('slice', 'command', 'duplicate_source', 'missing_game_source'):
            with self.subTest(defect=defect):
                evidence = self.evidence()
                if defect == 'slice':
                    evidence['slice'] = 'DM-00' if evidence['slice'] == 'DM-01' else 'DM-01'
                elif defect == 'command':
                    evidence['checks'][2]['command'][-1] = 'res://tests/integration/wrong_test.gd'
                elif defect == 'duplicate_source':
                    name = next(n for n in evidence['source_files_sha256'] if '/' in n)
                    evidence['source_files_sha256'][name.replace('/', '\\')] = evidence['source_files_sha256'][name]
                else:
                    name = next(n for n in evidence['source_files_sha256'] if n.startswith('scenes/'))
                    del evidence['source_files_sha256'][name]
                self.assertFalse(self.validate(evidence).ok)

    def test_dm00_profile_still_requires_complete_bootstrap_evidence(self):
        with tempfile.TemporaryDirectory(prefix='.dm00-interface-', dir=ROOT) as directory:
            root = Path(directory)
            for name in ('project.godot', 'tools/check_project.py', 'scenes/ui/bootstrap.tscn',
                         'tests/integration/test_bootstrap.gd'):
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(ROOT / name, path)
            project = root / 'project.godot'
            project.write_text(project.read_text().replace('res://scenes/battle/physics_lab.tscn',
                                                         'res://scenes/ui/bootstrap.tscn'))
            evidence = self.evidence(root, dm00=True)
            self.assertTrue(self.validate(evidence, root=root).ok)
            evidence['checks'][2]['output'] = ''
            self.assertFalse(self.validate(evidence, root=root).ok)

    def test_unsupported_or_duplicate_scene_is_rejected(self):
        with tempfile.TemporaryDirectory(prefix='.scene-interface-', dir=ROOT) as directory:
            root = Path(directory)
            for project in ('run/main_scene="res://other.tscn"\n',
                            'run/main_scene="res://scenes/battle/physics_lab.tscn"\n' * 2):
                (root / 'project.godot').write_text(project)
                result = self.validate({}, root=root)
                self.assertFalse(result.ok)
                self.assertIn('main scene', result.violations[0])

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

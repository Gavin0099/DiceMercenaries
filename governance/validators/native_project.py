"""Bind fresh DM-00/DM-01 evidence to the framework DomainValidator seam."""
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path
import subprocess
import sys
import tempfile

from governance_tools.validator_interface import DomainValidator, ValidatorResult


SOURCE_FILES = (
    'project.godot', 'scenes/ui/bootstrap.tscn',
    'tests/integration/test_bootstrap.gd', 'tools/check_project.py',
)


def profile(root: Path) -> tuple[str, tuple[str, ...], list[tuple[str, str]]]:
    scenes = re.findall(r'^run/main_scene="([^"]+)"\s*$',
                        (root / 'project.godot').read_text(encoding='utf-8'), re.MULTILINE)
    if scenes == ['res://scenes/ui/bootstrap.tscn']:
        return 'DM-00', SOURCE_FILES, [
            ('res://tests/integration/test_bootstrap.gd', 'DM00_BOOTSTRAP_PASS')]
    if scenes == ['res://scenes/battle/physics_lab.tscn']:
        sources = ('project.godot', 'tools/check_project.py',
                   *[p.relative_to(root).as_posix() for p in sorted((root / 'scripts').rglob('*.gd'))],
                   *[p.relative_to(root).as_posix() for p in sorted((root / 'scenes').rglob('*.tscn'))],
                   'tests/unit/test_shot_rules.gd', 'tests/integration/test_physics_lab.gd')
        return 'DM-01', sources, [
            ('res://tests/unit/test_shot_rules.gd', 'DM01_RULES_PASS'),
            ('res://tests/integration/test_physics_lab.gd', 'DM01_PHYSICS_PASS')]
    raise ValueError('Exactly one supported main scene is required')


class NativeProjectValidator(DomainValidator):
    def __init__(self, project_root: Path | None = None, runner=None):
        self.root = (project_root or Path(__file__).resolve().parents[2]).resolve()
        self.runner = runner or subprocess.run

    @property
    def rule_ids(self) -> list[str]:
        return ['dm-native-check']

    def validate(self, payload: dict) -> ValidatorResult:
        metadata: dict = {'not_claimed': ['gameplay', 'Owner acceptance', 'full adoption']}
        try:
            checks = payload.get('checks') or {}
            godot = checks.get('godot_path')
            if not isinstance(godot, str) or not godot.strip():
                raise ValueError('Native acceptance requires an explicit godot_path')
            slice_name, source_files, scripts = profile(self.root)
            hashes = {name: hashlib.sha256((self.root / name).read_bytes()).hexdigest()
                      for name in source_files}
            head = subprocess.check_output(
                ['git', 'rev-parse', 'HEAD'], cwd=self.root, text=True).strip()
            with tempfile.TemporaryDirectory(prefix='dm-native-check-') as directory:
                output = Path(directory) / 'native.json'
                command = [sys.executable, str(self.root / 'tools/check_project.py'),
                           '--godot', godot, '--output', str(output)]
                result = self.runner(command, cwd=self.root, capture_output=True,
                                     text=True, encoding='utf-8', errors='replace', timeout=300)
                metadata['checker_returncode'] = result.returncode
                metadata['checker_output'] = result.stdout + result.stderr
                if not output.is_file():
                    raise ValueError('Checker did not produce fresh native evidence')
                evidence = json.loads(output.read_text(encoding='utf-8'))
            metadata['native_evidence'] = evidence
            if result.returncode != 0 or evidence.get('ok') is not True:
                raise ValueError(evidence.get('error') or 'Native Godot check failed')
            if evidence.get('slice') != slice_name or evidence.get('source_commit') != head:
                raise ValueError('Native evidence is not bound to this slice and HEAD')
            recorded_hashes = evidence.get('source_files_sha256')
            if not isinstance(recorded_hashes, dict):
                raise ValueError('Native source hashes are missing')
            normalized_hashes = {name.replace('\\', '/'): value
                                 for name, value in recorded_hashes.items()}
            if len(normalized_hashes) != len(recorded_hashes) or normalized_hashes != hashes:
                raise ValueError('Native evidence does not match current source bytes')
            current_hashes = {name: hashlib.sha256((self.root / name).read_bytes()).hexdigest()
                              for name in source_files}
            if current_hashes != hashes:
                raise ValueError('Native source changed during acceptance')
            expected = [
                [godot, '--version'],
                [godot, '--path', str(self.root), '--headless', '--editor', '--import'],
                *[[godot, '--path', str(self.root), '--headless', '--script', script]
                  for script, _ in scripts],
                [godot, '--path', str(self.root), '--headless', '--quit-after', '3'],
            ]
            native_checks = evidence.get('checks')
            if not isinstance(native_checks, list) or len(native_checks) != len(expected):
                raise ValueError('Incomplete native acceptance sequence')
            for check, expected_command in zip(native_checks, expected):
                if (check.get('command') != expected_command or check.get('ok') is not True
                        or check.get('returncode') != 0
                        or any(token in check.get('output', '')
                               for token in ('SCRIPT ERROR:', 'Parse Error:', 'ERROR:'))):
                    raise ValueError('Native acceptance sequence contains a failed check')
            if not native_checks[0]['output'].strip().startswith('4.7.2.stable.'):
                raise ValueError('Official Godot 4.7.2 stable required')
            for index, (_, sentinel) in enumerate(scripts, 2):
                if sentinel not in native_checks[index]['output']:
                    raise ValueError('Native test success sentinel missing')
            return ValidatorResult(True, self.rule_ids,
                                   evidence_summary=f'Fresh {slice_name} native import/test/startup passed',
                                   metadata=metadata)
        except (OSError, subprocess.SubprocessError, ValueError, TypeError, AttributeError) as exc:
            return ValidatorResult(False, self.rule_ids, violations=[str(exc)],
                                   evidence_summary='Native acceptance failed', metadata=metadata)

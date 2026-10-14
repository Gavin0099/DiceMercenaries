"""Adapt the existing DM-00 checker to the framework's DomainValidator seam."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile

from governance_tools.validator_interface import DomainValidator, ValidatorResult


SOURCE_FILES = (
    'project.godot', 'scenes/ui/bootstrap.tscn',
    'tests/integration/test_bootstrap.gd', 'tools/check_project.py',
)


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
            hashes = {name: hashlib.sha256((self.root / name).read_bytes()).hexdigest()
                      for name in SOURCE_FILES}
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
            if evidence.get('slice') != 'DM-00' or evidence.get('source_commit') != head:
                raise ValueError('Native evidence is not bound to this DM-00 HEAD')
            recorded_hashes = evidence.get('source_files_sha256')
            if not isinstance(recorded_hashes, dict):
                raise ValueError('Native source hashes are missing')
            normalized_hashes = {name.replace('\\', '/'): value
                                 for name, value in recorded_hashes.items()}
            if len(normalized_hashes) != len(recorded_hashes) or normalized_hashes != hashes:
                raise ValueError('Native evidence does not match current source bytes')
            current_hashes = {name: hashlib.sha256((self.root / name).read_bytes()).hexdigest()
                              for name in SOURCE_FILES}
            if current_hashes != hashes:
                raise ValueError('Native source changed during acceptance')
            expected = [
                [godot, '--version'],
                [godot, '--path', str(self.root), '--headless', '--editor', '--import'],
                [godot, '--path', str(self.root), '--headless', '--script',
                 'res://tests/integration/test_bootstrap.gd'],
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
            if 'DM00_BOOTSTRAP_PASS' not in native_checks[2]['output']:
                raise ValueError('Bootstrap success sentinel missing')
            return ValidatorResult(True, self.rule_ids,
                                   evidence_summary='Fresh DM-00 native import/test/startup passed',
                                   metadata=metadata)
        except (OSError, subprocess.SubprocessError, ValueError, TypeError, AttributeError) as exc:
            return ValidatorResult(False, self.rule_ids, violations=[str(exc)],
                                   evidence_summary='DM-00 native acceptance failed', metadata=metadata)

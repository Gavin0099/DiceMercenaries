"""Regression fixture: transient Windows locks retry; persistent/other errors fail."""
import runpy
from unittest.mock import patch
cleanup = runpy.run_path('tools/verify_playtest.py')['cleanup_with_retry']
class Fixture:
    def __init__(self, failures, sharing=True):
        self.failures, self.sharing, self.calls = failures, sharing, 0
    def cleanup(self):
        self.calls += 1
        if self.calls <= self.failures:
            error = PermissionError('fixture locked')
            error.winerror = 32 if self.sharing else 5
            raise error
with patch('time.sleep'):
    value = Fixture(2)
    cleanup(value)
    assert value.calls == 3
    value = Fixture(20)
    try:
        cleanup(value)
        raise AssertionError('Persistent lock falsely passed')
    except PermissionError:
        assert value.calls == 11
    value = Fixture(1, False)
    try:
        cleanup(value)
        raise AssertionError('Other permission failure swallowed')
    except PermissionError:
        assert value.calls == 1
print('PACKAGE_CLEANUP_FIXTURE_PASS cases=3')

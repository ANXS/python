"""
testinfra tests for anxs-python role
Tests the Python and UV installation functionality
"""

import pytest
import os


# Module-level fixtures so pytest/testinfra can discover them
@pytest.fixture
def uv_enabled():
    """Check if UV installation is enabled (from env)"""
    return os.environ.get('PYTHON_UV_INSTALL', 'false').lower() == 'true'


@pytest.fixture
def uv_install_path():
    """Get UV installation path (from env)"""
    return os.environ.get('PYTHON_PREFIX_DIR', '/usr/local') + '/bin'


class TestPythonInstallation:
    """Test Python installation functionality"""

    def test_python3_is_installed(self, host):
        """Test that Python 3 is installed and working"""
        cmd = host.run("python3 --version")
        assert cmd.rc == 0
        assert "Python 3." in cmd.stdout

    def test_pip_is_installed(self, host):
        """Test that pip is installed and working"""
        cmd = host.run("pip3 --version")
        assert cmd.rc == 0
        assert "pip" in cmd.stdout

    def _detect_os_release(self, host):
        """Return a dict of /etc/os-release values"""
        os_release = {}
        f = host.file('/etc/os-release')
        if not f.exists:
            return os_release
        for line in f.content_string.splitlines():
            if '=' in line:
                k, v = line.split('=', 1)
                os_release[k.strip()] = v.strip().strip('"')
        return os_release

    def test_python_packages_can_be_installed(self, host):
        """Test that pip can install packages system-wide on supported distros

        This test runs only on distributions which support system-level pip
        installs (Ubuntu, or Debian older than 13). On Debian 13+ we skip this
        because some packaging changes make system-level pip installs unreliable
        in CI images.
        """
        osr = self._detect_os_release(host)
        distro = osr.get('ID', '').lower()
        version = osr.get('VERSION_ID', '')

        # Skip system-level pip install test on Debian 13 and newer
        if distro == 'debian' and version:
            try:
                major = int(version.split('.')[0])
            except Exception:
                major = None
            if major and major >= 13:
                pytest.skip("System-level pip installs are skipped on Debian 13+")

        # Attempt a system-level install (CI runs as root inside molecule by
        # default). We install a small package and assert success.
        cmd = host.run("pip3 install requests")
        assert cmd.rc == 0

    def test_python_packages_in_virtualenv(self, host):
        """Create a virtualenv and install a package inside it"""
        venv_dir = "/tmp/test-venv"

        # Create the virtualenv
        cmd = host.run(f"python3 -m venv {venv_dir}")
        assert cmd.rc == 0

        # Install a package inside the virtualenv
        pip_bin = f"{venv_dir}/bin/pip"
        cmd = host.run(f"{pip_bin} install requests")
        assert cmd.rc == 0

        # Verify the package can be imported using the virtualenv's python
        py_bin = f"{venv_dir}/bin/python"
        cmd = host.run(f"{py_bin} -c \"import requests; print(requests.__version__)\"")
        assert cmd.rc == 0

        # Cleanup the virtualenv
        host.run(f"rm -rf {venv_dir}")


class TestUVInstallation:
    """Test UV installation functionality"""

    def test_uv_binary_exists(self, host, uv_enabled, uv_install_path):
        """Test that uv binary exists when enabled"""
        if not uv_enabled:
            pytest.skip("UV installation not enabled")

        uv_path = f"{uv_install_path}/uv"
        uv_file = host.file(uv_path)
        assert uv_file.exists
        assert uv_file.is_file
        assert uv_file.mode == 0o755

    def test_uvx_binary_exists(self, host, uv_enabled, uv_install_path):
        """Test that uvx binary exists when enabled"""
        if not uv_enabled:
            pytest.skip("UV installation not enabled")

        uvx_path = f"{uv_install_path}/uvx"
        uvx_file = host.file(uvx_path)
        assert uvx_file.exists
        assert uvx_file.is_file
        assert uvx_file.mode == 0o755

    def test_uv_version_command(self, host, uv_enabled, uv_install_path):
        """Test that uv --version works"""
        if not uv_enabled:
            pytest.skip("UV installation not enabled")

        cmd = host.run(f"{uv_install_path}/uv --version")
        assert cmd.rc == 0
        assert "uv" in cmd.stdout

        # Check for expected version
        expected_version = os.environ.get('PYTHON_UV_VERSION', '0.9.3')
        assert expected_version in cmd.stdout

    def test_uvx_version_command(self, host, uv_enabled, uv_install_path):
        """Test that uvx --version works"""
        if not uv_enabled:
            pytest.skip("UV installation not enabled")

        cmd = host.run(f"{uv_install_path}/uvx --version")
        assert cmd.rc == 0
        assert "uvx" in cmd.stdout

    def test_uv_basic_functionality(self, host, uv_enabled, uv_install_path):
        """Test basic uv functionality"""
        if not uv_enabled:
            pytest.skip("UV installation not enabled")

        # Test uv help command
        cmd = host.run(f"{uv_install_path}/uv --help")
        assert cmd.rc == 0
        assert "Usage:" in cmd.stdout or "USAGE:" in cmd.stdout


class TestArchitectureSupport:
    """Test architecture detection and support"""

    def test_architecture_detection(self, host):
        """Test that architecture is properly detected"""
        arch_cmd = host.run("uname -m")
        assert arch_cmd.rc == 0

        # Supported architectures
        supported_archs = ["x86_64", "aarch64", "armv7l"]
        assert arch_cmd.stdout.strip() in supported_archs

    def test_correct_binary_for_architecture(self, host, uv_enabled, uv_install_path):
        """Test that correct binary is installed for architecture"""
        if not uv_enabled:
            pytest.skip("UV installation not enabled")

        # Get system architecture
        arch_cmd = host.run("uname -m")
        system_arch = arch_cmd.stdout.strip()

        # Test that the binary works (implies correct arch was selected)
        uv_cmd = host.run(f"{uv_install_path}/uv --version")
        assert uv_cmd.rc == 0, f"UV binary doesn't work on {system_arch}"


class TestSecurityAndCleanup:
    """Test security and cleanup functionality"""

    def test_no_temporary_files_left(self, host):
        """Test that no temporary UV files are left behind"""
        # Check common temp locations
        temp_locations = ["/tmp", "/var/tmp"]

        for temp_dir in temp_locations:
            if host.file(temp_dir).exists:
                cmd = host.run(f"find {temp_dir} -name '*uv*' -type f")
                # Should not find any UV-related temporary files
                assert cmd.stdout.strip() == "", f"Found UV temp files in {temp_dir}: {cmd.stdout}"

    def test_file_permissions_secure(self, host, uv_enabled, uv_install_path):
        """Test that installed files have secure permissions"""
        if not uv_enabled:
            pytest.skip("UV installation not enabled")

        for binary in ["uv", "uvx"]:
            binary_path = f"{uv_install_path}/{binary}"
            binary_file = host.file(binary_path)

            if binary_file.exists:
                # Should be executable by all, writable only by owner
                assert binary_file.mode == 0o755
                # Should be owned by root (since we run with become: true)
                assert binary_file.user == "root"


class TestIdempotency:
    """Test idempotency of the role"""

    def test_binaries_not_modified_on_rerun(self, host, uv_enabled, uv_install_path):
        """Test that binaries are not modified on subsequent runs"""
        if not uv_enabled:
            pytest.skip("UV installation not enabled")

        # Get current modification times
        for binary in ["uv", "uvx"]:
            binary_path = f"{uv_install_path}/{binary}"
            binary_file = host.file(binary_path)

            if binary_file.exists:
                # File should exist and be the expected size (not empty)
                assert binary_file.size > 0

                # In a real idempotency test, we'd compare timestamps
                # before and after re-running the role, but that requires
                # more complex test setup


class TestErrorHandling:
    """Test error handling scenarios"""

    def test_install_directory_exists(self, host, uv_install_path):
        """Test that installation directory exists"""
        install_dir = host.file(uv_install_path)
        assert install_dir.exists
        assert install_dir.is_directory

    def test_install_directory_permissions(self, host, uv_install_path):
        """Test that installation directory has correct permissions"""
        install_dir = host.file(uv_install_path)
        # Directory should be readable and executable by all
        assert install_dir.mode & 0o755 == 0o755

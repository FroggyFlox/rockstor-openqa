"""
Module containing the definitions of the machines, test suites, and job groups
used by Rockstor openQA.
"""

from typing import Dict
import pathlib


FINAL_MACHINE_SETTINGS = [
    {
        "name": "64bit",
        "backend": "qemu",
        "settings": [
            {"key": "QEMUCPU", "value": "qemu64"},
            {"key": "WORKER_CLASS", "value": "qemu_x86_64"},
        ],
    },
    {
        "name": "64bit_tap",
        "backend": "qemu",
        "settings": [
            {"key": "QEMUCPU", "value": "qemu64"},
            {"key": "NICTYPE", "value": "tap"},
            {"key": "WORKER_CLASS", "value": "qemu_x86_64,tap"},
        ],
    },
]

RAID_LEVEL = ["single", "raid1", "raid10"]


def generate_final_test_suites() -> Dict:
    """
    Build all TEST SUITES by adding them one by one to the final_test_suites
    dictionary. A test suite can be:
      - manual: simply a dict defining name, and settings (see 'install_textmode')
      - semi-automatic: supportserver or webui test suite. Use the corresponding
        methods from the RockstorTestSuite() class for semi-automatically generation

    :return: Dict
    """
    final_test_suites = {}
    # Add install_textmode
    final_test_suites.update(
        {
            "install_textmode": {
                "settings": [
                    {"key": "DESKTOP", "value": "textmode"},
                    {"key": "INSTALLONLY", "value": "1"},
                ],
            },
        }
    )
    # Add base supportserver
    final_test_suites.update(
        RockstorTestSuite().new_supportserver_test_suite(
            name="supportserver_webui", first_boot=True
        )
    )
    # Add base webui
    final_test_suites.update(
        RockstorTestSuite().new_webui_test_suite(
            name="webui_navigation", first_boot=True
        )
    )
    # Add pools supportservers
    test_list = [
        RockstorTestSuite().new_supportserver_pool_test_suite(raid_level=raid_level)
        for raid_level in RAID_LEVEL
    ]
    for ts in test_list:
        final_test_suites.update(ts)
    # Add pools webuis
    test_list = [
        RockstorTestSuite().new_webui_pool_test_suite(raid_level=raid_level)
        for raid_level in RAID_LEVEL
    ]
    for ts in test_list:
        final_test_suites.update(ts)

    return final_test_suites


def generate_job_groups_map() -> Dict:
    """
    Reads all *.yaml files present in the 'job_groups' dir and builds
    a dictionary as {job_group_name: path-to-yaml-template}.

    :return: Dict
    """
    job_groups_dir = "job_groups"
    jb_gps_path = pathlib.Path(job_groups_dir)
    list_files = list(jb_gps_path.rglob("*.yaml"))
    jb_gps_map = {}
    for file in list_files:
        jb_gps_map[file.stem] = file
    return jb_gps_map


class RockstorTestSuite:
    first_boot: bool
    name: str
    raid_level: str

    # Define the number of disks required for Pools-related test suites.
    # Note that we use Btrfs min disk + 1 (OS disk). For Raid1, for instance,
    # we need 2 disks for raid1 + 1 OS disk = 3
    NUMDISKS_RAID_LEVEL = {
        "single": 2,
        "raid1": 3,
        "raid10": 5,
    }

    @staticmethod
    def new_supportserver_test_suite(name: str, first_boot: bool = False) -> Dict:
        """
        Builds a test suite destined to be used as a supportserver. It pre-defines a
        set of corresponding settings.

        :param name: name of test suite
        :param first_boot: set to True for a test suite booting off of a freshly
        installed Rockstor system, pre-first login. Set to False to boot off an already
        prepared system (network configured, Rockstor first login procedure completed).
        :return:
        """
        hdd_1 = (
            "%DISTRI%-%VERSION%-%FLAVOR%-%ARCH%-%BUILD%-non-efi.qcow2"
            if first_boot
            else "%DISTRI%-%VERSION%-%FLAVOR%-%ARCH%-%BUILD%-non-efi-prepared.qcow2"
        )
        base_dict = {
            f"{name}": {
                "settings": [
                    {"key": "ATACONTROLLER", "value": "ich9-ahci"},
                    {"key": "BOOTFROM", "value": "c"},
                    {"key": "HDD_1", "value": hdd_1},
                    {"key": "DESKTOP", "value": "textmode"},
                    {"key": "HOSTNAME", "value": "rockstorserver"},
                    {"key": "TAPDEV", "value": "tap0"},
                    {"key": "WORKER_CLASS", "value": "qemu_x86_64,tap"},
                    {"key": "QEMURAM", "value": "2048"},
                ]
            }
        }
        return base_dict

    def new_supportserver_pool_test_suite(self, raid_level: str) -> Dict:
        """
        Builds a test suite destined to be used as a support server for testing
        Pool-related operations. As a result, the number of disks, their size, and
        raid_level are customized.

        :param raid_level: MUST be one of the RAID_LEVEL constant
        :return:
        """
        name = f"{raid_level}_supportserver"
        out_dict = self.new_supportserver_test_suite(name=name)
        out_dict[name]["settings"].extend(
            [
                {"key": "NUMDISKS", "value": self.NUMDISKS_RAID_LEVEL[raid_level]},
                {"key": "HDDSIZEGB", "value": "10"},
            ]
        )
        return out_dict

    @staticmethod
    def new_webui_test_suite(name: str, first_boot: bool = False) -> Dict:
        """
        Builds a test suite destined to be used as webUI testing connecting to
        a supportserver.

        :param name: name of the test suite
        :param first_boot: set to True for a test suite booting off of a freshly
        installed Rockstor system, pre-first login. Set to False to boot off an already
        prepared system (network configured, Rocsktor first login procedure completed).
        :return:
        """
        hdd_1 = (
            "Leap15-4_KDE_Client.qcow2"
            if first_boot
            else "Leap15-4_KDE_Client-prepared.qcow2"
        )
        base_dict = {
            f"{name}": {
                "settings": [
                    {"key": "BOOTFROM", "value": "c"},
                    {"key": "HDD_1", "value": hdd_1},
                    {"key": "DESKTOP", "value": "kde"},
                    {"key": "HOSTNAME", "value": "client"},
                    {"key": "XRES", "value": "1280"},
                    {"key": "YRES", "value": "960"},
                    {"key": "TAPDEV", "value": "tap1"},
                    {"key": "WORKER_CLASS", "value": "qemu_x86_64,tap"},
                    {"key": "QEMURAM", "value": "4096"},
                ]
            }
        }
        return base_dict

    def new_webui_pool_test_suite(self, raid_level: str) -> Dict:
        """
        Builds a test suite destined to be used as webUI testing connecting to
        a supportserver, related to Pools operations.

        :param raid_level: MUST be one defined in RAID_LEVEL constant
        :return:
        """
        name = f"{raid_level}_webui"
        out_dict = self.new_webui_test_suite(name=name)
        return out_dict


FINAL_TEST_SUITES = generate_final_test_suites()
FINAL_JOB_GROUPS = generate_job_groups_map()

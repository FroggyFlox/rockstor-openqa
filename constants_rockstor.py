"""
Module containing the definitions of the machines, test suites, and job groups
used by Rockstor openQA.
"""

TEST_MACHINE_SETTINGS = [
    {
        "name": "testmachine",
        "backend": "qemu",
        "settings": [
            {"key": "HDDSIZEGB", "value": 10},
            {"key": "QEMUCPU", "value": "qemu64"},
            {"key": "VIRTIO_CONSOLE", "value": 1},
            {"key": "WORKER_CLASS", "value": "qemu_x86_64"},
        ],
    },
    {
        "name": "testmachine2",
        "backend": "qemu",
        "settings": [
            {"key": "HDDSIZEGB", "value": 20},
            {"key": "QEMUCPU", "value": "qemu64"},
            {"key": "VIRTIO_CONSOLE", "value": 1},
            {"key": "WORKER_CLASS", "value": "qemu_x86_64"},
        ],
    },
]

TEST_TEST_SUITES = {
    "test_suite_1": {
        "description": "description 1",
        "settings": [],
    },
    "test_suite_2": {
        "description": "description 2",
        "settings": [{"key": "VARIABLE1", "value": "VALUE1"}],
    },
}

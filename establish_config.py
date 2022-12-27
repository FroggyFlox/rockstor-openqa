#!/usr/bin/env python3

from openqa_client.client import OpenQA_Client

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

client = OpenQA_Client(server="openqa-server", scheme="http")
current_machines = client.openqa_request("GET", "machines")["Machines"]

for machine in TEST_MACHINE_SETTINGS:
    # Search whether a machine with the same name already exists
    matching_machine = [
        matching_dict
        for matching_dict in current_machines
        if matching_dict["name"] == machine["name"]
    ]
    # Delete any existing matching with the same name
    if len(matching_machine) > 0:
        matching_machine_id = matching_machine[0]["id"]
        client.openqa_request("DELETE", f"machines/{matching_machine_id}")
    # Define our machine
    client.openqa_request("POST", "machines", params=machine)

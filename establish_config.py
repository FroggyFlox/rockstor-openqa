#!/usr/bin/env python3

from openqa_client.client import OpenQA_Client

TEST_MACHINE_SETTINGS = {
    "name": "testmachine",
    "backend": "qemu",
    "settings": [
        {"key": "HDDSIZEGB", "value": 20},
        {"key": "QEMUCPU", "value": "qemu64"},
        {"key": "VIRTIO_CONSOLE", "value": 1},
        {"key": "WORKER_CLASS", "value": "qemu_x86_64"},
    ],
}

client = OpenQA_Client(server="openqa-server", scheme="http")
res = client.openqa_request("GET", "machines")["Machines"]
# client.openqa_request(
#     "POST", "machines", params=TEST_MACHINE_SETTINGS
# )
# Get id of the testmachine machine
matching_machine = [
    matching_dict for matching_dict in res if matching_dict["name"] == "testmachine"
]
if len(matching_machine) > 0:
    matching_machine_id = matching_machine[0]["id"]
    client.openqa_request("DELETE", f"machines/{matching_machine_id}")
client.openqa_request("POST", "machines", params=TEST_MACHINE_SETTINGS)
# print(res)

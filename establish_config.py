#!/usr/bin/env python3

from openqa_client.client import OpenQA_Client
from constants_rockstor import TEST_MACHINE_SETTINGS, TEST_TEST_SUITES


client = OpenQA_Client(server="openqa-server", scheme="http")


def establish_machines():
    current_machines = client.openqa_request("GET", "machines")["Machines"]
    for machine in TEST_MACHINE_SETTINGS:
        # Search whether a machine with the same name already exists
        matching_machine = [
            matching_dict
            for matching_dict in current_machines
            if matching_dict["name"] == machine["name"]
        ]
        # Delete any existing machine with the same name
        if len(matching_machine) > 0:
            matching_machine_id = matching_machine[0]["id"]
            client.openqa_request("DELETE", f"machines/{matching_machine_id}")
        # Define our machine
        client.openqa_request("POST", "machines", params=machine)


def establish_test_suites():
    current_test_suites = client.openqa_request("GET", "test_suites")["TestSuites"]
    for suite_name in TEST_TEST_SUITES:
        # Define parameters of the test suite to be created
        params = {**TEST_TEST_SUITES[suite_name], "name": suite_name}
        # Search whether a test suite with the same name already exists
        matching_test_suite = [
            matching_dict
            for matching_dict in current_test_suites
            if matching_dict["name"] == suite_name
        ]
        # Delete any existing test suite with the same name
        if len(matching_test_suite) > 0:
            matching_test_suite_id = matching_test_suite[0]["id"]
            client.openqa_request("DELETE", f"test_suites/{matching_test_suite_id}")
        # Define our test suite
        client.openqa_request("POST", "test_suites", params=params)


establish_machines()
establish_test_suites()

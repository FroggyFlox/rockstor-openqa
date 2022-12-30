#!/usr/bin/env python3

from openqa_client.client import OpenQA_Client
from constants_rockstor import (
    TEST_MACHINE_SETTINGS,
    FINAL_TEST_SUITES,
    FINAL_JOB_GROUPS,
)


client = OpenQA_Client(server="openqa-server", scheme="http")


def get_parent_groups(job_group_map: dict) -> list:
    list_parents = [
        job_group_map[job_group].parts[1:-1][0] for job_group in job_group_map
    ]
    return [*set(list_parents)]


def read_template_file(template_name: str) -> str:
    path = FINAL_JOB_GROUPS[template_name]
    with open(path, "r") as infile:
        template = infile.read()
    return template


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
    for suite_name in FINAL_TEST_SUITES:
        # Define parameters of the test suite to be created
        params = {**FINAL_TEST_SUITES[suite_name], "name": suite_name}
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


def establish_job_groups():
    # GET existing parent job groups and create if non-existent
    current_parent_groups = client.openqa_request("GET", "parent_groups")
    target_parent_groups = get_parent_groups(FINAL_JOB_GROUPS)
    # Create a dict to map parent_group name to their ID upon their creation
    # below so that we don't have to make another API call to retrieve that
    # information when we need to create the job_groups.
    target_parent_groups_map = {}
    for parent_group in target_parent_groups:
        matching_parent_group = [
            matching_dict
            for matching_dict in current_parent_groups
            if matching_dict["name"] == parent_group
        ]
        if len(matching_parent_group) > 0:
            # If matching parent_group already exists, simply add its ID
            # to the target_parent_groups_map dict
            matching_parent_group_id = matching_parent_group[0]["id"]
            target_parent_groups_map[parent_group] = matching_parent_group_id
            # client.openqa_request("DELETE", f"parent_groups/{matching_parent_group_id}")
        else:
            # Create the parent_group and save its id
            pg_id = client.openqa_request(
                "POST", "parent_groups", params={"name": parent_group}
            )
            target_parent_groups_map[parent_group] = pg_id["id"]

    # GET existing job groups and DELETE if name conflict
    current_job_groups = client.openqa_request("GET", "job_groups")
    for job_group in FINAL_JOB_GROUPS:
        # Define parameters of the job group to be created
        #  - read the template for the job group from file
        template = read_template_file(job_group)
        #  - get parent_group id
        parent_group = FINAL_JOB_GROUPS[job_group].parts[1:-1][0]
        pg_id = target_parent_groups_map[parent_group]
        params = {"name": job_group, "parent_id": pg_id, "template": template}
        # Search whether a job group with the same name already exists
        matching_job_group = [
            matching_dict
            for matching_dict in current_job_groups
            if matching_dict["name"] == job_group
        ]
        if len(matching_job_group) > 1:
            raise ValueError(
                f"Found {len(matching_job_group)} job groups named {job_group}."
            )
        elif len(matching_job_group) == 1:
            # UPDATE the job group that already exists
            print(f"A job group named {job_group} already exists... update it.")
            jb_grp_id = matching_job_group[0]["id"]
            client.openqa_request("PUT", f"job_groups/{jb_grp_id}", data=params)
        else:
            # Define our job group and save its id
            jb_grp_id = client.openqa_request("POST", "job_groups", data=params)["id"]
            print(f"Created the job group named {job_group}(id: {jb_grp_id}).")
        # Define the template
        params["schema"] = "JobTemplates-01.yaml"
        print(
            f"Define the template for the job group named {job_group}(id: {jb_grp_id})."
        )
        client.openqa_request(
            "POST",
            f"job_templates_scheduling/{jb_grp_id}",
            data=params,
        )


establish_machines()
establish_test_suites()
establish_job_groups()

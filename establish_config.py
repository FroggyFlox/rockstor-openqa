#!/usr/bin/env python3

from openqa_client.client import OpenQA_Client
from constants_rockstor import (
    FINAL_MACHINE_SETTINGS,
    FINAL_TEST_SUITES,
    FINAL_JOB_GROUPS,
    FINAL_PRODUCTS_SETTINGS,
)


client = OpenQA_Client(server="openqa-server", scheme="http")


def get_parent_groups(job_group_map: dict) -> list:
    """
    Builds a list of unique parent_groups from a Dict of pathlib.Path().

    :param job_group_map: Dict of {job_group_name: path-to-yaml-schedule}
    :return: List of unique parent_groups.
    """
    list_parents = [
        job_group_map[job_group].parts[1:-1][0] for job_group in job_group_map
    ]
    return [*set(list_parents)]


def read_template_file(template_name: str) -> str:
    """
    Read .yaml template file from path defined in FINAL_JOB_GROUPS.

    :param template_name: name of the job_group
    :return:
    """
    path = FINAL_JOB_GROUPS[template_name]
    with open(path, "r") as infile:
        template = infile.read()
    return template


def establish_machines():
    """
    Ensures the MACHINES defined on the openQA server matches the definitions
    in the FINAL_MACHINE_SETTINGS constant. All machine names must be unique.
    As a result, if a machine of the same name exists, we update its definition
    on the server based on the definition present in FINAL_MACHINE_SETTINGS.
    All settings NOT defined in FINAL_MACHINE_SETTINGS will be removed by the
    process. If no machine with the same name exists, simply create it.

    :return:
    """
    current_machines = client.openqa_request("GET", "machines")["Machines"]
    for machine in FINAL_MACHINE_SETTINGS:
        # Search whether a machine with the same name already exists
        matching_machine = [
            matching_dict
            for matching_dict in current_machines
            if matching_dict["name"] == machine["name"]
        ]
        if len(matching_machine) > 1:
            raise ValueError(
                f"More than 1 machine found with the name {machine['name']}"
            )
        elif len(matching_machine) == 1:
            print(f"A machine named {machine['name']} already exists... update it.")
            matching_machine_id = matching_machine[0]["id"]
            client.openqa_request(
                "PUT", f"machines/{matching_machine_id}", params=machine
            )
        else:
            client.openqa_request("POST", "machines", params=machine)
            print(f"Created the machine named {machine['name']}.")


def equal_in_db(target_dict, db_dict) -> bool:
    """
    Check whether the target_dict dictionary defines the same product
     as db_dict given the uniqueness constraints applied to products/mediums.
    """
    # products have a UNIQUE (distri, version, arch, flavor) constraint
    # applied in the DB
    return (
        db_dict.get("distri") == target_dict["distri"]
        and db_dict.get("version") == target_dict["version"]
        and db_dict.get("flavor") == target_dict["flavor"]
        and db_dict.get("arch") == target_dict["arch"]
    )


def establish_products():
    """
    Ensures the MEDIUMS/PRODUCTS defined on the openQA server matches the definitions
    in the FINAL_PRODUCTS_SETTINGS constant.
    All mediums/products must represent a unique combination of distri, version,
    flavor, and arch, so we first check for that in the server's database. If the
    product/medium already exists, we update its definition
    on the server based on the definition present in FINAL_PRODUCTS_SETTINGS.
    All settings NOT defined in FINAL_PRODUCTS_SETTINGS will be removed by the
    process. If the desired product/medium does not already exist, simply create it.
    Note the use of 'data' instead of 'params' here due to our need to send
    application/x-www-form-urlencoded data because of the '*' used for version
    (see https://github.com/os-autoinst/openQA-python-client/pull/5 for details).

    :return:
    """
    current_products = client.openqa_request("GET", "products")["Products"]
    for p in FINAL_PRODUCTS_SETTINGS:
        product_string = f"{p['distri']}-{p['version']}-{p['flavor']}-{p['arch']}"
        # Search whether a product with the same name already exists
        matching_product = [
            matching_dict
            for matching_dict in current_products
            if equal_in_db(p, matching_dict)
        ]

        if len(matching_product) > 1:
            raise ValueError(f"More than 1 product found matching {product_string}")
        elif len(matching_product) == 1:
            print(f"The product {product_string} already exists... update it.")
            matching_product_id = matching_product[0]["id"]
            client.openqa_request("PUT", f"products/{matching_product_id}", data=p)
        else:
            client.openqa_request("POST", "products", data=p)
            print(f"Created the product {product_string}.")


def establish_test_suites():
    """
    Ensures the TEST SUITES defined on the openQA server matches the definitions
    in the FINAL_TEST_SUITES constant. All test suite names must be unique.
    As a result, if a test suite of the same name exists, we update its definition
    on the server based on the definition present in FINAL_TEST_SUITES.
    All settings NOT defined in FINAL_TEST_SUITES will be removed by the
    process. If no test suite with the same name exists, simply create it.

    :return:
    """
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
        if len(matching_test_suite) > 1:
            raise ValueError(f"More than 1 test suite found with the name {suite_name}")
        elif len(matching_test_suite) == 1:
            print(f"A test suite named {suite_name} already exists... update it.")
            matching_test_suite_id = matching_test_suite[0]["id"]
            client.openqa_request(
                "PUT", f"test_suites/{matching_test_suite_id}", params=params
            )
        else:
            client.openqa_request("POST", "test_suites", params=params)
            print(f"Created the test suite named {suite_name}.")


def establish_job_groups():
    """
    Ensures the JOB GROUPS defined on the openQA server matches the definitions
    in the FINAL_JOB_GROUPS constant. All job group names must be unique.
    As a result, if a job group of the same name exists, we update its definition
    on the server based on the definition present in FINAL_JOB_GROUPS.
    All settings NOT defined in FINAL_JOB_GROUPS will be removed by the
    process. If no job group with the same name exists, simply create it.

    :return:
    """
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


print("############# Begin establishing MACHINES #############")
establish_machines()
print("\n")
print("############# Begin establishing PRODUCTS #############")
establish_products()
print("\n")
print("############# Begin establishing TEST SUITES #############")
establish_test_suites()
print("\n")
print(f"############# Begin establishing JOB GROUPS #############")
establish_job_groups()

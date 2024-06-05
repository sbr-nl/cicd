"""
Here we overwrite default packages with specific yet to build versions.
We enter this script in <Project_Root>/tmp
The triggering taxonomy has been checked out and build.
For each entry in the testconfig.yaml which has the same branchname as the current,we can skip this step
"""
import yaml
import sys
import os
import subprocess

if len(sys.argv) < 5:
    print("Usage: test_config.py <config.file> <local_taxonomy_dir> <local_instance_dir> <test_branch_name>")
    print("Not enough arguments given. Goodbye!")
    exit()
else:
    filename = sys.argv[1]
    local_taxonomy_dir = sys.argv[2]
    local_instance_dir = sys.argv[3]
    test_branch = sys.argv[4]

print(f"{local_taxonomy_dir} - {local_instance_dir} - {filename}")

try:
    with open(filename) as f:
        try:
            repositories = yaml.safe_load(f)
        except yaml.YAMLError as exc:
            print(exc)
            exit(1)
except FileNotFoundError:
    print(f"File {filename} not found!")
    exit(1)

for repo in repositories["repositories"]:
    print(repo)
    branch = repo.get("branch")
    name = repo.get("name")
    package = repo.get("package")
    print(f"Taxonomie {name} uit branch {branch} word als {package} gegenereerd")
    if branch == test_branch:
        print("Skipping {name}, same branch")
        continue
    print(f"Cloning {name} with branch: {branch}")
    git_cmd = f"git clone --branch {branch} {local_taxonomy_dir}/{name}"
    print(git_cmd)
    subprocess.run(git_cmd, shell=True)
    rm_cmd = f"rm ../local-test/taxonomies/{test_branch}/{package}.zip 2>/dev/null"
    subprocess.run(rm_cmd, shell=True)
    create_package = f"cd {name}; pwd; zip -r ../../local-test/taxonomies/{test_branch}/{package} {package}; cd .."
    print(create_package)
    subprocess.run(create_package, shell=True)
    print(f"{os.getcwd()}")
exit()



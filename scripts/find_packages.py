import sys
import glob
import os.path
import yaml
import subprocess


if len(sys.argv) != 3:
    print("No directory given. Goodbye!")
    exit()

if os.path.isfile("_tax/testconfig.yaml"):
    owner = sys.argv[2]
    with open("_tax/testconfig.yaml") as f:
        try:
            repositories = yaml.safe_load(f)
            packages = []
            # subprocess.run(["mkdir", "tst"])
            for repo in repositories["repositories"]:
                branch = repo.get("branch")
                name = repo.get("name")
                package = repo.get("package")
                git_cmd = f"/usr/bin/git clone https://github.com/{owner}/{name}.git --branch {branch}"
                subprocess.run(git_cmd)
                package_cmd = f"cd {name} \
                zip -qr ../{package} {package} && \
                cd .. "
                subprocess.run(package_cmd)
                packages.append(f"{package}.zip")
        except yaml.YAMLError as exc:
            print(exc)
            exit(1)
else:
    pattern = "%s/*zip" % sys.argv[1]
    packages = glob.glob(pattern)
print("|".join(packages))

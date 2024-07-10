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
            subprocess.run(["mkdir", "_tmp"])
            for repo in repositories["repositories"]:
                branch = repo.get("branch")
                name = repo.get("name")
                package = repo.get("package")
                git_cmd = f"cd _tmp && \
                git clone https://github.com/{owner}/{name} --branch {branch} && \
                cd {name} \
                zip -qr ../{package} {package} && \
                cd ../.."
                subprocess.run(git_cmd, shell=True)
                packages.append(f"_tmp/{package}.zip")
            # print(subprocess.run("pwd && ls -l"))
        except yaml.YAMLError as exc:
            print(exc)
            exit(1)
else:
    pattern = "%s/*zip" % sys.argv[1]
    packages = glob.glob(pattern)
print("|".join(packages))

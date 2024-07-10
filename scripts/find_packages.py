import sys
import glob
import os.path
import yaml
import subprocess


if len(sys.argv) != 2:
    print("No directory given. Goodbye!")
    exit()

if os.path.isfile("_tax/testconfig.yaml"):
    with open("_tax/testconfig.yaml") as f:
        try:
            repositories = yaml.safe_load(f)
            packages = []
            subprocess.run(["mkdir", "_tmp"])
            for repo in repositories["repositories"]:
                branch = repo.get("branch")
                name = repo.get("name")
                package = repo.get("package")
                git_cmd = f"cd _tmp; git clone {name} --branche {branch}; cd .."
                subprocess.run(git_cmd, shell=True)
                package_cmd = f"cd _tmp; zip -r {package} {name}{package}; cd .."
                subprocess.run(package_cmd, shell=True)
                packages.append(f"public/taxonomies/{branch}/{package}.zip")
            print(subprocess.run("ls -l _tmp"))
        except yaml.YAMLError as exc:
            print(exc)
            exit(1)
else:
    pattern = "%s/*zip" % sys.argv[1]
    packages = glob.glob(pattern)
print("|".join(packages))

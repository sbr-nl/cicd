import sys
import glob
import os
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
                git_cmd = ["git", "clone",  f"https://github.com/{owner}/{name}.git", "--branch", branch]
                subprocess.run(git_cmd)

                os.chdir(name)
                # package_cmd = ["cd",  name, " && ", "zip",  "-r",  f"../{package}",  package, " && ", "cd",  ".."]
                package_cmd = ["zip", "-qr", f"../_tax/{package}", package]
                outp = subprocess.run(package_cmd)
                os.chdir("..")
        except yaml.YAMLError as exc:
            print(exc)
            exit(1)
    pattern = "_tax/*zip"
    packages = glob.glob(pattern)
    print("==")
    print(packages)
    print("==")
    print(os.getcwd())
    subprocess.run(["ls", "-al", "_tax"])
    print(outp)
else:
    pattern = "%s/*zip" % sys.argv[1]
    packages = glob.glob(pattern)
print("|".join(packages))

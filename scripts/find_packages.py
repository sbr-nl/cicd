import sys
import glob
import os.path
import yaml


if len(sys.argv) != 2:
    print("No directory given. Goodbye!")
    exit()

if os.path.isfile("testconfig.yaml"):
    print("Found testconfig.yaml")
    with open("testconfig.yaml") as f:
        try:
            repositories = yaml.safe_load(f)
        except yaml.YAMLError as exc:
            print(exc)
            exit(1)
    print(repositories)
else:
    pattern = "%s/*zip" % sys.argv[1]
    packages = glob.glob(pattern)
print("|".join(packages))

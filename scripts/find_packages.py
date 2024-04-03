import sys
import glob

if len(sys.argv) != 2:
    print("No directory given. Goodbye!")
    exit()

pattern = "%s/*zip" % sys.argv[1]
packages = glob.glob(pattern)
print("|".join(packages))

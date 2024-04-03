import sys
import glob

if len(sys.argv) != 2:
    print("No directory given. Goodbye!")
    exit()

pattern = "%s/*" % sys.argv[1]
instances = glob.glob(pattern)
print("|".join(instances))

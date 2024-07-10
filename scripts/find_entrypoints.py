import xml.etree.ElementTree as ET
import sys
if len(sys.argv) != 2:
    print("No package given. Goodbye!")
    exit()

tax_name = sys.argv[1]
print(f"tax: {tax_name}")
ns = {"tp": "http://xbrl.org/2016/taxonomy-package"}
doc = ET.parse("%s/META-INF/taxonomyPackage.xml" % tax_name)
ep_list = []
for ep in doc.findall("tp:entryPoints/tp:entryPoint/tp:entryPointDocument", ns):
    ep_list.append(ep.get('href'))
print("|".join(ep_list))

#!/bin/bash

# Dit script doet een workflow na.
# aanroepen vanuit de root van je project. Dus:
# ./scripts/test.sh <argumenten>

if test ! -f ./scripts/config.sh; then
  echo "Maak een configuratie aan (zie scripts/config.sh.sample)"
  exit
fi
source ./scripts/config.sh

while [ $# -gt 0 ]; do
  case "$1" in
    --branch*|-b*)
      if [[ "$1" != *=* ]]; then shift; fi # Value is next arg if no `=`
      branch="${1#*=}"
      ;;
    --repo*|-r*)
      if [[ "$1" != *=* ]]; then shift; fi
      repo_name="${1#*=}"
      ;;
    --tax*|-t*)
      if [[ "$1" != *=* ]]; then shift; fi
      taxonomy_name="${1#*=}"
      ;;
    --help*|-h*)
      echo ""
      echo Usage:
      echo "scripts/test.sh [arguments]"
      echo ""
      echo arguments:
      echo "-b | --branch  naam van de branch waarin we moeten werken"
      echo "               default: main"
      echo "-r | --repo    naam van de repository (taxonomie) die getest moet worden"
      echo "               default: jenv-taxonomie"
      echo "-t | --taxo    naam van het taxonomy package (minus .zip)"
      echo "               default: jenv_taxonomy_2024"
      echo "je mag zowel spaties als = gebruiken als scheidingsteken"
      echo "dus ./scripts/test.sh --repo=rj --taxo=rj_taxonomy_2024 --branch=develop"
      echo "is gelijk aan:"
      echo "dus ./scripts/test.sh -r rj -t rj_taxonomy_2024 -b develop"
      echo "geen enkel argument mag spaties bevatten"
      echo ""
      echo "bijv: ./scripts/test.sh --repo rj --taxo rj_taxonomy_2024 --branch develop"
      exit 0
      ;;
    *)
      >&2 printf "Error: Invalid argument\n"
      exit 1
      ;;
  esac
  shift
done

branch="${branch:-main}"
repo_name="${repo_name:-jenv-taxonomie}"
taxonomy_name="${taxonomy_name:-jenv_taxonomy_2024}"

repository="${local_taxonomy_dir}/${repo_name}"
# probably add
domain="jenv"


mkdir -p public/taxonomies/${branch}/views # just to be sure
mkdir -p local-test/taxonomies/${branch} # just to be sure

# remove package which we will rebuild
cp -rup public/taxonomies/${branch} local-test/taxonomies/
rm local-test/taxonomies/${branch}/${taxonomy_name}.zip 2>/dev/null

# create a new taxonomy package for given taxonomy
mkdir -p tmp
cd tmp || exit 1

echo "Cloning ${repository} with branch: ${branch}"
git clone --branch "${branch}" "${repository}"
cd "${repo_name}" || exit 1
echo "=+="
echo "Creating taxonomy package"

zip -r ../../local-test/taxonomies/"${branch}"/"${taxonomy_name}" "${taxonomy_name}"
# 22 may 2024 add the capability to combine different-versions of taxonomies.
if test -f "testconfig.yaml"; then
  cd ..  # get out of the 'domain' directory
  echo -e "\n=+=+=\n\n update package-versions!"
  python ../scripts/test_config.py `pwd`/"${repo_name}"/testconfig.yaml "${local_taxonomy_dir}" "${local_instance_dir}" "${branch}"
  cd ./"${repo_name}" || exit 1  # Hieronder gaan we rucksichtlos twee directories up.
  echo -e  "\n=+=+="
fi

cd ../..  # get back to where you once belonged

# Als wij de eerste zijn die dit package maken, zet het in git.
if test ! -f "public/taxonomies/${branch}/${taxonomy_name}.zip"; then
  echo adding new taxonomy package to this repository
  cp local-test/taxonomies/"${branch}"/"${taxonomy_name}".zip public/taxonomies/"${branch}"/
  git add public/taxonomies/"${branch}"/
  git commit -m "New taxonomy package in branch ${branch}"
fi

echo ""
echo "=-="
echo "gather entrypoints from the requested taxonomy"
echo "see which other taxonomies can be loaded"
echo "find test instances"

# shellcheck disable=SC2006
ep=$(python ./scripts/find_entrypoints.py tmp/"${repo_name}"/"${taxonomy_name}")
packages=$(python ./scripts/find_packages.py local-test/taxonomies/"${branch}")
instances=$(python ./scripts/find_instances.py tmp/"${repo_name}"/instances)

echo ""
echo "=-="
echo "Testing entrypoint(s): ${ep}"
echo "With packages: ${packages}"
echo ""
arelleCmdLine --packages "${packages}"  --validate --file "${ep}" --logLevel=warning --logLevelFilter=!.*message

# Create html of the presentation and dimensional linkbases
IFS_SAVE="$IFS"   # field-seperator to |
IFS='|'
for ep_ in $ep; do
    filename=$(basename "${ep_}" .xsd)
    echo "=-="
    echo "Creating html: ${filename} "
    arelleCmdLine --packages "${packages}" --file "${ep_}" \
                  --pre="public/taxonomies/${branch}/views/${filename}-presentation-nl.html" \
                  --dim="public/taxonomies/${branch}/views/${filename}-dimensions-nl.html" \
                  --labelLang=nl
done
IFS="$IFS_SAVE"


if test ! "${instances}" == ""; then
  echo ""
  echo "=-="
  echo "Testing instance(s): ${instances}"
  echo "With packages: ${packages}"
  echo ""
  arelleCmdLine --packages "${packages}"  --validate --file "${instances}"
else
  echo No instances to be tested. Goodbye
fi

python ./scripts/html_index.py > public/index.html

echo ""
echo "=-="
echo "Cleaning up the mess"
rm -rf tmp
rm -rf local-test
echo ""


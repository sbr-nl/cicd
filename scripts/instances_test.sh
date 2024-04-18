#!/bin/bash

# Dit script doet een workflow na.
# aanroepen vanuit de root van je project. Dus:
# ./scripts/instances_test.sh <argumenten>

if test ! -f ./scripts/config.sh; then
  echo "Maak een configuratie aan (zie scripts/config.sh.sample)"
  exit
fi
source ./scripts/config.sh
if [ "${local_instance_dir}" == "" ]; then
  echo "Geef een waarde voor "local_instance_dir" op in config.sh"
  exit
fi

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
    --instance|-i*)
      if [[ "$1" != *=* ]]; then shift; fi
      report_name="${1#*=}"
      ;;
    --help*|-h*)
      echo ""
      echo Usage:
      echo "scripts/instance_test.sh [arguments]"
      echo ""
      echo arguments:
      echo "-b | --branch   naam van de branch waarin we moeten werken"
      echo "                default: main"
      echo "-r | --repo     naam van de repository (taxonomie) die getest moet worden"
      echo "                default: kvk-ixbrl-voorbeelden"
      echo "-i | --instance [optioneel], test alleen dit report bijv: nba-middelgroot-nl-inrichtingsjaarrekening-2023"
      echo "                je kan ook '-i middel' meegeven, alle reports met 'middel' in de naam worden dan getest."
      echo "                default: alles "
      echo "je mag zowel spaties als = gebruiken als scheidingsteken"
      echo "dus ./scripts/instances_test.sh --repo ocw-voorbeelden --branch=develop --instance=gaap"
      echo "is gelijk aan:"
      echo "dus ./scripts/instances_test.sh -r ander_dan_kvk-voorbeelden -b develop -i gaap"
      echo "geen enkel argument mag spaties bevatten"
      echo ""
      echo "bijv: ./scripts/instance_test.sh --branch=develop"
      exit 0
      ;;
    *)
      >&2 printf "Error: Invalid argument\n"
      exit 1
      ;;
  esac
  shift
done

branch="${branch:-instances}"
repo_name="${repo_name:-kvk-ixbrl-voorbeelden}"
repository="${local_instance_dir}/${repo_name}"
report_name="${report_name:-}"

mkdir -p public/instances/"${branch}"/views

# Create and fill a temporary directory where we will perform the (integratiion) tests
mkdir -p local-test/taxonomies/${branch}
mkdir -p local-test/instances/${branch}/views
cp -rup public/taxonomies/${branch} local-test/taxonomies/
rm -rf local-test/instances/"${branch}"/*zip  # Create, don't update!

mkdir -p tmp
cd tmp || exit 1

echo "Cloning ${repository} with branch: ${branch}"
rm -rf "${repo_name}"
git clone --branch "${branch}" "${repository}"
cd "${repo_name}" || exit 1
echo "=+="
echo "Creating reportpackages:"
count=0
for dir in */
do
  dir=${dir%*/}      # remove the trailing "/"
  echo "  - ${dir}.zip"
  zip -rq ../../local-test/instances/"${branch}"/"${dir}" "${dir}"
done
echo ""

cd ../..

packages=$(python ./scripts/find_packages.py local-test/taxonomies/"${branch}")

for report in local-test/instances/"${branch}"/*zip
do
  if [ "${report_name}" == "" ] || [[ "${report}" =~ ${report_name} ]] ; then
    echo "${report} (${report_name})"
    rm arelle.log 2>/dev/null
    echo "Running arelle, output to terminal:"
    echo "=================================="
    # We run this first for hte output to the user. It's polite.
    arelleCmdLine --packages "${packages}"  --validate --file "${report}" --logLevel=warning --logLevelFilter=!.*message
    # Then we run it again, this time with logLevel=warning and an output file
    arelleCmdLine --packages "${packages}"  --validate --file "${report}" --logLevelFilter=!.*message --logLevel=warning --logFile=arelle.log
    if [ -s arelle.log ]; then
      echo "Houston we have a problem."
      echo "not publishin reportpackage."
    else
      cat arelle.log
      zipname=$(basename "${report}")
      file=$(basename "${report}" .zip)
      echo "Looks good! 'publishing' ${zipname}"
      cp "${report}" "public/instances/${branch}/"
      echo "Creating iXBRL inline view"
      rm public/instances/"${branch}"/views/"${file}"_viewer.html 2>/dev/null
      arelleCmdLine --packages "${packages}" \
                    --file "${report}" \
                    --plugins iXBRLViewerPlugin \
                    --save-viewer public/instances/"${branch}"/views/"${file}"_viewer.html \
                    --viewer-url https://github.com/Arelle/ixbrl-viewer/releases/download/1.4.22/ixbrlviewer.js
      if [ -s public/instances/"${branch}"/views/"${file}"_viewer.html ]; then
        echo "Created inline viewer for ${file}"
      else
        echo "No inline view created"
      fi
    fi
    echo ""
  else
    echo "== skipping: ${report}"
  fi
done
# Create html-index of 'public/'
python ./scripts/html_index.py > public/index.html

echo ""
echo "=-="
echo "Cleaning up the mess"
rm -rf tmp
rm -rf local-test
echo ""

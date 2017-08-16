#!/bin/sh
help () { printf "
*******************
get-next-version.sh
*******************
gets the next semver versioning of the current folder based on the version
in the git tag list. version should be in format x.y.z where x is the major
version, y is the minor version and z is the patch version.

eg. to add a 1.0.3 tag, run 'git tag 1.0.3'

options:
\t-q --quiet          : suppresses debug prints
\t-h --help           : prints this text

usage:
\t./get-next-version.sh <version_type> [...options]
\t<version_type>:
\t\tmajor: {major|maj|m1}
\t\tminor: {minor|min|m2}
\t\tpatch: {patch|ptc|p} (DEFAULT)

examples:
\t./get-next-version.sh maj : bumps the major version (1.0.0 > 2.0.0)
\t./get-next-version.sh min : bumps the minor version (1.0.0 > 1.1.0)
\t./get-next-version.sh patch : bumps the patch version (1.0.0 > 1.0.1)
\t./get-next-version.sh -q : bumps the patch version (1.0.0 > 1.0.1) w/o output

";
}

get_current_version () {
  CURRENT_VERSION=$(./get-latest.sh);
  if [[ $? != 0 ]]; then
    printf "ERROR: could not find a git tag that resembles a semver version (x.y.z).\n"
    printf "Run './get-next-version.sh -h' for more info. Exiting with status code 1.\n\n";
    exit 1;
  fi;
  LATEST_MAJOR_VERSION=$(printf "$CURRENT_VERSION" | cut -d. -f1);
  LATEST_MINOR_VERSION=$(printf "$CURRENT_VERSION" | cut -d. -f2);
  LATEST_PATCH_VERSION=$(printf "$CURRENT_VERSION" | cut -d. -f3);
}

get_next_version () {
  VERSION_TYPE_TO_UPDATE=$1;
  NEXT_MAJOR_VERSION=$LATEST_MAJOR_VERSION;
  NEXT_MINOR_VERSION=$LATEST_MINOR_VERSION;
  NEXT_PATCH_VERSION=$LATEST_PATCH_VERSION;
  case "$VERSION_TYPE_TO_UPDATE" in
  "major"|"maj"|"m1")
    ((NEXT_MAJOR_VERSION++));
    ;;
  "minor"|"min"|"m2")
    ((NEXT_MINOR_VERSION++));
    ;;
  "patch"|"ptc"|"p"|*)
    ((NEXT_PATCH_VERSION++));
    ;;
  esac
  NEXT_VERSION="${NEXT_MAJOR_VERSION}.${NEXT_MINOR_VERSION}.${NEXT_PATCH_VERSION}";
}

if [[ $* == *-h* ]] || [[ $* == *--help* ]]; then help; exit 1; fi;
if [[ $* == *-q* ]] || [[ $* == *--quiet* ]]; then exec 6>&1; exec > /dev/null; fi;

get_current_version;
printf "CURRENT_VERSION: ${CURRENT_VERSION}\n";
printf "MAJOR:           ${LATEST_MAJOR_VERSION}\n";
printf "MINOR:           ${LATEST_MINOR_VERSION}\n";
printf "PATCH:           ${LATEST_PATCH_VERSION}\n";

get_next_version $1;
printf "NEXT_VERSION:    ${NEXT_VERSION}\n";
printf "MAJOR:           ${NEXT_MAJOR_VERSION}\n";
printf "MINOR:           ${NEXT_MINOR_VERSION}\n";
printf "PATCH:           ${NEXT_PATCH_VERSION}\n";

printf "VERSION UPGRADE: ${CURRENT_VERSION} > ";

if [[ $* == *-q* ]] || [[ $* == *--quiet* ]]; then exec 1>&6 6>&-; fi;

printf "${NEXT_VERSION}\n";
exit 0;

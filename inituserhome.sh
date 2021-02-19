#!/usr/bin/env sh
set -e # Exit on failure

HOMEDIRS="/homedirs"
DOSSIER="/opt/dossier/dossier.json"

usage() {
    echo "Usage: $0 [-v HOMEDIR_VOLUME] [-f DOSSIER_FILE]" 1>&2
}

while getopts "f:v:" opt ; do
    case "${opt}" in
	v)
	    HOMEDIRS=${OPTARG}
	    ;;
	f)
	    DOSSIER=${OPTARG}
	    ;;
	*)
	    usage
	    ;;
    esac
done
shift $((OPTIND-1))

UNAME=$(jq -r .token.data.uid < ${DOSSIER})
UID=$(jq -r .token.data.uidNumber < ${DOSSIER})

# We have to do something a little silly here, because jq reports "null" for
#  a missing value, and it's possible, if unlikely, that a username could
#  indeed be "null".
user_is_actually_named_null=0
if [ ${UNAME} == "null" ]; then
    grep -q '\"uid\":[[:space:]]*\"null\"' ${DOSSIER}
    rc=$?
    if [ ${rc} -eq 0]; then
	user_is_actually_named_null=1
    fi
fi
insufficient=0
if [ "${UNAME}" == "null" ] && [ ${user_is_actually_named_null} -ne 1 ]; then
    insufficient=1
fi
if [ "${UID}" == "" ] || [ ${UID} == "null" ] || [ ${UNAME} == "" ]; then
    insufficient=1
fi
if [ ${insufficient} -eq 1 ]; then
    echo "Need uid/username; have ${UID}/${UNAME}" 1>&2
    exit 1
fi

# We have what we need to proceed.

HOME="${HOMEDIRS}/${UNAME}"

if [ -d "${HOME}" ]; then
    # We already have a directory there.  Is it owned by the right uid/gid?
    h_uid=$(ls -nd | awk '{print $3}')
    h_gid=$(ls -nd | awk '{print $4}')
    if [ ${h_uid} -eq ${UID} ] && [ ${h_gid} -eq ${UID} ]; then
	exit 0 # Nothing to do; all present and correct
    fi
    echo "${HOME} exists but owned by ${h_uid}:${h_gid} not ${UID}:${UID}" 1>&2
    exit 1
fi
# We don't have it, so make it.
mkdir "${HOME}"
chown ${UID}:${UID} "${HOME}"

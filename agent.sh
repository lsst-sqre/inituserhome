# This is a fragment that will be sourced by our filesystem-manipulating
#  tasks.  Since they have common options parsing and validation, we will
#  just share them
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

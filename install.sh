#!/usr/bin/env bash

set -euo pipefail  # Safety net

#Variables and Fucntions
handle_error() {
    local msg="$1"
    printf "Error: %s\n" "${msg}"
    printf "Please proceed to manually installing the script in your /bin of choose and making it executable\n"
    printf "Aborting install...\n"
    printf "Exiting...\n"
    exit 1
}

check_dir() {
    local dir=$1
    printf "Checking for ${dir} existence... \n"
    if [ ! -d "${dir}" ]; then
        printf "${dir} was not created! Trying to create...\n"
        if ! mkdir -p "${dir}"; then
            handle_error "Failed to create folder ${dir}!"
        fi
    	printf "Directory ${dir} was created!\n"
    	return 0
    fi
    printf "Directory ${dir} exists!\n"
    return 0
}

USR_LOCAL="${HOME}/.local/bin"
CMD_DIR="${HOME}/.user-commands/"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#Create .user-comannds/cldocf inside .usr-cmds

check_dir "${CMD_DIR}"

#Check file existence
if [ ! -f "${SCRIPT_DIR}/cldocf" ]; then 
   handle_error "Source file missing"
fi

#Copy cldocf to .user-comannds

if ! cp "${SCRIPT_DIR}/cldocf" "${CMD_DIR}/cldocf"; then
    handle_error "Failed to copy '${SCRIPT_DIR}/cldocf' to ${CMD_DIR}"
fi

#Check for the existense of .local/bin/ if not create

check_dir "${USR_LOCAL}"

#Create Symlink and make executable

printf "Trying to create symlink in ${USR_LOCAL} and making it executable"

if ! ln -sf "${CMD_DIR}/cldocf" "${USR_LOCAL}/cldocf"; then
   handle_error "Failed to create symlink in ${USR_LOCAL}"
fi

if ! chmod +x "${USR_LOCAL}/cldocf"; then
    handle_error "Failed to make ${USR_LOCAL}/cldocf executable"
fi
printf "Installation successful!\n"
printf "You can now delete the cloned folder if you'd like...\n"
printf "Thank you for installing cldocf as CLI! :)\n"

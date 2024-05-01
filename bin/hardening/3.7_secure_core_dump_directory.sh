#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 3.5 Ensure the Group Is Set Correctly on Apache Directories and Files
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure the Group Is Set Correctly on Apache Directories and Files"

USER='root'
PERMISSIONS='750'
PERMISSIONSOK='750 700'

# This function will be called if the script status is on enabled / audit mode
audit() {
	CORE_DUMP_DIRECTORY=$(grep -R "^CoreDumpDirectory" /etc/apache2/ | sed "s/CoreDumpDirectory//" | cut -f 2 -d":")
	if [ -z "$CORE_DUMP_DIRECTORY" ]; then
		ok "CoreDumpDirectory is not defined in apache conf files"
	else
		APACHE_GROUP=$($APACHE2CTLBIN  -t -D DUMP_RUN_CFG | grep "^Group:" | sed -E 's/.*name="([^"]+)".*/\1/')

		has_file_correct_ownership "$CORE_DUMP_DIRECTORY" "$USER" "$APACHE_GROUP"
		if [ "$FNRET" = 0 ]; then
			ok "$CORE_DUMP_DIRECTORY has correct ownership"
		else
			crit "$CORE_DUMP_DIRECTORY ownership was not set to $USER:$APACHE_GROUP"
		fi

		has_file_one_of_permissions "$CORE_DUMP_DIRECTORY" "$PERMISSIONSOK"
        if [ "$FNRET" = 0 ]; then
            ok "$CORE_DUMP_DIRECTORY has correct permissions"
        else
            crit "$CORE_DUMP_DIRECTORY permissions were not set to $PERMISSIONS"
        fi
	fi
}


# This function will check config parameters required
check_config() {
    :
}

# Source Root Dir Parameter
if [ -r /etc/default/apache2-cis-hardening ]; then
    # shellcheck source=../../debian/default
    . /etc/default/apache2-cis-hardening
fi
if [ -z "$CIS_LIB_DIR" ]; then
    echo "There is no /etc/default/apache2-cis-hardening file nor cis-hardening directory in current environment."
    echo "Cannot source CIS_LIB_DIR variable, aborting."
    exit 128
fi

# Main function, will call the proper functions given the configuration (audit, enabled, disabled)
if [ -r "${CIS_LIB_DIR}"/main.sh ]; then
    # shellcheck source=../../lib/main.sh
    . "${CIS_LIB_DIR}"/main.sh
else
    echo "Cannot find main.sh, have you correctly defined your root directory? Current value is $CIS_LIB_DIR in /etc/default/apache2-cis-hardening"
    exit 128
fi

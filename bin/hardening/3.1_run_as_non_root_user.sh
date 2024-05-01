#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 3.1 Ensure the Apache Web Server Runs As a Non-Root User
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure the Apache Web Server Runs As a Non-Root User"

# This function will be called if the script status is on enabled / audit mode
audit() {
	RESULT=$($APACHE2CTLBIN -t -D DUMP_RUN_CFG | grep "User: name=\"$APACHE_USER\"")
	if [ -n "$RESULT" ]; then
		ok "Apache run with non-root user $APACHE_USER"
	else
		crit "Apache doesn't run with user $APACHE_USER"
	fi

	if $APACHE2CTLBIN -t -D DUMP_RUN_CFG | grep "Group: name=\"$APACHE_GROUP\""; then
		ok "Apache run with non-root group $APACHE_GROUP"
	else
		crit "Apache doesn't run with group $APACHE_GROUP"
	fi

	UID_MIN=$(grep '^UID_MIN' /etc/login.defs | sed 's/UID_MIN//')
	GID_MIN=$(grep '^GID_MIN' /etc/login.defs | sed 's/GID_MIN//')

	APACHE_UID=$(id -u "$APACHE_USER")
	APACHE_GID=$(id -g "$APACHE_USER")

	if [ "$APACHE_UID" -lt "$UID_MIN" ]; then
		ok "Apache uid is correct"
	else
		crit "Apache uid is incorrect. It should be lesser than $UID_MIN"
	fi

	if [ "$APACHE_GID" -lt "$GID_MIN" ]; then
		ok "Apache gid is correct"
	else
		crit "Apache gid is incorrect. It should be lesser than $GID_MIN"
	fi

	RUN_USERS=$(ps aux | grep apache2 | grep -v '^root' | cut -f 1 -d" ")
	APACHE_RUN_USER=$APACHE_USER
	for USER in $RUN_USERS; do
		if [ "$USER" != "$APACHE_USER" ]; then
			APACHE_RUN_USER=$USER
		fi
	done

	if [ "$APACHE_RUN_USER" != "$APACHE_USER" ]; then
		crit "Some apache process run with user $USER instead of $APACHE_USER"
	else
		ok "All apache process run with user $APACHE_USER"
	fi
}


# This function will check config parameters required
check_config() {
    :
}

# This function will create the config file for this check with default values
create_config() {
    cat <<EOF
status=audit
APACHE_USER='www-data'
APACHE_GROUP='www-data'
EOF
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

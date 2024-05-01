#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 6.1 Ensure the Error Log Filename and Severity Level Are Configured Correctly
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure the Error Log Filename and Severity Level Are Configured Correctly"

# This function will be called if the script status is on enabled / audit mode
audit() {
	get_apache2_conf

	LOGLEVEL_FOUND=$(echo "$APACHE2_CONF" | grep -i 'LogLevel' | wc -l)
	LOGLEVEL_NOTICE_FOUND=$(echo "$APACHE2_CONF" | grep -i "LogLevel $LOG_LEVELVALUE" | wc -l)

	if [ "$LOGLEVEL_FOUND" = 0 ]; then
		crit "No LogLevel directive found"
	elif [ "$LOGLEVEL_NOTICE_FOUND" = 0 ]; then
		crit "LogLevel directive found, but is has wrong value. It should be configured with \"$LOG_LEVELVALUE\""
	else
		ok "LogLevel directive found and it has a correct value"
	fi

	ERRORLOG_FOUND=$(echo "$APACHE2_CONF" | grep -i "ErrorLog" | wc -l)

	if [ "$ERRORLOG_FOUND" = 0 ]; then
		crit "No ErrorLog directive found"
	else
		ok "ErrorLog directive found"
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
# Specify LogError value. It should be at least info for the core and notice for other modules
LOG_LEVELVALUE="notice core:info"
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

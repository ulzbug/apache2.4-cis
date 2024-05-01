#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 6.2 Ensure a Syslog Facility Is Configured for Error Logging
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=2
# shellcheck disable=2034
DESCRIPTION="Ensure a Syslog Facility Is Configured for Error Logging"

# This function will be called if the script status is on enabled / audit mode
audit() {
	get_apache2_conf

	ERRORLOG_FOUND=$(echo "$APACHE2_CONF" | grep -i "ErrorLog \"syslog:$SYSLOG_FACILITY\"" | wc -l)

	if [ "$ERRORLOG_FOUND" = 0 ]; then
		crit "No ErrorLog directive with syslog facility found"
	else
		ok "ErrorLog directive with syslog facility found"
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
SYSLOG_FACILITY="local1"
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

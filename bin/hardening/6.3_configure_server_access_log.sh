#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 6.3 Ensure the Server Access Log Is Configured Correctly
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure the Server Access Log Is Configured Correctly"

# This function will be called if the script status is on enabled / audit mode
audit() {
	get_apache2_conf

	LOGFORMAT_OCCURENCES=$(echo "$APACHE2_CONF" | grep -i "LogFormat ")

	VALIDS_LOGFORMATS=()
	for LOGFORMAT_OCCURENCE in $LOGFORMAT_OCCURENCES; do
		LOGFORMAT_CONTENT=$(echo "$LOGFORMAT_OCCURENCE" | awk '{$1=""}1' | awk 'NF{NF-=1};1')
		LOGFORMAT_NAME=$(echo "$LOGFORMAT_OCCURENCE" | awk '{print $NF}')

		is_logformat_compliant "$LOGFORMAT_CONTENT"
		if [ "$FNRET" = 0 ]; then
			VALIDS_LOGFORMATS+=("$LOGFORMAT_NAME")
		fi
	done

	OK=1
	CUSTOMLOG_OCCURENCES=$(echo "$APACHE2_CONF" | grep -i "CustomLog " | sed -E 's/\s*CustomLog\s+[^ ]+\s+(.*)$/\1/i')
	for CUSTOMLOG_OCCURENCE in $CUSTOMLOG_OCCURENCES; do
		in_array "$CUSTOMLOG_OCCURENCE" "${VALIDS_LOGFORMATS[@]}"
		if [ "$FNRET" = 1 ]; then
			is_logformat_compliant "$CUSTOMLOG_OCCURENCE"
			if [ "$FNRET" = 1 ]; then
				crit "$CUSTOMLOG_OCCURENCE is not a compliant CustomLog format"
				OK=0
			fi
		fi
	done

	if [ "$OK" = 1 ]; then
		ok "All CustomLog occurences have compliant CustomLog format"
	fi
}

is_logformat_compliant() {
	local LOGFORMAT=$1

	if [[ "$LOGFORMAT" =~ "%h" ]] && [[ "$LOGFORMAT" =~ "%l" ]] && [[ "$LOGFORMAT" =~ "%u" ]] && [[ "$LOGFORMAT" =~ "%t" ]] && [[ "$LOGFORMAT" =~ "%r" ]] && [[ "$LOGFORMAT" =~ "%>s" ]] && [[ "$LOGFORMAT" =~ "%b" ]] && [[ "$LOGFORMAT" =~ "%{Referer}i" ]] && [[ "$LOGFORMAT" =~ "%{User-agent}i" ]]; then
		debug "$LOGFORMAT is compliant"
		FNRET=0
	else
		FNRET=1
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

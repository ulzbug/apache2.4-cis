#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 6.7 Ensure the OWASP ModSecurity Core Rule Set Is Installed and Enabled
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=2
# shellcheck disable=2034
DESCRIPTION="Ensure the OWASP ModSecurity Core Rule Set Is Installed and Enabled"

MODULE_NAME="security2_module"
OWASP_MODUSECURITY_FILES="REQUEST-900-EXCLUSION-RULES-BEFORE-CRS REQUEST-901-INITIALIZATION REQUEST-905-COMMON-EXCEPTIONS REQUEST-911-METHOD-ENFORCEMENT REQUEST-913-SCANNER-DETECTION REQUEST-920-PROTOCOL-ENFORCEMENT REQUEST-921-PROTOCOL-ATTACK REQUEST-922-MULTIPART-ATTACK REQUEST-930-APPLICATION-ATTACK-LFI REQUEST-931-APPLICATION-ATTACK-RFI REQUEST-932-APPLICATION-ATTACK-RCE REQUEST-933-APPLICATION-ATTACK-PHP REQUEST-934-APPLICATION-ATTACK-GENERIC REQUEST-941-APPLICATION-ATTACK-XSS REQUEST-942-APPLICATION-ATTACK-SQLI REQUEST-943-APPLICATION-ATTACK-SESSION-FIXATION REQUEST-944-APPLICATION-ATTACK-JAVA REQUEST-949-BLOCKING-EVALUATION RESPONSE-950-DATA-LEAKAGES RESPONSE-951-DATA-LEAKAGES-SQL RESPONSE-952-DATA-LEAKAGES-JAVA RESPONSE-953-DATA-LEAKAGES-PHP RESPONSE-954-DATA-LEAKAGES-IIS RESPONSE-955-WEB-SHELLS RESPONSE-959-BLOCKING-EVALUATION RESPONSE-980-CORRELATION RESPONSE-999-EXCLUSION-RULES-AFTER-CRS"

# This function will be called if the script status is on enabled / audit mode
audit() {
	is_apache2_module_enabled "$MODULE_NAME"
	if [ "$FNRET" = 0 ]; then
		ok "$MODULE_NAME is enabled"
	else
		crit "$MODULE_NAME is disabled or not installed"
	fi

	OK=1
	for OWASP_MODUSECURITY_FILE in $OWASP_MODUSECURITY_FILES; do
		does_file_exist "/etc/modsecurity/rules/$OWASP_MODUSECURITY_FILE.conf"
		if [ "$FNRET" != 0 ]; then
			OK=1
		fi
	done

	if [ "$OK" = 1 ]; then
		ok "OWASP ModSecurity Core Rule Set is installed"
	else
		crit "OWASP ModSecurity Core Rule Set is not installed"
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

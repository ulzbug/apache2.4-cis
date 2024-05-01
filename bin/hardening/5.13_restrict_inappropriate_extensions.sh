#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 5.13 Ensure Access to Inappropriate File Extensions Is Restricted
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=2
# shellcheck disable=2034
DESCRIPTION="Ensure Access to Inappropriate File Extensions Is Restricted"

# This function will be called if the script status is on enabled / audit mode
audit() {
	get_apache2_conf

	CONTAIN_FILESMATCH=$(echo "$APACHE2_CONF" | tr '\n' ' ' | grep -i '<FilesMatch "\^\.\*\$">>\s*Require all denied\s*</FilesMatch>' | wc -l)

	if [[ "$CONTAIN_FILESMATCH" = 0 ]]; then
		crit "There is no fileMatch directive to restrict all files by default"
	else
		ok "There is a FileMatch directive to restrict all files by default"
	fi

	CONTAIN_FILESMATCH=$(echo "$APACHE2_CONF" | tr '\n' ' ' | grep -i "<FilesMatch \"^.*\.\($ALLOWED_EXTENSIONS\)\$\">>>\s*Require all granted\s*</FilesMatch>" | wc -l)

	if [[ "$CONTAIN_FILESMATCH" = 0 ]]; then
		crit "There is no FileMatch directive to allow these extensions : $ALLOWED_EXTENSIONS. Maybe you should configure authorized extensions ?"
	else
		ok "Only authorized extensions are allowed"
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
# Specify extensions allowed in the FileMatch Directives
ALLOWED_EXTENSIONS="css|html?|js|pdf|txt|xml|xsl|gif|ico|jpe?g|png"
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

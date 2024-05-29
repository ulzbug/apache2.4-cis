#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 5.3 Ensure Options for Other Directories Are Minimized
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure Options for Other Directories Are Minimized"

# This function will be called if the script status is on enabled / audit mode
audit() {
	CONTENT_ALL_DIRECTORIES=$(grep "^[^#]" /etc/apache2/apache2.conf | tr '\n' ' ' | sed 's#<Directory#\n<Directory#ig' | sed -E 's#^[^<][^dD].*##'  | sed -E "s#.*<Directory ([^>]*)>(.*)</Directory>.*#\1:\2#")
	DOCUMENT_ROOT=$("$APACHE2CTLBIN" -t -D DUMP_RUN_CFG | grep "Main DocumentRoot:" | sed "s/Main DocumentRoot: //"| sed 's/"//g')

	ERROR=0

	IFS=$'\n'
	for CONTENT_DIRECTORY in $CONTENT_ALL_DIRECTORIES; do
		DIRECTORY=$(echo "$CONTENT_DIRECTORY" | cut -f1 -d":")
		CONTENT=$(echo "$CONTENT_DIRECTORY" | cut -f2 -d":")

		if [ "$DIRECTORY" = "/" ] || [ "$DIRECTORY" = "$DOCUMENT_ROOT" ]; then
			continue
		fi

		CONTAIN_OPTIONS=$(echo "$CONTENT" | grep -i "Options" | wc -l)
		CONTAIN_OPTIONS_NONE=$(echo "$CONTENT" | grep -i "Options None" | wc -l)
		CONTAIN_OPTIONS_INCLUDE=$(echo "$CONTENT" | grep -i "Options.*\+Include" | wc -l)

		if [ "$CONTAIN_OPTIONS" = 0 ]; then
			crit "Directive Options is not present in the directory element : $DIRECTORY"
			ERROR=1
		elif [ "$CONTAIN_OPTIONS_INCLUDE" -ne 0 ]; then
			crit "Directive Options contains 'Includes' in the directory element : $DIRECTORY"
			ERROR=1
		elif [ "$CONTAIN_OPTIONS_NONE" -eq 0 ]; then
			info "Directive Options is present in the directory element : $DIRECTORY and it contains options that should not be used unless necessary : Multiviews, ExecCGI, FollowSymLinks, Indexes"
		fi
	done
	unset IFS

	if [ "$ERROR" = 0 ]; then
		ok "All directories does not contain Options +Includes"
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

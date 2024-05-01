#!/bin/bash

# run-shellcheck
#
# Apache 2.4 CIS Hardening
#

#
# 7.9 Ensure All Web Content is Accessed via HTTPS
#

set -e # One error, it's over
set -u # One variable unset, it's over

# shellcheck disable=2034
HARDENING_LEVEL=1
# shellcheck disable=2034
DESCRIPTION="Ensure All Web Content is Accessed via HTTPS"

# This function will be called if the script status is on enabled / audit mode
audit() {

	get_apache2_conf

	URLS=()

	LISTEN_OCCURENCES=$(echo "$APACHE2_CONF" | grep -i 'Listen' | sed -e 's/^[[:space:]]*//')

	IFS=$'\n'

	for LISTEN in $LISTEN_OCCURENCES; do
		IP=$(echo "$LISTEN" | cut -f2 -d" ")
		PORT=$(echo "$LISTEN" | cut -f3 -d" ")

		if [ -n "$PORT" ] && [ "$IP" != "127.0.0.1" ] && [ "$IP" != "0.0.0.0" ] && [ "$IP" != "[::ffff:0.0.0.0]" ]; then
			URLS+=("$IP")
		fi
	done
	unset IFS

	SERVERNAME_OCCURENCES=$(echo "$APACHE2_CONF" | grep -i 'ServerName' | sed -e 's/^[[:space:]]*//')

	IFS=$'\n'

	for SERVERNAME_OCCURENCE in $SERVERNAME_OCCURENCES; do
		SERVERNAME=$(echo "$SERVERNAME_OCCURENCE" | cut -f2 -d" ")

		if [ "$SERVERNAME" != "127.0.0.1" ]; then
			URLS+=("$SERVERNAME")
		fi
	done
	unset IFS

	OK=1
	for URL in "${URLS[@]}"; do
		HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}\n" "http://$URL" | cat)
		if [ "$HTTP_CODE" != "000" ] && [[ ! "$HTTP_CODE" =~ "^3..$" ]] && [[ ! "$HTTP_CODE" =~ "^4..$" ]]; then
			crit "http://$URL should return a redirect http code ( 3XX ) or unavailable http code ( 4XX )"
			OK=0
		fi
	done

	if [ "$OK" = 1 ]; then
		ok "All web content is delivered via HTTPS"
	fi
}

# This function will check config parameters required
check_config() {
    is_pkg_installed "curl"
    if [ "$FNRET" != 0 ]; then
        warn "Curl is not installed, can't verify this check"
        exit 2
    fi
}

# This function will create the config file for this check with default values
create_config() {
    cat <<EOF
status=audit
# Specify LogError value. It should be at least info for the core and notice for other modules
SECURE_CIPHERS="ALL:!EXP:!NULL:!LOW:!SSLv2:!RC4:!aNULL:!3DES:!IDEA"
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

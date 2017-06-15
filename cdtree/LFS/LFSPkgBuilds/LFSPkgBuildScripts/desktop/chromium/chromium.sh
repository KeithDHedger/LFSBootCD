#!/bin/bash

#©keithhedger Wed 18 Mar 18:28:45 GMT 2015 kdhedger68713@gmail.com

# Allow users to override command-line options
# Based on Gentoo's chromium package (and by extension, Debian's)
if [[ -f /etc/default/chromium.default ]]; then
	. /etc/default/chromium.default
fi

# Prefer user defined CHROMIUM_USER_FLAGS (from env) over system
# default CHROMIUM_FLAGS (from /etc/chromium/default)
CHROMIUM_FLAGS=${CHROMIUM_USER_FLAGS:-$CHROMIUM_FLAGS}

export CHROME_WRAPPER=$(readlink -f "$0")
export CHROME_DESKTOP=chromium.desktop

exec /usr/lib64/chromium/chromium $CHROMIUM_FLAGS "$@"
#!/bin/bash

set -eu

create_user()
{
	username=$1
	uid=$2
	set +u
	gid=$3
	set -u
	if [ "X$gid" = "X" ]; then
		gid=$uid
	fi
	groupadd --force --gid $gid $username
	set +e
	useradd --home-dir /nonexistent --shell /usr/sbin/nologin --no-log-init --no-create-home --uid $uid --gid $gid $username
	set -e
}

create_user lxcroot       100000
create_user lxcfirstuser  101000
create_user lxcnobody     165534

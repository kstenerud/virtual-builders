Ubuntu APT Repository Mirror
============================

Mirrors the standard Ubuntu APT respository and shares it via http on port 80.


Use the following script to point to your mirror:

	RELEASE=bionic
	APT_MIRROR="http://your-internal-mirror-address/ubuntu/"
	SOURCES_LIST=/etc/apt/sources.list
	printf '%s\n%s\n' "deb [ arch=amd64 ] ${APT_MIRROR} ${RELEASE} main restricted
	deb [ arch=amd64 ] ${APT_MIRROR} ${RELEASE} universe
	deb [ arch=amd64 ] ${APT_MIRROR} ${RELEASE} multiverse
	deb [ arch=amd64 ] ${APT_MIRROR} ${RELEASE}-updates main restricted
	deb [ arch=amd64 ] ${APT_MIRROR} ${RELEASE}-updates universe
	deb [ arch=amd64 ] ${APT_MIRROR} ${RELEASE}-updates multiverse
	deb [ arch=amd64 ] ${APT_MIRROR} ${RELEASE}-security main restricted
	deb [ arch=amd64 ] ${APT_MIRROR} ${RELEASE}-security universe
	deb [ arch=amd64 ] ${APT_MIRROR} ${RELEASE}-security multiverse
	" "$(cat $SOURCES_LIST)" >$SOURCES_LIST
	apt update

Ubuntu APT Cacher
=================

Caches apt downloads.

To connect your ubuntu system to the cache, do the following:

	sudo apt install squid-deb-proxy-client

or:

	echo 'Acquire::http { Proxy "http://your-server:3142"; }' | sudo tee /etc/apt/apt.conf.d/00-apt-proxy

You can connect via HTTP to the cache admin interface on port `3142`.

    http://your-server:3142/acng-report.html


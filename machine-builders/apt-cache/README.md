Ubuntu APT Cacher
=================

Caches apt downloads.

To connect your ubuntu system to the cache, do the following:

	echo 'Acquire::http::Proxy "http://192.168.1.242:3142"' | sudo tee /etc/apt/apt.conf.d/00aptproxy

You can connect via HTTP to the cache admin interface on port `3142`.

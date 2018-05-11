NFS Container
=============

Sares files over NFS.


Mapping Directories
-------------------

Use the -m option:

	-m /host/path:my_writable:192.168.0.*:w
	-m /host/other/path:my_readonly:*:r

You can add as many -m arguments as you like.
See the script help (-H) for formatting information.
Exports will be exported under the "/exports" path tree. e.g. `/exports/my_writable`

Samba Container
===============

Sares files over SMB.


Mapping Directories
-------------------

Use the -m option:

	-m /host/path:my_writable:w
	-m /host/other/path:my_readonly:r

You can add as many -m arguments as you like.
See the script help (-H) for formatting information.


Host Considerations
-------------------

The samba user will be mapped to host user 165534, group 165534. You can use the included `add_shared_files_user.sh` script to add the user and group as `sharedfiles` to /etc/passwd and /etc/group.

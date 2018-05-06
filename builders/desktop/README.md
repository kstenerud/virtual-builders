LXC Desktop
===========

A virtual ubuntu 18.04 based desktop environment.
You can access the desktop with x2go.


You must mount a directory from the host to use as the desktop user's home directory. Note that you'll have to fiddle with permissions and ownerhip a bit to get this working. A non-privileged container will start at uid 100000, and so the first user will be 101000. In a privileged container, it will be 1000.


Desktop Environments
--------------------

Currently, only the following desktops actually work:

  * lxde
  * mate

The rest fail due to a dbus issue that I haven't been able to track down. Here are the logs if anyone has ideas:

### ~/.xsession-x2go-all-errors:

	dbus-update-activation-environment: warning: error sending to systemd: org.freedesktop.DBus.Error.Spawn.ChildExited: Process org.freedesktop.systemd1 exited with status 1
	xhost:  must be on local machine to add or remove hosts.
	localuser:karl being added to access control list
	xhost:  must be on local machine to add or remove hosts.
	dbus-update-activation-environment: setting QT_ACCESSIBILITY=1
	dbus-update-activation-environment: warning: error sending to systemd: org.freedesktop.DBus.Error.Spawn.ChildExited: Process org.freedesktop.systemd1 exited with status 1


### /var/log/syslog:

	Mar 26 11:34:14 all /usr/bin/x2gomountdirs[712]: successfully mounted karl@127.0.0.1:33574/home/karl/.x2go/S-karl-50-1522064053_stDGNOME_dp24/spool to /tmp/.x2go-karl/spool/C-karl-50-1522064053_stDGNOME_dp24
	Mar 26 11:34:15 all /usr/bin/x2goruncommand: launching session with Xsession-x2go mechanism, using STARTUP="/usr/bin/gnome-session --session=gnome-flashback-metacity --disable-acceleration-check"
	Mar 26 11:34:15 all /usr/bin/x2goruncommand: dbus wrapper available as /usr/bin/dbus-run-session
	Mar 26 11:34:15 all udisksd[155]: Error statting /dev/loop0: No such file or directory
	Mar 26 11:34:15 all udisksd[155]: Error statting none: No such file or directory
	Mar 26 11:34:16 all gnome-session[852]: gnome-session-binary[852]: CRITICAL: We failed, but the fail whale is dead. Sorry....
	Mar 26 11:34:16 all gnome-session-binary[852]: CRITICAL: We failed, but the fail whale is dead. Sorry....
	Mar 26 11:34:16 all udisksd[155]: Error statting /dev/loop0: No such file or directory
	Mar 26 11:34:16 all udisksd[155]: Error statting none: No such file or directory
	Mar 26 11:34:17 all udisksd[155]: Error statting /dev/loop0: No such file or directory
	Mar 26 11:34:17 all udisksd[155]: Error statting none: No such file or directory
	Mar 26 11:34:17 all /usr/bin/x2goumount-session[1106]: successfully unmounted "/tmp/.x2go-karl/spool/C-karl-50-1522064053_stDGNOME_dp24"

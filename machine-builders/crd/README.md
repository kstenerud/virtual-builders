LXC Chrome Remote Desktop
=========================

A minimal Ubuntu 18.04 mate desktop for use with Chrome Remote Desktop.
This is primarily to get access to SOME sort of desktop where I can ssh into other internal systems.
First time access to the desktop is via x2go.

You must mount a directory from the host to use as the desktop user's home directory. Note that you'll have to fiddle with permissions and ownerhip a bit to get this working. A non-privileged container will start at uid 100000, and so the first user will be 101000. In a privileged container, it will be 1000.

To enable headless CRD: https://remotedesktop.google.com/headless

More info: https://cloud.google.com/solutions/chrome-desktop-remote-on-compute-engine

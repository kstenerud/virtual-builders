LXC Steam
=========

A minimal Ubuntu 18.04 mate desktop with Steam installed.
Don't expect miracles with this. It can get REALLY slow with 3d games.
First time access to the desktop is via x2go.

Steam games must be launched using launch options: `PROTON_USE_WINED3D=1 %command%`

You must mount a directory from the host to use as the desktop user's home directory. Note that you'll have to fiddle with permissions and ownerhip a bit to get this working. A non-privileged container will start at uid 100000, and so the first user will be 101000. In a privileged container, it will be 1000.

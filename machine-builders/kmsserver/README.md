KMS Server
==========

Local Key Management Server for enterprise rollouts.



Attaching Clients
-----------------

    slmgr /upk
    slmgr /ipk [Enterprise Product Key]
    slmgr /skms [kms server hostname or ip]
    slmgr /ato



Building Your Own Server Binaries
---------------------------------

Obviously, you shouldn't trust random binaries downloaded from the internet. Build your own uing the `compile_vlmcsd.sh` script, which spins up a dev environment, git clones the vlmcsd repository, compiles it, and replaces the binaries in fs/usr/sbin.

Also, you should use your own repo that you control.

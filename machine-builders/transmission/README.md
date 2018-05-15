Transmission Daemon
===================

Transmission daemon and web service container.

You must provide a mount location for the configuration and downloads. `/var/lib/transmission` will be mapped there.


Settings
--------

The settings will be in your_mount_location/config/settings.json.

Note: Transmission will overwrite the settings file on shutdown. Only change the settings from within the app, or while the app or container is shut down.


First Time Connecting
---------------------

The first time you connect, you'll be prevented from accessing the web app due to the rpc whitelist. The setting to change is `rpc-whitelist`, or just turn off `rpc-whitelist-enabled`.


Important Settings and Their Defaults
-------------------------------------

* "download-queue-size": 5
* "peer-port": 51413
* "rpc-authentication-required": false
* "rpc-password": "{4e318cae37ff958b0d268c70ba7fc56144819514hELHCu3p"
* "rpc-username": ""
* "rpc-whitelist-enabled": true

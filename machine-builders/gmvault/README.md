GMail Backup
============

Backup GMail account daily at 1:55.



Usage
-----

### GMail Setup

Follow instructions at http://gmvault.org/gmail_setup.html


### First Time Run

Note: This container is set up to run gmvault under user `gmail`.

Open a shell `lxc exec gmvault bash` and run `sudo -u gmail gmvault sync foo.bar@gmail.com`


### Update Runs

The container will automatically run `gmvault sync -t quick foo.bar@gmail.com` at 1:55 every day, logging to /home/gmail/backup.log.

MacOS VM
========

Builds a MacOS virtual machine (tested on High Sierra).



Installing MacOS
----------------

If you need to install MacOS on the VM, you must call the build script with the -I option the first time around to specify the installer disk.

Installation steps:

  1. Use VNC (default port 5920) to connect to the installer via QEMU's VNC service
  2. Run Disk Utility
  3. Select View (top left corner gadget) -> Show All Devices
  4. Select your virtual drive (bottom QEMU HARDDISK MEDIA drive)
  5. Erase your virtual drive, naming it "MacOS" (Clover's config.plist is set to boot "MacOS" by default)
  6. Quit Disk Utility
  7. Run the OS installer



Screen Resolution
-----------------

Screen resolution has been fixed at 1920x1080. To change it, you'll need to alter the screen resolution settings in two places:


1. In Clover:
	* Use the supplied `change_clover_resolution.sh` script to modify the Clover.qcow2 image in your virtual Mac's directory. DO NOT EDIT THE TEMPLATE CLOVER.QCOW2 IMAGE IN THIS DIRECTORY!
	* Note that the script must be run as root.

2. In the OVMF settings:

    * Press ESC during early boot (before Clover screen) to get to the OVMF menu
    * Navigate: Device Manager -> OVMF Platform Configuration -> Change Preferred Resolution for Next Boot -> [chosen resolution]
    * Save and reboot



Maintenance and Tweaks
----------------------


### Clearing Free Space on the Mac Guest

    diskutil secureErase freespace 0 /Volumes/MacOS


### Compressing a QCOW Image on the Host

    mv mac_hdd.qcow mac_hdd-uncompacted.qcow
    qemu-img convert -O qcow2 -c mac_hdd-uncompacted.qcow mac_hdd.qcow
    rm mac_hdd-uncompacted.qcow



Creating an Installer ISO
-------------------------

* Download the "Install macOS High Sierra" app from the app store.
* Run the following:

      hdiutil create -o /tmp/HighSierra.cdr -size 5500m -layout SPUD -fs HFS+J
      hdiutil attach /tmp/HighSierra.cdr.dmg -noverify -mountpoint /Volumes/install_build
      sudo /Applications/Install\ macOS\ High\ Sierra.app/Contents/Resources/createinstallmedia --volume /Volumes/install_build

* Enter sudo password, answer Y to continue, then wait for it to finish.
* Run the following:

      mv /tmp/HighSierra.cdr.dmg ~/Desktop/InstallSystem.dmg
      hdiutil detach /Volumes/Install\ macOS\ High\ Sierra
      hdiutil convert ~/Desktop/InstallSystem.dmg -format UDTO -o ~/Desktop/HighSierra.iso
      mv ~/Desktop/HighSierra.iso.cdr ~/Desktop/HighSierra.iso



Troubleshooting
---------------

### Virsh Undefine Failure

MacOS uses nvram, which causes `virsh undefine mymacos` to barf:

    error: Failed to undefine domain mymacos
    error: Requested operation is not valid: cannot undefine domain with nvram

Get past this with the --nvram switch:

    virsh undefine --nvram mymacos


### Graphics Glitches (blank/white window)

Some apps may not display properly because they try to use hardware acceleration (for example, Chrome and Skype). Try to disable hardware acceleration in programs if you can.

Chrome's hardware acceleration setting is under advanced settings. It's difficult (but not impossible) to get to because the settings page itself uses hardware acceleration.


### Garbled Screen

This happens if the screen resolution settings in OVMF and Clover don't match. Double-check that you've set both to the same values (see Screen Resolution section).



Legal Issues
------------

There is much talk on the internet about Apple operating systems only being licensed to run on Apple hardware. I've been unable to find any such clauses in the license agreement (https://www.apple.com/legal/sla/docs/macOS1013.pdf), but that doesn't necessarily mean they're not there.

I'd recommend having a legal expert from your region examine the license agreement to make sure you're able to remain in compliance with it. Different regions have different restrictions on what is enorceable under a license agreement.



Notes
-----

Most of this is shamelessly stolen from https://github.com/kholia/OSX-KVM

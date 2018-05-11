Windows VM
==========

Builds a Windows virtual machine (only tested on Windows 10).



Installing Windows
------------------

If you need to install Windows on the VM, you must call the build script with the -I and -D options the first time around to specify the installer disk and the drivers disk.



Optimal Virtual Windows Setup
-----------------------------

### Network

- click network icon in tray
- click network conneced
- click network conneced in new window
- click private

### System

- set paging file to 50mb
- enable remote desktop
- rename pc: Settings -> System -> About -> Rename this PC

### Apps

- uninstall games

### Enterprise Activation

    slmgr /upk
    slmgr /ipk <your-product-key>
    slmgr /skms <your-kms-server>
    slmgr /ato

### Update

- Run windows update

### Compacting

- Run disk cleanup
- Run ultradefrag
- Run sdelete -c c:
- (Optional) Run c:\Windows\System32\Sysprep\sysprep.exe (as administrator)
  - out of box experience
  - generalize
  - shutdown
- qemu-img convert -O qcow2 -c uncompacted.qcow2 compacted.qcow2

Note that if you sysprep, the homedir of the user you used during the initial install will STILL be present after resetting the out of box experience, and will prevent you from creating the same username again.


Sources
-------

* https://www.microsoft.com/en-us/software-download/windows10ISO
* https://docs.fedoraproject.org/quick-docs/en-US/creating-windows-virtual-machines-using-virtio-drivers.html
* https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys
* https://docs.microsoft.com/en-us/sysinternals/downloads/sdelete
* http://ultradefrag.sourceforge.net/en/index.html

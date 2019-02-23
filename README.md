# VMware ESXi: Persistent USB NIC Binding

## Description

The original script on the Fling page did not offer an easy way to add uplinks to vSwitches and specific portgroups on USB NICs without copying and/or re-writing bigger parts of the script. This is a more flexible and extended script allowing to simply use one-line commands to do the job for you. See more details below.

## Installation

1. Install fling [USB Network Native Driver for ESXi
](https://labs.vmware.com/flings/usb-network-native-driver-for-esxi#instructions) as instructed (ignore the script part on linked page)
2. Copy content from script [`vusb.sh`](vusb.sh)
3. Add script right above `exit 0` in `/etc/rc.local.d/local.sh` on your VMware ESXi hypervisor
4. Add `vusbnic_setup` commands to modify the vSwitches/portgroups based on your needs.

For example the `local.sh` file might look like:
```shell
#!/bin/sh

# local configuration options

# Note: modify at your own risk!  If you do/use anything in this
# script that is not part of a stable API (relying on files to be in
# specific places, specific tools, specific output, etc) there is a
# possibility you will end up with a broken system after patching or
# upgrading.  Changes are not supported unless under direction of
# VMware support.

# Note: This script will not be run when UEFI secure boot is enabled.

# <SCRIPT_CONTENT>
vusbnic_setup()
{
    [...]
}
# </SCRIPT_CONTENT>

vusbnic_setup vusb0,vusb1 vSwitch1 M-Management,M-ServerA
vusbnic_setup vusb2 vSwitch2 M-ServerB

exit 0
```

## Examples

**Specify multiple vusb devices with same vSwitch and portgroups**
```text
$ vusbnic_setup vusb0,vusb1 vSwitch1 M-Management,M-ServerA
Processing device vusb0...
 Adding uplink vusb0 to vSwitch vSwitch1...
  Adding portgroup M-Management...
  Adding portgroup M-ServerA...
Processing device vusb1...
 Adding uplink vusb1 to vSwitch vSwitch1...
  Adding portgroup M-Management...
  Adding portgroup M-ServerA...
```

**Otherwise vusb settings can be specified separately, if they differ**
```shell
$ vusbnic_setup vusb0 vSwitch0 M-Management
Processing device vusb0...
 Adding uplink vusb0 to vSwitch vSwitch0...
  Adding portgroup M-Management...

$ vusbnic_setup vusb1 vSwitch1 M-ServerA
Processing device vusb1...
 Adding uplink vusb0 to vSwitch vSwitch1...
  Adding portgroup M-ServerA...
```

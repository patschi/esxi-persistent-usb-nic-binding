#!/bin/sh
# ^^^ Remove this line above when copying the content in `local.sh` on your ESXi

vusbnic_setup()
{
    vswitch=$2
    vusb_devs="$1," # add empty comma at the end so that while[] knows when to end
    while [[ "$vusb_devs" != "" ]]; do
        vusb_dev="${vusb_devs%%,*}" # get current vusb device to process
        vusb_devs="${vusb_devs#*,}" # cut off current vusb device from string

        echo "Processing device $vusb_dev..."
        vusb_status=$(esxcli network nic get -n $vusb_dev | grep 'Link Status' | awk '{print $NF}')
        count=0
        # wait maximum up to total of 1 minute
        while [[ $count -lt 60 && "${vusb_status}" != "Up" ]]; do
            sleep 5
            count=$(( $count + 1 ))
            vusb_status=$(esxcli network nic get -n $vusb_dev | grep 'Link Status' | awk '{print $NF}')
        done

        if [ "${vusb_status}" = "Up" ]; then # wait until vusb port comes online
            echo " Adding uplink $vusb_dev to vSwitch $vswitch..."
            esxcfg-vswitch -L $vusb_dev $vswitch # add uplink to vswitch
            portgroups="$3," # add empty comma at the end so that while[] knows when to end
            while [[ "$portgroups" != "" ]]; do
                portgroup="${portgroups%%,*}" # get current portgroup to add
                portgroups="${portgroups#*,}" # cut off current portgroup from string
                echo "  Adding portgroup $portgroup..."
                esxcfg-vswitch -M $vusb_dev -p "$portgroup" $vswitch # add portgroup to vswitch
            done
        fi
    done
}

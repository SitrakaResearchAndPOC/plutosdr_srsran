# plutosdr_srsran
## I. Flashing firmware using timestamp mode
[Flashing_firmware](https://github.com/SitrakaResearchAndPOC/osmobts_allsdr_docker/tree/main/plutosdr/firmeware)

## II. Preparing PlutoSDR
```
lsusb
```
Verify if this log exist </br>
`Bus 001 Device 006: ID 0456:b673 Analog Devices, Inc. LibIIO based AD9363 Software Defined Radio [ADALM-PLUTO]`  </br>

Launch : 
```
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="0456", ATTR{idProduct}=="b673", MODE="666"' | sudo tee /etc/udev/rules.d/90-libiio_pluto.rules
```
Then, 
```
sudo udevadm control --reload-rules
```
```
sudo udevadm trigger
```
Unplug and replug PlutoSDR </br>

## III. Installing tools
```
rm -rf srsran_pluto ; mkdir srsran_pluto && cd srsran_pluto
```
```
apt update
```
```
apt install docker.io wget
```
```
apt-get install linux-tools-common linux-tools-generic
```
```
cpupower frequency-set -g performance
```
## IV. Choice Dockerfile
* PRB = 6
```
[ -f Dockerfile.prb6 ] && rm -rf Dockerfile.prb6 ; \
wget https://raw.githubusercontent.com/SitrakaResearchAndPOC/plutosdr_srsran/refs/heads/main/configs/Dockerfile.prb6
```

* PRB = 15
```
[ -f Dockerfile.prb15 ] && rm -rf Dockerfile.prb15 ; \
wget https://raw.githubusercontent.com/SitrakaResearchAndPOC/plutosdr_srsran/refs/heads/main/configs/Dockerfile.prb15
```

* PRB = 25
```
[ -f Dockerfile.prb25 ] && rm -rf Dockerfile.prb25 ; \
wget https://raw.githubusercontent.com/SitrakaResearchAndPOC/plutosdr_srsran/refs/heads/main/configs/Dockerfile.prb25
```
## V. Building image
```
[ -f "Dockerfile" ] && rm Dockerfile; mv Dockerfile.* Dockerfile
```
```
docker  build -t srsran_pluto:v1 .
```

## VI. Launching srsran
### DIRECT USB
[screen_shots_usb_direct](https://github.com/SitrakaResearchAndPOC/osmobts_allsdr_docker/tree/main/plutosdr/screenshot_usb_direct)
```
docker rm -f srsran_pluto 2> /dev/null ; \
docker run -tid --privileged \
  --cgroupns=host \
  --net=host \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  -v /dev:/dev \
  -v /dev/bus/usb:/dev/bus/usb \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -v /home/user/.Xauthority:/home/user/.Xauthority:ro \
  --tmpfs /run \
  --tmpfs /run/lock \
  --env="DISPLAY=$DISPLAY" \
  --env="LC_ALL=C.UTF-8" \
  --env="LANG=C.UTF-8" \
  --env="NAME_PLUTO=pluto" \
  --cap-add=sys_nice \
  --cap-add=ipc_lock \
  --ulimit rtprio=99 \
  --ulimit memlock=-1 \
  --volume /run/dbus/system_bus_socket:/run/dbus/system_bus_socket \
  --volume /run/avahi-daemon/socket:/run/avahi-daemon/socket \
  --name srsran_pluto \
  --hostname srsran_pluto \
  srsran_pluto:v1
```
CHECK USB CONFIGURATION
```
docker exec -it srsran_pluto bash -c \
'bash check_pluto_usb_cfg.sh /root/.config/srsran/enb.conf'
```
### DIRECT ETHERENET
[screen_shots_ethernet_direct](https://github.com/SitrakaResearchAndPOC/osmobts_allsdr_docker/tree/main/plutosdr/screen_shot_ethernet_direct)
```
export NAME_PLUTO=fishball
```
```
docker rm -f srsran_pluto 2> /dev/null ; \
docker run -tid --privileged \
  --cgroupns=host \
  --net=host \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  -v /dev:/dev \
  -v /dev/bus/usb:/dev/bus/usb \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -v /home/user/.Xauthority:/home/user/.Xauthority:ro \
  --tmpfs /run \
  --tmpfs /run/lock \
  --env="DISPLAY=$DISPLAY" \
  --env="LC_ALL=C.UTF-8" \
  --env="LANG=C.UTF-8" \
  --env="NAME_PLUTO=$NAME_PLUTO" \
  --cap-add=sys_nice \
  --cap-add=ipc_lock \
  --ulimit rtprio=99 \
  --ulimit memlock=-1 \
  --volume /run/dbus/system_bus_socket:/run/dbus/system_bus_socket \
  --volume /run/avahi-daemon/socket:/run/avahi-daemon/socket \
  --name srsran_pluto \
  --hostname srsran_pluto \
  srsran_pluto:v1
```
```
docker exec -it srsran_pluto bash -c \
'bash check_pluto_network_cfg.sh  /root/.config/srsran/enb.conf'
```

## VII. Testing driver PlutoSDR
[screen_shot_plutosdr_srsran](https://github.com/SitrakaResearchAndPOC/plutosdr_srsran/tree/main/screen_shot)
```
xhost +
```
Change name of pluto eg : `fishball`
```
export NAME_PLUTO=fishball
```
```
docker exec -ti srsran_pluto bash -c 'ping "$NAME_PLUTO.local"'
```
or test ssh
```
ssh-keygen -R "$NAME_PLUTO.local" && docker exec -ti srsran_pluto bash -c 'ssh root@"$NAME_PLUTO.local"'
```
</br>
MDP is `analog`

```
docker exec -ti srsran_pluto bash -c 'SoapySDRUtil --info'
```
```
docker exec -ti srsran_pluto bash -c 'SoapySDRUtil --find'
```
```
docker exec -ti srsran_pluto  bash -c 'SoapySDRUtil --probe="driver=plutosdr"'
```

## VIII. Running srsRAN LTE
### ON TERMINAL 1
```
cpupower frequency-set -g performance && docker exec -ti srsran_pluto bash -c 'srsepc'
```
Tape ctrl+shift+T

### ON TERMINAL 2
```
cpupower frequency-set -g performance && docker exec -ti srsran_pluto bash -c 'srsenb'
```
## IX. Sharing Internet
New terminal , tape ctrl+shit+t </br>
### Finding interface which gives internet
```
ifconfig
```
Let name the interface <if_name> 
### sharing lte traffic
```
command -v wget >/dev/null 2>&1 || \
(apt-get update && apt-get install -y wget ) ; \
[ -f srsepc_if_masq.sh ] || \
wget https://raw.githubusercontent.com/SitrakaResearchAndPOC/plutosdr_srsran/refs/heads/main/srsepc_if_masq.sh && chmod +x  *.sh
```
```
bash srsepc_if_masq.sh <if_name>
```
### Routing internet over the interface
```
sysctl -w net.ipv4.ip_forward=1
```
### Disabling firewall 
```
ufw disable
```

## X. Configuring SIM & APN
1) Download [GR-SIM](https://github.com/SitrakaResearchAndPOC/gr-sim-write) </br>
2) Download grsp config [CONFIG](https://github.com/SitrakaResearchAndPOC/plutosdr_srsran/blob/main/configs_simcard_grsp/phil_greenland.grsp) ; my SIM supprot only xor for authentication algorithm </br>
3) Load and write the config on the green card using card write </br>
4) Plug and search network on parameter/sim_card/search_network and select network mcc=999 and mnc=69 </br>
5) If the simcard is authenticated on the network for future searching it's more quick to active/desactivate avion mode </br>
6) Configure APN indeed name should be `srsapn` and mcc on the apn should be 999 and mnc should be 69 </br>



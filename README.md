# plutosdr_srsran
## Flashing firmeware 
[Flashing_firmeware](https://github.com/SitrakaResearchAndPOC/osmobts_allsdr_docker/tree/main/plutosdr/firmeware)

## Installing tools
```
rm -rf srsran_pluto && mkdir srsran_pluto && cd srsran_pluto
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
## Choice Dockerfile
* PRB = 6
```
wget https://raw.githubusercontent.com/SitrakaResearchAndPOC/plutosdr_srsran/refs/heads/main/configs/Dockerfile.prb6
```

* PRB = 15
```
wget https://raw.githubusercontent.com/SitrakaResearchAndPOC/plutosdr_srsran/refs/heads/main/configs/Dockerfile.prb15
```

* PRB = 25
```
wget https://raw.githubusercontent.com/SitrakaResearchAndPOC/plutosdr_srsran/refs/heads/main/configs/Dockerfile.prb25
```
## Building image
```
[-f "Dockerfile"] && rm Dockerfile; mv Dockerfile.* Dockerfile
```
```
docker  build -t srsran_pluto:v1 .
```


## Building and launching srsran
## DIRECT USB
```
docker rm -f srsran_pluto && docker run -tid --privileged \
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
## DIRECT ETHERENET
```
export NAME_PLUTO=fishball
```
```
docker rm -f osmobts_pluto && docker run -tid --privileged \
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

## Testing driver PlutoSDR
```
xhost +
```
Change the <IP_ADDRESS>
```
docker exec -ti srsran_pluto bash -c 'ping <IP_ADDRESS>'
```
or test ssh
```
ssh-keygen -R '<IP_ADDRESS>' && docker exec -ti srsran_pluto bash -c 'ssh root@<IP_ADDRESS>'
```
</br>
MDP is `analog`

```
docker exec -ti srsran_pluto bash -c '$SRSRAN_INSTALL/bin/SoapySDRUtil  --info'
```
```
docker exec -ti srsran_pluto bash -c '$SRSRAN_INSTALL/bin/SoapySDRUtil  --find'
```
```
docker exec -ti srsran_pluto bash -c '$SRSRAN_INSTALL/bin/SoapySDRUtil  --probe="driver=plutosdr"'
```

## ON TERMINAL 1
```
cpupower frequency-set -g performance && docker exec -ti srsran_pluto bash -c 'cd ${HOME}/.config/srsran; ${SRSRAN_INSTALL}/bin/srsepc epc.conf'
```
Tape ctrl+shift+T

## ON TERMINAL 2
```
cpupower frequency-set -g performance && docker exec -ti srsran_pluto bash -c 'cd ${HOME}/.config/srsran; ${SRSRAN_INSTALL}/bin/srsenb enb.conf'
```

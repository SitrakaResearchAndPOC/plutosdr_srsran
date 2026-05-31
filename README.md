# plutosdr_srsran
## Flashing firmeware 
[Flashing_firmeware](https://github.com/SitrakaResearchAndPOC/osmobts_allsdr_docker/tree/main/plutosdr/firmeware)

## Installing tools
```
mkdir srsran && cd srsran
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
rm Dockerfile && mv Dockerfile.* Dockerfile
```
```
docker  build -t srsran_pluto:v1 .
```


## Building and launching srsran
```
docker rm -f srsran_pluto && \
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
  --cap-add=sys_nice \
  --cap-add=ipc_lock \
  --ulimit rtprio=99 \
  --ulimit memlock=-1 \
  --name srsran_pluto \
  --hostname srsran_pluto \
  srsran_pluto:v1
```
## Testing driver PlutoSDR
```
xhost +
```
Change the <IP_ADDRESS>
```
docker exec -ti osmobts_pluto bash -c 'ping <IP_ADDRESS>'
```
or test ssh
```
ssh-keygen -R '<IP_ADDRESS>' && docker exec -ti osmobts_pluto bash -c 'ssh root@<IP_ADDRESS>'
```
</br>
MDP is `analog`

```
docker exec -ti osmobts_pluto bash -c 'SoapySDRUtil --info'
```
```
docker exec -ti osmobts_pluto bash -c 'SoapySDRUtil --find'
```
```
docker exec -ti osmobts_pluto bash -c 'SoapySDRUtil --probe="driver=plutosdr"'
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

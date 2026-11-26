

---

# 10.2.1.1

## Download and Extract

```shell
ARCHIVE="https://thinkbox-installers.s3.us-west-2.amazonaws.com/Releases/Deadline/10.2/5_10.2.1.1/Deadline-10.2.1.1-linux-installers.tar"
SHA="https://thinkbox-installers.s3.us-west-2.amazonaws.com/Releases/Deadline/10.2/5_10.2.1.1/Deadline-10.2.1.1-linux-installers.sha256"
# version="10.2.1"

# https://unix.stackexchange.com/a/325492
curl --location "${ARCHIVE}" \
    --output ./${ARCHIVE##*/}
curl --location "${SHA}" \
    --output ./${SHA##*/}

tar -xvf ./${ARCHIVE##*/}
# rm ./${ARCHIVE##*/}
# rm ./${SHA##*/}
```

## Install DeadlineClient

> [!TIP]
> 
> For reference, based on the [OpenStudioLandscapes_Deadline_10_2/deadline_command_build_docker_image_client](https://openstudiolandscapes.meemoo.ch/assets/OpenStudioLandscapes_Deadline_10_2/deadline_command_build_docker_image_client) asset.
> 
> ```shell
> /installers/DeadlineClient.run \
>     --mode unattended \
>     --prefix /opt/Thinkbox/Deadline10 \
>     --setpermissionsclient true \
>     --repositorydir /opt/Thinkbox/DeadlineRepository10 \
>     --launcherdaemon false \
>     --httpport 8888 \
>     --enabletls false \
>     --proxyalwaysrunning false \
>     --blockautoupdateoverride NotBlocked \
>     --webserviceuser root \
>     --webservice_httpport 8899 \
>     --webservice_enabletls false
> ```

- [OpenStudioLandscapes_Deadline_10_2 & OpenStudioLandscapes_Deadline_10_2_Worker](https://openstudiolandscapes.meemoo.ch/asset-groups~OpenStudioLandscapes_Deadline_10_2%20OpenStudioLandscapes_Deadline_10_2_Worker/?open-nodes%5B%5D=OpenStudioLandscapes%20Engine&open-nodes%5B%5D=OpenStudioLandscapes%20Engine%3AComposeScope_default&open-nodes%5B%5D=OpenStudioLandscapes%20Engine%3AOpenStudioLandscapes_Kitsu&open-nodes%5B%5D=OpenStudioLandscapes%20Engine%3AOpenStudioLandscapes_Dagster&open-nodes%5B%5D=OpenStudioLandscapes%20Engine%3AOpenStudioLandscapes_OpenCue&open-nodes%5B%5D=OpenStudioLandscapes%20Engine%3AOpenStudioLandscapes_Deadline_10_2&open-nodes%5B%5D=__repository__%40OpenStudioLandscapes%20Engine%3AOpenStudioLandscapes_Deadline_10_2_Worker&open-nodes%5B%5D=__repository__%40OpenStudioLandscapes%20Engine%3AOpenStudioLandscapes_Deadline_10_2&expanded=__repository__%40OpenStudioLandscapes%20Engine%3AOpenStudioLandscapes_Deadline_10_2_Worker)
- [OpenStudioLandscapes_Deadline_10_2/connection_ini](https://openstudiolandscapes.meemoo.ch/assets/OpenStudioLandscapes_Deadline_10_2/connection_ini)
- `deadline_ini`
  - [OpenStudioLandscapes_Deadline_10_2/deadline_ini](https://openstudiolandscapes.meemoo.ch/assets/OpenStudioLandscapes_Deadline_10_2/deadline_ini)
  - [OpenStudioLandscapes_Deadline_10_2_Worker/deadline_ini](https://openstudiolandscapes.meemoo.ch/assets/OpenStudioLandscapes_Deadline_10_2_Worker/deadline_ini)
- [OpenStudioLandscapes_Deadline_10_2_Worker/deadline_command_compose_worker_runner](https://openstudiolandscapes.meemoo.ch/assets/OpenStudioLandscapes_Deadline_10_2_Worker/deadline_command_compose_worker_runner)

```shell
fhs
# sudo ./DeadlineClient-10.2.1.1-linux-x64-installer.run
# sudo: The "no new privileges" flag is set, which prevents sudo from running as root.
# sudo: If sudo is running in a container, you may need to adjust the container configuration to disable the flag.
./DeadlineClient-10.2.1.1-linux-x64-installer.run
```

- `/data/share/tools/.stage/test/`
  - [ ] Set full read/write enable
    - [images](media/images/full_rw)
  - [ ] Set full read/write disable
    - [images](media/images/no_rw)
- Client
- RCS: `deadline-rcs-runner-10-2.meemoo.lan:8888`
  - See [OpenStudioLandscapes_Deadline_10_2_Worker/deadline_ini](https://openstudiolandscapes.meemoo.ch/assets/OpenStudioLandscapes_Deadline_10_2_Worker/deadline_ini)
- No TLS/Certificates
- Use the repository for auto update

```shell
./DeadlineClient-10.2.1.1-linux-x64-installer.run \
    --mode text \
    --setpermissionsclient false \
    --prefix /data/share/tools/.stage/test \
    --connectiontype Remote \
    --proxyrootdir deadline-rcs-runner-10-2.meemoo.lan:8888 \
    --slavedatadir "$HOME/.temp/Deadline/slavedatadir" \
    --binariesonly true \
    --slavestartup false
```

```shell
sudo chmod 0777 /data/share/tools/.stage/test/bin/libpython3.7m.so
sudo chmod 0777 /data/share/tools/.stage/test/bin/plugins
sudo chmod 0777 /data/share/tools/.stage/test/bin/libNativeThinkboxUI.so
sudo chmod 0777 /data/share/tools/.stage/test/bin/libNodeView.so
sudo chmod 0777 /data/share/tools/.stage/test/bin/python
sudo chmod 0777 /data/share/tools/.stage/test/bin/lib
sudo chmod 0777 /data/share/tools/.stage/test/bin/libQtCommercialChart.so.1
sudo chmod 0777 /data/share/tools/.stage/test/bin/libpython2.7.so
sudo chmod 0777 /data/share/tools/.stage/test/bin/python3/plugins
sudo chmod 0777 /data/share/tools/.stage/test/bin/python3/libNativeThinkboxUI.so
sudo chmod 0777 /data/share/tools/.stage/test/bin/python3/libNodeView.so
sudo chmod 0777 /data/share/tools/.stage/test/bin/python3/libxkbcommon-x11.so.0
sudo chmod 0777 /data/share/tools/.stage/test/bin/python3/libxkbcommon.so.0
sudo chmod 0777 /data/share/tools/.stage/test/bin/python3/libQt5Charts.so.5

chmod -R 755 "/data/share/tools/.stage/test/Uninstall"*.desktop
```

```shell
/data/share/tools/.stage/test/bin/deadlinelauncher.exe -monitor
```

```
$ ldd /data/share/tools/.stage/test/bin/python3/python3
        linux-vdso.so.1 (0x00007ffff7fbe000)
        librt.so.1 => /lib/librt.so.1 (0x00007ffff7faa000)
        libpython3.7m.so.1.0 => /data/share/tools/.stage/test/lib/python3/lib/libpython3.7m.so.1.0 (0x00007ffff7a00000)
        libcrypt.so.1 => not found
        libpthread.so.0 => /lib/libpthread.so.0 (0x00007ffff7fa3000)
        libdl.so.2 => /lib/libdl.so.2 (0x00007ffff7f9e000)
        libutil.so.1 => /lib/libutil.so.1 (0x00007ffff7f99000)
        libm.so.6 => /lib/libm.so.6 (0x00007ffff78df000)
        libc.so.6 => /lib/libc.so.6 (0x00007ffff7600000)
        /lib64/ld-linux-x86-64.so.2 => /nix/store/r3hvhzl5fxhrgn0rfy5g7rda17702pj4-glibc-2.44-57/lib64/ld-linux-x86-64.so.2 (0x00007ffff7fc0000)
        libcrypt.so.1 => not found
```
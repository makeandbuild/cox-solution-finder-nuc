# Configurations

*Files prefixed with `mxm-` are alternative versions specific to the MaxMedia NUC*

## Gottchas

* Files in `/var/named` must have permissions of `0640` and owned by the `named` group.

## SSH Config `/root/.ssh/config`

NUC 1:

```
Host showroom-sshfwd
  HostName staging.sfv2.cox.mxmcloud.com
  User sfv2-sshforward
  RemoteForward 2122 localhost:22
```

NUC 2:

```
Host showroom-sshfwd
  HostName staging.sfv2.cox.mxmcloud.com
  User sfv2-sshforward
  RemoteForward 2222 localhost:22
```
NUC dev:

```
Host showroom-sshfwd
  HostName dev.sfv2.cox.mxmcloud.com
  User sfv2-sshforward
  RemoteForward 2122 localhost:22
```

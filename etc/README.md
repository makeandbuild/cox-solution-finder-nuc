# Configurations

The etc files go to the following directories on the NUCs:

* `dhcp/*` -> `/etc/dhcp/`
* `named/named.conf` -> `/etc/`
* `named/named.cox-sfv2-showroom` -> `/var/named/`
* `NetworkManager-dispatcher.d/*` -> `/etc/NetworkManager/dispatcher.d/`
* `NetworkManager-system-connections/*` -> `/etc/NetworkManager/system-connections/`
* `nginx/*` -> `/etc/nginx/conf.d/`
* `sbin/*` -> `/usr/local/sbin/`
* `sysconfig/*` -> `/etc/sysconfig/`
* `systemd/*` -> `/etc/systemd/system/`

Each configuration file is setup for development by default; however, it has configurations for
staging, production, and the various NUCs (as "NUC-?") notated and commented out.

## Gottchas

* Files in `/var/named` must have permissions of `0640` and owned by the `named` group.

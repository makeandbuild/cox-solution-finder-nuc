# Configurations

Most of the etc files go to their corresponding directories under `/etc` on the NUCs with a few
exceptions:

* `named/named.cox-sfv2-showroom` - `/var/named/`
* `sbin/*` -> `/usr/local/sbin/`
* `systemd/*` -> `/etc/systemd/system/`

Each configuration file is setup for development by default; however, it has configurations for
staging, production, NUC1, and NUC2 notated and commented out.

## Gottchas

* Files in `/var/named` must have permissions of `0640` and owned by the `named` group.

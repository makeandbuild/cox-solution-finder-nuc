# cox-solution-finder-nuc

Simple Express app to serve Cox Solution Finder project in the showroom.

Update static, public files:

    ./script/update-public.sh dev

Sync records:

    ./script/sync.rb dev

## Example nginx config

This nginx config shows how to run the static site and this app as a subdirectory.

    server {
      listen 80;
      server_name html.csf.dev.nookwit.com;
      root /home/stonewit/source/cox-solution-finder/public/;

      location / {
        index index.html;
      }

      rewrite ^/showroomstatus$ /_status_/update redirect;
      rewrite ^/_status_/update\.html$ /_status_/update redirect;
      location /_status_/ {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://localhost:3001/_status_/;
      }

      location /stats/ {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://localhost:3001/stats/;
      }

      location /socket.io/ {
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://localhost:3001/socket.io/;
      }
    }

## Showroom WiFi

* SSID: `cox-sfv2-showroom`, `cox-sfv2-showroom-mxm`, or `cox-sfv2-showroom-dev`
* Password: `s01uTIon5`
* URL: http://showroom.mxm

## NUC 1

* Ethernet Interface: `enp0s25` (MAC `b8:ae:ed:72:0c:84`)
* nuc1.showroom.sfv2.cox.mxmcloud.com
* WiFi Interface: `wlp2s0` (MAC `34:13:e8:0f:7f:58`)
* DHCP: `192.168.127.1/25`
* SSID: `cox-sfv2-showroom`

## NUC 2

* Ethernet Interface: `enp0s25` (MAC `b8:ae:ed:72:94:f9`)
* nuc2.showroom.sfv2.cox.mxmcloud.com
* WiFi Interface: `wlp2s0` (MAC `34:13:e8:1d:fe:48`)
* DHCP: `192.168.127.129/25`
* SSID: `cox-sfv2-showroom-mxm`

## NUC Dev

* Ethernet Interface: `enp0s25` (MAC `b8:ae:ed:72:a1:e9`)
* nuc.showroom.dev.sfv2.cox.mxmcloud.com
* WiFi Interface: `wlp2s0` (MAC `TBD`)
* DHCP: `192.168.126.1/24`
* SSID: `cox-sfv2-showroom-dev`

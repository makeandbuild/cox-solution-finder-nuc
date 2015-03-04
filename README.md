# cox-solution-finder-nuc

Simple Express app to capture posts


# Example nginx config

This nginx config shows how to run the static site and this app as a subdirectory.

				server {
					listen 80;
					server_name html.csf.dev.nookwit.com;
					root /home/stonewit/source/cox-solution-finder/public/;

					location / {
						index index.html;
					}

					location /stats/ {
						proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
						proxy_set_header Host $http_host;
						proxy_redirect off;
						proxy_pass http://localhost:3001/;
					}
				}


# Showroom WIFI

## Nuc 1

**Ethernet Interface**: `enp0s25` (MAC `b8:ae:ed:72:0c:84`)

**WiFi Interface**: `wlp2s0` (MAC `34:13:e8:0f:7f:58`)

* IP: `192.168.127.1/25`
* AP: `cox-sfv2-showroom` `gcpybhwtpo2g`

## Nuc 2

**Ethernet Interface**: `enp0s25` (MAC `b8:ae:ed:72:94:f9`)

**WiFi Interface**: `wlp2s0` (MAC `34:13:e8:1d:fe:48`)

* IP: `192.168.127.129/25`
* AP: `cox-sfv2-showroom-2` `gcpybhwtpo2g`

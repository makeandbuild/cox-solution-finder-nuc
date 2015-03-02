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

upstream selenium {
  server 127.0.0.1:4444;
}

server {
  listen 8080;
  server_name selenium.onefaceinamillion.com;
  
  allow 45.48.233.223;
  deny all;

  access_log /var/log/nginx/access-selenium.log;
  error_log  /var/log/nginx/error-selenium.log;

  location / {
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto https;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Real-Ip $remote_addr;
    proxy_pass http://selenium$request_uri;
  }  
}

  location / {
    # try_files $uri $uri/ =404;
    try_files $uri $uri/ /index.php?q=$uri&$args;
  }

  error_page 404 /404.html;
  error_page 500 502 503 504 /50x.html;

  location = /50x.html {
    root /usr/share/nginx/html;
  }

  location ~ \.php$ {
    try_files $uri =404;
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass unix:/var/run/php5-fpm.sock;
    fastcgi_index index.php;
    include fastcgi_params;
  }
}
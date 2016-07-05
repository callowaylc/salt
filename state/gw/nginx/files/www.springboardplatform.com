server {
  listen 8080;
  server_name 
    springboardplatform.com
    www.springboardplatform.com;

  location /mediaplayer/springboard/video/face001/2329/1602733 {
    try_files $uri =404;
  }

  location / {
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Real-Ip $remote_addr;    
    proxy_pass http://cs443.wpc.edgecastcdn.net?request_uri;
  }
}

backend default {
    .host = "127.0.0.1";
    .port = "8080";
}

sub vcl_recv {
  if (req.http.host ~ "springboardplatform.com$" &&
      req.url !~ "^/mediaplayer/springboard/video/face001/2329/1602733") {
    return( pass );
  }
  if (req.http.Accept-Encoding) {
    if (req.url ~ "\.(gif|jpg|jpeg|swf|flv|mp3|mp4|pdf|ico|png|gz|tgz|bz2)(\?.*|)$") {
      remove req.http.Accept-Encoding;
    } elsif (req.http.Accept-Encoding ~ "gzip") {
      set req.http.Accept-Encoding = "gzip";
    } elsif (req.http.Accept-Encoding ~ "deflate") {
      set req.http.Accept-Encoding = "deflate";
    } else {
      remove req.http.Accept-Encoding;
    }
  }
  if (req.url ~ "\.(gif|jpg|jpeg|swf|css|js|flv|mp3|mp4|pdf|ico|png)(\?.*|)$") {
    unset req.http.cookie;
    set req.url = regsub(req.url, "\?.*$", "");
  }
  if (req.url ~ "\?(utm_(campaign|medium|source|term)|adParams|client|cx|eid|fbid|feed|ref(id|src)?|v(er|iew))=") {
    set req.url = regsub(req.url, "\?.*$", "");
  }

  if ( req.url ~ "admin|login" ) {
    return( pass );
  
  } else {
    unset req.http.cookie;
    unset req.http.Cache-Control;

    return( lookup );
  }
}

sub vcl_fetch {
  if (req.url ~ "wp-(login|admin)" || req.url ~ "preview=true" || req.url ~ "xmlrpc.php") {
    return (hit_for_pass);
  }
  if ( (!(req.url ~ "(wp-(login|admin)|login)")) || (req.request == "GET") ) {
    unset beresp.http.set-cookie;
  }
  if (req.url ~ "\.(gif|jpg|jpeg|swf|css|js|flv|mp3|mp4|pdf|ico|png)(\?.*|)$") {
    set beresp.ttl = 365d;
  
  } else {
    set beresp.ttl = 300s;
    set beresp.grace = 300s;  
  }

  return( deliver );
}

sub vcl_deliver {
   if (obj.hits > 0) {
     set resp.http.X-Cache = "true";
   } else {
     set resp.http.X-Cache = "false";
   }
}


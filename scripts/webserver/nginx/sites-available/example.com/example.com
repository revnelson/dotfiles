# Uncomment for fastcgi caching
# fastcgi_cache_path /sites/example.com/cache levels=1:2 keys_zone=example.com:100m inactive=1d;

server {
    server_name example.com;

    root /sites/example.com/files/public/;

    access_log /sites/example.com/logs/access.log;
    error_log /sites/example.com/logs/error.log;

    index index.html index.php;

    # Don't allow pages to be rendered in an iframe on external domains.
    add_header X-Frame-Options "SAMEORIGIN";

    # MIME sniffing prevention
    add_header X-Content-Type-Options "nosniff";

    # Enable cross-site scripting filter in supported browsers.
    add_header X-Xss-Protection "1; mode=block";

    # Tell browsers to transparently upgrade HTTP resources to HTTPS
    add_header 'Content-Security-Policy' 'upgrade-insecure-requests';

    include sites-available/example.com/server/*;

    # Prevent access to hidden files
    location ~* /\.(?!well-known\/) {
        deny all;
    }

    # Prevent access to certain file extensions
    location ~\.(ini|log|conf|blade.php)$ {
        deny all;
    }

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        try_files $uri =404;

        include fastcgi.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;

        # Uncomment when using fastcgi-cache
        # include sites-available/example.com/location/*;
    }

    listen 80;
}
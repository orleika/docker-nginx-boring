FROM debian

MAINTAINER orleika "orleika.net@gmail.com"

RUN apt-get update && \
apt-get install git make cmake wget libpcre3 libpcre3-dev zlib1g-dev libgd-dev libgd2-xpm-dev libgd-gd2-perl build-essential libpng12-dev libjpeg-dev golang -y && \
cd /usr/local/src && \
git clone https://boringssl.googlesource.com/boringssl && \
cd boringssl && \
mkdir build && cd build && \
cmake ../ && \
make && \
mkdir -p /usr/local/src/boringssl/.openssl/lib && \
cd /usr/local/src/boringssl/.openssl && \
ln -s ../include && \
cd /usr/local/src/boringssl && \
cp build/crypto/libcrypto.a build/ssl/libssl.a .openssl/lib && \
useradd -s /sbin/nologin nginx && \
mkdir -p /var/{log,run}/nginx && \
mkdir -p /var/lib/nginx/body && \
chown nginx:nginx /var/{log,run}/nginx/ && \
cd /usr/local/src/ && \
wget https://nginx.org/download/nginx-1.11.4.tar.gz && \
tar zxf nginx-1.11.4.tar.gz && \
cd /usr/local/src/nginx-1.11.4 && \
./configure --prefix=/usr/share/nginx \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/run/nginx.pid \
--lock-path=/run/lock/subsys/nginx \
--user=nginx \
--group=nginx \
--with-threads \
--with-file-aio \
--with-ipv6 \
--with-http_ssl_module \
--with-http_v2_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_slice_module \
--with-http_stub_status_module \
--without-select_module \
--without-poll_module \
--with-openssl="/usr/local/src/boringssl" \
--with-cc-opt="-g -O2 -fPIE -fstack-protector-all -D_FORTIFY_SOURCE=2 -Wformat -Werror=format-security -I /usr/local/src/boringssl/.openssl/include/" \
--with-ld-opt="-Wl,-Bsymbolic-functions -Wl,-z,relro -L /usr/local/src/boringssl/.openssl/lib" && \
make && \
make install

CMD nginx -g 'daemon off;'

FROM localhost:5000/ubuntu
MAINTAINER innode

RUN apt-get update -y

# install LuaJIT
RUN apt-get install -y curl tar make gcc build-essential && \
    cd /usr/local/src && \
    curl -O http://luajit.org/download/LuaJIT-2.0.3.tar.gz && \
    tar xf LuaJIT-2.0.3.tar.gz && \
    cd LuaJIT-2.0.3 && \
    make && \
    make PREFIX=/usr/local/luajit install

# install nginx with lua-nginx-module
RUN apt-get install -y git curl tar bzip2 gzip libssl-dev libcurl4-openssl-dev && \
    export LUAJIT_LIB=/usr/local/luajit/lib && \
    export LUAJIT_INC=/usr/local/luajit/include/luajit-2.0 && \
    cd /usr/local/src && \
    git clone git://github.com/simpl/ngx_devel_kit.git && \
    git clone git://github.com/chaoslawful/lua-nginx-module.git && \
    curl -LO http://downloads.sourceforge.net/project/pcre/pcre/8.35/pcre-8.35.tar.bz2 && \
    tar xf pcre-8.35.tar.bz2 && \
    curl -O http://nginx.org/download/nginx-1.7.4.tar.gz && \
    tar xf nginx-1.7.4.tar.gz && \
    cd nginx-1.7.4 && \
    ./configure --prefix=/usr/local/nginx \
      --with-pcre=/usr/local/src/pcre-8.35 \
      --add-module=/usr/local/src/ngx_devel_kit \
      --add-module=/usr/local/src/lua-nginx-module \
      --with-ld-opt="-Wl,-rpath,$LUAJIT_LIB" && \
    make && \
    make install

# install lua-resty-redis
RUN cd /usr/local/src && \
    git clone git://github.com/agentzh/lua-resty-redis.git && \
    cd lua-resty-redis && \
    git checkout -b v0.20 v0.20 && \
    install -d /usr/local/lib/lua/resty && \
    install -t /usr/local/lib/lua/resty lib/resty/redis.lua

ADD conf/ /usr/local/nginx/conf/
RUN ln -s /usr/local/nginx/sbin/nginx /usr/bin
EXPOSE 80
CMD ["/usr/local/nginx/sbin/nginx", "-c", "/usr/local/nginx/conf/nginx.conf", "-g", "daemon off;"]

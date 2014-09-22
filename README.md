#下载dockerfile
git clone https://github.com/llk2256/innode-nginx.git
cd  innode-nginx
#创建innode-nginx镜像
docker build -t innode-nginx .
#运行innode-nginx容器
docker run -i -t -d -p 9080:80 --name innode-nginx innode-nginx  



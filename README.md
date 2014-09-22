
docker build -t innode-nginx .

docker run -i -t -d -p 9080:80 --name innode-nginx innode-nginx  

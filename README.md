# 本地开发Mysql基础镜像
---
## 镜像构建
`make build`

## 自签名证书
参考(How To Create a Self-Signed SSL Certificate for Nginx in CentOS 7)[https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-on-centos-7]

### 生成证书
确定安装了OpenSSL，然后执行下面的命令
```bash
sudo openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout nginx-selfsigned.key \
  -out nginx-selfsigned.crt
```
上面命令的各个参数含义如下：
* req：处理证书签署请求
* -x509：生成自签名证书
* -nodes：跳过为证书设置密码的阶段，这样 Nginx 才可以直接打开证书
* -days 365：证书有效期为一年
* -newkey rsa:2048：生成一个新的私钥，采用的算法是2048位的 RSA
* -keyout：新生成的私钥文件为当前目录下的nginx-selfsigned.key
* -out：新生成的证书文件为当前目录下的nginx-selfsigned.crt

执行后，命令行会跳出一堆问题要你回答，比如你在哪个国家、你的 Email 等等
其中最重要的一个问题是 Common Name，正常情况下应该填入一个域名，这里可以填 127.0.0.2

### 生成 dhparam.pem
```bash
sudo openssl dhparam -out dhparam.pem 2048
```

### HTTPS 配置
首先，打开conf/conf.d/default.conf文件，在结尾添加下面的配置
```nginx
server {
    listen 443 ssl http2;
    server_name  localhost;

    ssl                      on;
    ssl_certificate          /etc/nginx/certs/example.crt;
    ssl_certificate_key      /etc/nginx/certs/example.key;

    ssl_session_timeout  5m;

    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;

    ssl_dhparam /etc/nginx/certs/dhparam.pem;
}
```

然后，启动一个新的 Nginx 容器
```
docker container run \
  --rm \
  --name mynginx \
  --volume "$PWD/html":/usr/share/nginx/html \
  --volume "$PWD/conf":/etc/nginx \
  -p 127.0.0.2:8080:80 \
  -p 127.0.0.2:8081:443 \
  -d \
  nginx
```

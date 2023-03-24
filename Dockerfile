FROM nginx:alpine

COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./config/snippets/ /etc/nginx/snippets/
COPY ./ssl/ /etc/nginx/ssl/

RUN mkdir -p /opt/htdocs && mkdir -p /opt/log/nginx

# 替换国内镜像
COPY ./config/source.list /etc/apk/repositories

# 设置时区
ENV TIME_ZONE Asia/Shanghai
RUN apk add --no-cache tzdata \
    && echo "${TIME_ZONE}" > /etc/timezone \
    && ln -sf /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime

EXPOSE 80

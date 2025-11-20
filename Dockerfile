# 使用Python 3.11作为基础镜像
FROM python:3.11-slim

# 设置标签信息
LABEL maintainer="zhinianboke"
LABEL version="2.0.0"
LABEL description="闲鱼自动回复系统 - 企业级多用户版本"
LABEL repository="https://github.com/zhinianboke/xianyu-auto-reply"
LABEL license="仅供学习使用，禁止商业用途"
LABEL author="zhinianboke"

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV TZ=Asia/Shanghai
ENV DOCKER_ENV=true
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# 安装系统依赖（包括Playwright浏览器依赖）
# 已修正 libgdk-pixbuf2.0-0 为 libgdk-pixbuf-xlib-2.0-0，并优化了多行 RUN 的格式。
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nodejs npm tzdata curl ca-certificates \
    libjpeg-dev libpng-dev libfreetype6-dev fonts-dejavu-core fonts-liberation \
    libnss3 libnspr4 libatk-bridge2.0-0 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxrandr2 libgbm1 libxss1 libasound2 libatspi2.0-0 libgtk-3-0 libgdk-pixbuf-xlib-2.0-0 libxcursor1 libxi6 libxrender1 libxext6 libx11-6 libxft2 libxinerama1 libxtst6 libappindicator3-1 libx11-xcb1 libxfixes3 xdg-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# 设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 验证Node.js安装并设置环境变量
RUN node --version && npm --version
ENV NODE_PATH=/usr/lib/node_modules

# 复制requirements.txt并安装Python依赖
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 复制项目文件
COPY . .

# 安装Playwright浏览器（必须在复制项目文件之后）
RUN playwright install chromium && \
    playwright install-deps chromium

# 创建必要的目录并设置权限
RUN mkdir -p /app/logs /app/data /app/backups && \
    chmod 777 /app/logs /app/data /app/backups

# 注意: 为了简化权限问题，使用root用户运行
# 在生产环境中，建议配置适当的用户映射

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --

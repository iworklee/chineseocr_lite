FROM python:3.8-slim-bookworm

LABEL Author="Pad0y<github.com/Pad0y>"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PYTHONUNBUFFERED=1

COPY . /data/project/
WORKDIR /data/project/

# 添加重试和超时设置，使用清华源
RUN echo 'Acquire::Retries "8";' > /etc/apt/apt.conf.d/80retries && \
    echo 'Acquire::http::Timeout "120";' >> /etc/apt/apt.conf.d/80retries && \
    echo 'Acquire::ftp::Timeout "120";' >> /etc/apt/apt.conf.d/80retries && \
    echo 'deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware' > /etc/apt/sources.list && \
    echo 'deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware' >> /etc/apt/sources.list && \
    echo 'deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware' >> /etc/apt/sources.list && \
    echo 'deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware' >> /etc/apt/sources.list && \
    apt-get clean && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc g++ libgeos-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 配置pip使用清华源
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple/ && \
    pip config set install.trusted-host pypi.tuna.tsinghua.edu.cn && \
    pip install --upgrade pip

# 分批安装Python依赖，使用--no-cache-dir减少磁盘使用
RUN pip install --no-cache-dir tornado==5.1.1 numpy==1.19.1 && \
    pip install --no-cache-dir Shapely==1.7.0 && \
    pip install --no-cache-dir pyclipper==1.2.0 Pillow==7.2.0 && \
    pip install --no-cache-dir opencv-python-headless && \
    pip install --no-cache-dir onnxruntime

# 确认依赖安装完毕
RUN pip list

EXPOSE 8089

CMD ["python3", "backend/main.py"]
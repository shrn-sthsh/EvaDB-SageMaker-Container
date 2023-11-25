# Base Linux Distribution
FROM ubuntu:20.04 

# Set Work Directory
WORKDIR /app

# Packages for EvaDB
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3.9 \
        python3.9-dev \
        python3.9-distutils \
        gcc python3-dev \
        curl \
        ffmpeg \
        nginx \
        ca-certificates \
        && \
    apt-get autoremove --purge -y && \
    apt-get autoclean -y && \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/*

# Install pip and Environment Packages
RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python3.9 get-pip.py && \
    rm get-pip.py && \
    pip install Flask --default-timeout=1000 --no-cache-dir && \
    pip install awscliv2 --default-timeout=1000 --no-cache-dir && \
    pip install gevent==21.12 --default-timeout=1000 --no-cache-dir && \
    pip install gunicorn --default-timeout=1000 --no-cache-dir && \
    rm -rf /root/.cache

# Set Python Preferences
ENV PYTHONUNBUFFERED=TRUE
ENV PYTHONDONTWRITEBYTECODE=TRUE

# Set Path
ENV PATH="/app/program:${PATH}"

# Install EvaDB
RUN python3.9 -m pip install evadb 

# Define folder for EvaDB inference
COPY /evadb_instance /app/program

# Make Serving and Training Executable
RUN chmod +x /app/program/serve
RUN chmod +x /app/program/train

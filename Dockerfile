# Build a docker image which can operate EvaDB in Amazon SageMaker
FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu20.04

# Define packages required to run EvaDB
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      git \
      build-essential \
      python3.9 \
      python3.9-dev \
      python3.9-distutils \
      nginx \
      wget \
      ca-certificates \
      ffmpeg \
      && \
    apt-get autoremove --purge -y && \
    apt-get autoclean -y && \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/*

# Install python packages for the environment flask gevent gunicorn
RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python3.9 get-pip.py && rm get-pip.py && \
    python3.9 -m pip install flask --default-timeout=1000 --no-cache-dir && \
    python3.9 -m pip install gevent --default-timeout=1000 --no-cache-dir && \
    python3.9 -m pip install gunicorn --default-timeout=1000 --no-cache-dir && \
    python3.9 -m pip install evadb --default-timeout=1000 --no-cache-dir && \
    rm -rf /root/.cache

# Set environment variables
ENV PYTHONUNBUFFERED=TRUE
ENV PYTHONDONTWRITEBYTECODE=TRUE
ENV PATH="/opt/program:${PATH}"

# Define the folder where inference code is located
COPY evadb_instance /opt/program
RUN chmod +x /opt/program/train
RUN chmod +x /opt/program/serve
WORKDIR /opt/program

# Create defualt non-root user and use it
RUN useradd -m evauser 
RUN chown -R evauser:evauser /app
USER evauser

# Expose the default port EvaDB runs on 
EXPOSE 8803

# Start EvaDB
CMD ["eva_server"]


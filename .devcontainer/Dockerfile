FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV SDKMAN_DIR="/root/.sdkman"


# Install base tools
RUN apt-get update && apt-get install -y \
    curl wget zip unzip git gnupg lsb-release ca-certificates \
    python3 python3-pip \
    nodejs npm \
    openssl \
    #xmllint
    libxml2-utils \ 
    vim \
    jq \
    netcat-openbsd \
    iputils-ping \
    curl \
    sudo \
    openssh-server \
    build-essential bash-completion && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


#DOCKER INSTALLATION
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


# Install SDKMAN and Java + Maven
RUN curl -s "https://get.sdkman.io" | bash && \
    bash -c "source $SDKMAN_DIR/bin/sdkman-init.sh && \
      sdk install java 21.0.7-graal && \
      sdk default java 21.0.7-graal && \
      sdk flush archives"
#      sdk install java 21.0.7-sem && \
#      sdk install java 21.0.7-tem && \
#      sdk install java 21.0.2-open && \
#      sdk install java 21.0.2-graalce && \



RUN apt-get update && apt-get install -y maven

# ----------------------------------------------------
# Create non-root user with sudo permissions
# ----------------------------------------------------
RUN useradd -ms /bin/bash devuser && \
    echo "devuser:default" | chpasswd && \
    usermod -aG docker devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure SSH access
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Auto-load SDKMAN in bash
RUN echo 'source "$SDKMAN_DIR/bin/sdkman-init.sh"' >> /root/.bashrc



COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY utils/logger.sh /usr/local/bin/logger.sh
COPY utils/fetch-and-trust-cert.sh /usr/local/bin/fetch-and-trust-cert.sh
COPY utils/configure-nexus-connection.sh /usr/local/bin/configure-nexus-connection.sh
COPY utils/create-empty-p12.sh /usr/local/bin/create-empty-p12.sh
COPY utils/validate_maven_connection.sh /usr/local/bin/validate_maven_connection.sh


RUN chmod +x /usr/local/bin/logger.sh && \
    chmod +x /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/fetch-and-trust-cert.sh && \
    chmod +x /usr/local/bin/configure-nexus-connection.sh && \
    chmod +x /usr/local/bin/create-empty-p12.sh  && \
    chmod +x /usr/local/bin/validate_maven_connection.sh

EXPOSE 22

USER devuser


CMD ["/usr/local/bin/entrypoint.sh"]
#CMD ["/usr/sbin/sshd", "-D"]

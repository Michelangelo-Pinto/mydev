FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV SDKMAN_DIR="/root/.sdkman"


# Install base tools
RUN apt-get update && apt-get install -y \
    curl wget zip unzip git gnupg lsb-release ca-certificates \
    python3 python3-pip python3-venv python3-full \
    nodejs npm \
    openssl \
#    xmllint \
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





#RUN apt-get update && apt-get install -y maven


# Install SDKMAN and Java + Maven
RUN curl -s "https://get.sdkman.io" | bash && \
    bash -c "source $SDKMAN_DIR/bin/sdkman-init.sh && \
      sdk install java 25.ea.26-graal && \
      sdk install java 24.0.1-graalce && \
      sdk default java 24.0.1-graalce && \
      sdk flush archives"
#      sdk install java 21.0.7-sem && \
#      sdk install java 21.0.7-tem && \
#      sdk install java 21.0.2-open && \
#      sdk install java 21.0.2-graalce && \

ENV DEBIAN_FRONTEND=noninteractive
ENV MAVEN_VERSION=3.9.11
ENV MAVEN_HOME=/opt/maven
ENV PATH="${MAVEN_HOME}/bin:${PATH}"

RUN apt-get update && apt-get install -y \
 && curl -fsSL https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar -xz -C /opt \
 && ln -s /opt/apache-maven-${MAVEN_VERSION} ${MAVEN_HOME} \
 && rm -rf /var/lib/apt/lists/*




# ----------------------------------------------------
# Create non-root user with sudo permissions
# ----------------------------------------------------
#RUN useradd -ms /bin/bash devuser && \
#    echo "devuser:default" | chpasswd && \
#    usermod -aG docker devuser && \
#    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


# Crea gruppo docker e utente dev
#RUN groupadd --gid ${DOCKER_GID} docker \
# && useradd -m -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} ${USERNAME} \
# && usermod -aG docker ${USERNAME}

# Configure SSH access
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    ssh-keygen -A

# Auto-load SDKMAN in bash
RUN echo 'source "$SDKMAN_DIR/bin/sdkman-init.sh"' >> /root/.bashrc



COPY container/bin/ /usr/local/bin/
COPY container/libexec /usr/local/libexec
COPY container/entrypoint.d/ entrypoint.d/
RUN chmod +x /usr/local/bin/* /usr/local/libexec/*

EXPOSE 22

COPY container/home/  /home/devuser/
RUN find /root -name *sh -o -name *py | xargs chmod +x

RUN echo "root:toor" | chpasswd


WORKDIR /root

# Set the entrypoint script
CMD ["/usr/local/bin/entrypoint.sh"]

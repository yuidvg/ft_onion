FROM debian:stable-slim

RUN apt-get update \
    && apt-get install -y openssh-server --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/sshd

# Copy custom SSH configuration
COPY sshd_config /etc/ssh/sshd_config

# Create user for SSH access
ARG SSH_USER=devuser
ARG SSH_PASSWORD=password
RUN useradd -m -s /bin/bash $SSH_USER \
    && echo "$SSH_USER:$SSH_PASSWORD" | chpasswd \
    && mkdir -p /home/$SSH_USER/.ssh \
    && chown $SSH_USER:$SSH_USER /home/$SSH_USER/.ssh \
    && chmod 700 /home/$SSH_USER/.ssh

# Generate host keys
RUN ssh-keygen -A

CMD ["/usr/sbin/sshd", "-D"]

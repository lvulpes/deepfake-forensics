FROM node:lts-slim

# 1. Install system dependencies (libcap2-bin is required for setcap)
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    tshark \
    iproute2 \
    xxd \
    findutils \
    python3 \
    python3-pip \
    python3-venv \
    libcap2-bin \
    && rm -rf /var/lib/apt/lists/*

# 2. Configure Python virtual environment
RUN python3 -m venv /opt/gemini-sandbox
ENV PATH="/opt/gemini-sandbox/bin:/usr/local/bin:$PATH"

# 3. Install pyshark inside venv
RUN pip install --no-cache-dir pyshark

# 4. Grant packet capture capabilities to dumpcap for non-root execution
RUN chgrp node /usr/bin/dumpcap && \
    chmod 750 /usr/bin/dumpcap && \
    setcap cap_net_raw,cap_net_admin+eip /usr/bin/dumpcap

# 5. Install Gemini CLI
RUN npm install -g @google/gemini-cli

# 6. Configure workspace & non-root user
RUN mkdir -p /home/node/.gemini /home/node/workdir && \
    chown -R node:node /home/node

USER node

WORKDIR /home/node/workdir
ENTRYPOINT ["gemini"]

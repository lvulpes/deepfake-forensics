FROM node:lts-slim

# 1. Install system dependencies as root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    tshark \
    iproute2 \
    && rm -rf /var/lib/apt/lists/*

# 2. Grant non-root packet capture capabilities to dumpcap
RUN setcap cap_net_raw,cap_net_admin+eip /usr/bin/dumpcap

# 3. Clone and install WireMCP globally or in a shared path
RUN git clone https://github.com/0xKoda/WireMCP.git /opt/wiremcp \
    && cd /opt/wiremcp && npm install

RUN chown -R node:node /opt/wiremcp

# 4. Install Gemini CLI
RUN npm install -g @google/gemini-cli

RUN mkdir -p /home/node/.gemini && chown -R node:node /home/node

USER node

COPY --chown=node:node settings.json /home/node/.gemini/settings.json

WORKDIR /home/node/workdir
ENTRYPOINT ["gemini"]

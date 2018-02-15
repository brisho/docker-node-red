FROM node:6-alpine

# Create home directory for Node-RED application source code. Also
# create user data directory to contain flows, config and nodes.
RUN mkdir -p /usr/src/node-red && \
    mkdir /data

WORKDIR /usr/src/node-red

# Add node-red user so we aren't running as root
RUN adduser -h /usr/src/node-red -D -H node-red && \
    chown -R node-red:node-red /data && \
    chown -R node-red:node-red /usr/src/node-red

# Switch to node-red user for the rest
USER node-red

# package.json contains Node-RED NPM module and node dependencies
# as well as whatever other nodes are to be installed
COPY package.json /usr/src/node-red/
RUN npm install

EXPOSE 1880

# Set up environment variables
ENV FLOWS=flows.json
ENV NODE_PATH=/usr/src/node-red/node_modules:/data/node_modules

CMD ["npm", "start", "--", "--userDir", "/data"]


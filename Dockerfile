FROM node:alpine

RUN apk add --no-cache make gcc g++ python

RUN mkdir -p /usr/src/node-red /data \
    && addgroup node-red \
    && adduser -G node-red -h /usr/src/node-red -D -H node-red \
    && chown -R node-red:node-red /usr/src/node-red

USER node-red

# package.json contains Node-RED NPM module and node dependencies
# as well as whatever other nodes are to be installed
COPY package.json /usr/src/node-red/
RUN cd /usr/src/node-red \
    && npm install


##############################
### Build run-time container
FROM node:alpine

# Create home directory for Node-RED application source code. Also
# create user data directory to contain flows, config and nodes.
# Add node-red user so we aren't running as root
RUN mkdir -p /usr/src/node-red /data \
    && addgroup node-red \
    && adduser -G node-red -h /usr/src/node-red -D -H node-red

# Copy over needed pieces from first stage container
#COPY --from=0 /usr/bin/node* /usr/bin/
COPY --from=0 /usr/lib/libgcc* /usr/lib/libstdc* /usr/lib/

WORKDIR /usr/src/node-red
COPY --from=0 /usr/src/node-red/node_modules ./node_modules
COPY --from=0 /usr/src/node-red/package*json ./
COPY --from=0 /usr/src/node-red/.npm ./.npm
COPY --from=0 /usr/src/node-red/.node-gyp ./.node-gyp
COPY --from=0 /usr/src/node-red/.config ./.config
RUN chown -R node-red:node-red /data \
    && chown -R node-red:node-red /usr/src/node-red

# Switch to node-red user for the rest
USER node-red

EXPOSE 1880

# Set up environment variables
ENV FLOWS=flows.json
ENV NODE_PATH=/usr/src/node-red/node_modules:/data/node_modules

CMD ["npm", "start", "--", "--userDir", "/data"]


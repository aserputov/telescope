# This Docker file is used  for
# `development`, `test`, and `staging` enviornments
#
# CLI command to run this file: script="some-name" docker-compose up --build
# `some-name` is one of the names provided under `scripts` tag in `package.json` file
# example: $ script="test" docker-compose up --build    --> will run telescope with `test` script
# default: $ docker-compose up --build                  --> will run telescope with `start` script


# Dockerfile
#
# -------------------------------------

# NEXT_PUBLIC_API_URL is needed by the next.js build, which we define
# as a build ARG in API_URL

# Context: Build Context
FROM node:16 as build

# Set Working Directory Context
WORKDIR "/telescope"

# Copy package.jsons for each service
COPY package.json .

# -------------------------------------
# Context: Dependencies
FROM build AS backend_dependencies

# Install Production Modules!
# Disable postinstall hook in this case since we are being explict with installs
# `postinstall` typically goes on to install front-end and autodeployment modules
# which though is logical for local development, breaks docker container caching trick.
RUN npm install --only=production --no-package-lock --ignore-scripts

# -------------------------------------
# Context: Release
FROM node:16-alpine3.15 AS release

# GET production code from previous containers
COPY --from=backend_dependencies /telescope/node_modules /telescope/node_modules
COPY ./src/backend ./src/backend
COPY package.json .

# Directory for log files
RUN mkdir /log

# Environment variable with default value
ENV script=start

# Running telescope when the image gets built using a script
# `script` is one of the scripts from `package.json`, passed to the image
CMD ["sh", "-c", "npm run ${script}"]

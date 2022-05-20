FROM ubuntu:focal-20210921

WORKDIR /app

# Ensures tzinfo doesn't ask for region info.
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
    dumb-init \
    xvfb \
    build-essential libxi-dev libglu1-mesa-dev libglew-dev pkg-config

# Source: https://gist.github.com/remarkablemark/aacf14c29b3f01d6900d13137b21db3a
# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# update the repository sources list
# and install dependencies
RUN apt-get update \
    && apt-get install -y curl \
    && apt-get -y autoclean

RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -

RUN apt-get install -y nodejs

# confirm installation
RUN node -v
RUN npm -v

## INSTALL EDITLY

# ## Install app dependencies
COPY package.json /app/
RUN npm install

# Add app source
COPY . /app

# Ensure `editly` binary available in container
RUN npm link

RUN apt-get update && apt-get install -y wget \
    xz-utils \
    dumb-init \
    xvfb

# Get ffmpeg and ffprobe with static build
RUN wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-4.3.1-amd64-static.tar.xz \
    && tar xvf ffmpeg-4.3.1-amd64-static.tar.xz \
    && cp ffmpeg-4.3.1-amd64-static/ffmpeg /usr/local/bin/ \
    && cp ffmpeg-4.3.1-amd64-static/ffprobe /usr/local/bin/ \
    && rm -rf ffmpeg-4.3.1-amd64-static.tar.xz \
    && rm -rf ffmpeg-4.3.1-amd64-static

# Ensure ffmpeg and ffprobe are successfully copied
RUN ffmpeg -version && ffprobe -version

ENTRYPOINT ["/usr/bin/dumb-init", "--", "xvfb-run", "--server-args", "-screen 0 1280x1024x24 -ac"]
CMD [ "editly" ]

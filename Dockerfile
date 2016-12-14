# This is a development environment you can use to build/test delivery-cli on Linux in a Docker container
# For example, the following command will create a directory called target-docker and build a release binary in it
# docker build -t delivery-cli . && docker run -it -v `pwd`/target-docker:/opt/delivery-cli/target --rm delivery-cli make release

# Ruby is the most complicated dependency, so let's just start with that image
FROM ruby:2.1.5

MAINTAINER Chef Software, Inc. <docker@chef.io>

# Install Rust
RUN apt-get update && \
    apt-get install \
       ca-certificates \
       curl \
       gcc \
       libc6-dev \
       wget \
       -qqy \
       --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

ENV RUST_ARCHIVE=rust-1.12.0-x86_64-unknown-linux-gnu.tar.gz
ENV RUST_DOWNLOAD_URL=https://static.rust-lang.org/dist/$RUST_ARCHIVE

RUN mkdir /opt/rust
WORKDIR /opt/rust

RUN curl -fsOSL $RUST_DOWNLOAD_URL \
    && curl -s $RUST_DOWNLOAD_URL.sha256 | sha256sum -c - \
    && tar -C /opt/rust -xzf $RUST_ARCHIVE --strip-components=1 \
    && rm $RUST_ARCHIVE \
    && ./install.sh

# Install Chef DK
RUN wget --content-disposition "https://omnitruck.chef.io/stable/chefdk/download?p=debian&pv=8.0&m=x86_64&v=latest" -O /tmp/chefdk.deb && \
    dpkg -i /tmp/chefdk.deb && \
    rm -rf /tmp/chefdk.deb
ENV PATH=/opt/chefdk/bin:/opt/chefdk/embedded/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Setup Dev Environment
RUN git config --global user.email "docker@chef.io" && git config --global user.name "Chef Software, Inc."
RUN useradd dbuild

# Add Repo
ADD . /opt/delivery-cli
WORKDIR /opt/delivery-cli

CMD /bin/bash

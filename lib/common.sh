#!/usr/bin/env bash

install_graalvm() {
  GRAALVM_DOWNLOAD_URL=${GRAALVM_DOWNLOAD_URL:-"https://github.com/oracle/graal/releases/download/vm-1.0.0-rc4/graalvm-ce-1.0.0-rc4-linux-amd64.tar.gz"}
  curl --retry 3 --location $GRAALVM_DOWNLOAD_URL | tar xzm -C /tmp/graalvm 

  export PATH=/tmp/graalvm/bin:$PATH
}

install_truffleruby() {
  gu install ruby
}
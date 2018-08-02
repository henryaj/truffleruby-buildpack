#!/usr/bin/env bash

install_graalvm() {
  mkdir -p /tmp/graalvm

  GRAALVM_DOWNLOAD_URL=${GRAALVM_DOWNLOAD_URL:-"https://github.com/oracle/graal/releases/download/vm-1.0.0-rc4/graalvm-ce-1.0.0-rc4-linux-amd64.tar.gz"}
  curl --retry 3 --location $GRAALVM_DOWNLOAD_URL | tar xzm -C /tmp/graalvm --strip-components 1

  export PATH=/tmp/graalvm/bin:$PATH
}

install_truffleruby() {
  gu install ruby
}

has_gemfile_lock() {
  local buildDir=${1}
  test -f ${buildDir}/Gemfile.lock
}

write_graalvm_profile() {
  local home=${1}
  mkdir -p ${home}/.profile.d
  cat << EOF > ${home}/.profile.d/graal.sh
export PATH="/tmp/graalvm/bin:\$PATH"
EOF
}

#!/usr/bin/env bash

set -euo pipefail

# TruffleRuby Buildpack - Common Functions
# =========================================

# Configuration with defaults (can be overridden via environment variables)
TRUFFLERUBY_VERSION="${TRUFFLERUBY_VERSION:-24.1.1}"
TRUFFLERUBY_VARIANT="${TRUFFLERUBY_VARIANT:-community}"
TRUFFLERUBY_ARCH="${TRUFFLERUBY_ARCH:-linux-amd64}"
TRUFFLERUBY_HOME="${TRUFFLERUBY_HOME:-/tmp/truffleruby}"

# Logging functions
log_info() {
    echo "-----> $*"
}

log_step() {
    echo "       $*"
}

log_error() {
    echo " !     ERROR: $*" >&2
}

log_warn() {
    echo " !     WARNING: $*" >&2
}

die() {
    log_error "$@"
    exit 1
}

# Get the TruffleRuby download URL
get_truffleruby_url() {
    local version="${1:-$TRUFFLERUBY_VERSION}"
    local variant="${2:-$TRUFFLERUBY_VARIANT}"
    local arch="${3:-$TRUFFLERUBY_ARCH}"

    echo "https://github.com/oracle/truffleruby/releases/download/graal-${version}/truffleruby-${variant}-${version}-${arch}.tar.gz"
}

# Install TruffleRuby standalone distribution
install_truffleruby() {
    local install_dir="${1:-$TRUFFLERUBY_HOME}"
    local download_url

    download_url="$(get_truffleruby_url)"

    log_info "Installing TruffleRuby ${TRUFFLERUBY_VERSION} (${TRUFFLERUBY_VARIANT})"
    log_step "Downloading from: ${download_url}"

    mkdir -p "$install_dir"

    if ! curl --retry 3 --fail --silent --show-error --location "$download_url" | tar xzm -C "$install_dir" --strip-components 1; then
        die "Failed to download TruffleRuby from $download_url"
    fi

    export TRUFFLERUBY_HOME="$install_dir"
    export PATH="${install_dir}/bin:$PATH"

    log_step "TruffleRuby installed to: ${install_dir}"

    # Run post-install hook if it exists (compiles OpenSSL, etc.)
    local post_install="${install_dir}/lib/truffle/post_install_hook.sh"
    if [[ -x "$post_install" ]]; then
        log_info "Running TruffleRuby post-install hook"
        if ! "$post_install"; then
            log_warn "Post-install hook failed (non-fatal)"
        fi
    fi
}

# Check if Gemfile.lock exists
has_gemfile_lock() {
    local build_dir="${1:?build_dir required}"
    [[ -f "${build_dir}/Gemfile.lock" ]]
}

# Check if Gemfile exists
has_gemfile() {
    local build_dir="${1:?build_dir required}"
    [[ -f "${build_dir}/Gemfile" ]]
}

# Write TruffleRuby profile script for runtime
write_truffleruby_profile() {
    local home="${1:?home directory required}"
    local install_dir="${2:-$TRUFFLERUBY_HOME}"

    mkdir -p "${home}/.profile.d"
    cat <<EOF >"${home}/.profile.d/truffleruby.sh"
export TRUFFLERUBY_HOME="${install_dir}"
export PATH="\${TRUFFLERUBY_HOME}/bin:\$PATH"
EOF
}

# Get buildpack directory from a script location
get_buildpack_dir() {
    local script_path="${1:-${BASH_SOURCE[1]}}"
    cd "$(dirname "$script_path")/.." && pwd
}

# Indent output (for subprocess output)
indent() {
    local c='s/^/       /'
    case "$(uname)" in
        Darwin) sed -l "$c" ;;
        *) sed -u "$c" ;;
    esac
}

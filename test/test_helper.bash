#!/usr/bin/env bash

# BATS test helper for TruffleRuby buildpack

# Get buildpack root directory
BUILDPACK_DIR="$(cd "$(dirname "${BATS_TEST_DIRNAME}")" && pwd)"
TEST_DIR="${BUILDPACK_DIR}/test"
FIXTURES_DIR="${TEST_DIR}/fixtures"

# Create a temporary build directory
setup_build_dir() {
    export BUILD_DIR="$(mktemp -d)"
    export CACHE_DIR="$(mktemp -d)"
}

# Clean up temporary directories
teardown_build_dir() {
    [[ -d "$BUILD_DIR" ]] && rm -rf "$BUILD_DIR"
    [[ -d "$CACHE_DIR" ]] && rm -rf "$CACHE_DIR"
}

# Copy a fixture to the build directory
copy_fixture() {
    local fixture_name="$1"
    cp -r "${FIXTURES_DIR}/${fixture_name}/." "$BUILD_DIR/"
}

# Source the common.sh library for testing
load_common() {
    # shellcheck source=../lib/common.sh
    source "${BUILDPACK_DIR}/lib/common.sh"
}

# Assert that a string contains a substring
assert_contains() {
    local haystack="$1"
    local needle="$2"
    if [[ "$haystack" != *"$needle"* ]]; then
        echo "Expected '$haystack' to contain '$needle'" >&2
        return 1
    fi
}

# Assert that output matches a pattern
assert_output_contains() {
    local pattern="$1"
    if [[ "$output" != *"$pattern"* ]]; then
        echo "Expected output to contain '$pattern'" >&2
        echo "Actual output: $output" >&2
        return 1
    fi
}

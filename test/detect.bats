#!/usr/bin/env bats

load test_helper

setup() {
    setup_build_dir
}

teardown() {
    teardown_build_dir
}

@test "detect: succeeds when Gemfile exists" {
    touch "$BUILD_DIR/Gemfile"
    run "${BUILDPACK_DIR}/bin/detect" "$BUILD_DIR"
    [ "$status" -eq 0 ]
    [ "$output" = "Ruby" ]
}

@test "detect: fails when Gemfile is missing" {
    run "${BUILDPACK_DIR}/bin/detect" "$BUILD_DIR"
    [ "$status" -eq 1 ]
    [ "$output" = "no" ]
}

@test "detect: fails when build directory is empty string" {
    run "${BUILDPACK_DIR}/bin/detect" ""
    [ "$status" -eq 1 ]
    [ "$output" = "no" ]
}

@test "detect: handles directory with spaces in path" {
    local temp_dir
    temp_dir="$(mktemp -d -t 'build dir with spaces.XXXXXX')"
    touch "${temp_dir}/Gemfile"
    run "${BUILDPACK_DIR}/bin/detect" "$temp_dir"
    [ "$status" -eq 0 ]
    [ "$output" = "Ruby" ]
    rm -rf "$temp_dir"
}

@test "detect: ignores other Ruby-related files without Gemfile" {
    touch "$BUILD_DIR/Rakefile"
    touch "$BUILD_DIR/config.ru"
    run "${BUILDPACK_DIR}/bin/detect" "$BUILD_DIR"
    [ "$status" -eq 1 ]
    [ "$output" = "no" ]
}

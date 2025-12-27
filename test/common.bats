#!/usr/bin/env bats

load test_helper

setup() {
    setup_build_dir
    load_common
}

teardown() {
    teardown_build_dir
}

@test "has_gemfile_lock: returns true when Gemfile.lock exists" {
    touch "$BUILD_DIR/Gemfile.lock"
    run has_gemfile_lock "$BUILD_DIR"
    [ "$status" -eq 0 ]
}

@test "has_gemfile_lock: returns false when Gemfile.lock is missing" {
    run has_gemfile_lock "$BUILD_DIR"
    [ "$status" -eq 1 ]
}

@test "has_gemfile: returns true when Gemfile exists" {
    touch "$BUILD_DIR/Gemfile"
    run has_gemfile "$BUILD_DIR"
    [ "$status" -eq 0 ]
}

@test "has_gemfile: returns false when Gemfile is missing" {
    run has_gemfile "$BUILD_DIR"
    [ "$status" -eq 1 ]
}

@test "get_truffleruby_url: returns correct default URL format" {
    run get_truffleruby_url
    [ "$status" -eq 0 ]
    [[ "$output" == *"truffleruby-community-"* ]]
    [[ "$output" == *"linux-amd64.tar.gz"* ]]
    [[ "$output" == *"github.com/oracle/truffleruby"* ]]
}

@test "get_truffleruby_url: uses default version 24.1.1" {
    run get_truffleruby_url
    [ "$status" -eq 0 ]
    [[ "$output" == *"24.1.1"* ]]
}

@test "get_truffleruby_url: respects version parameter" {
    run get_truffleruby_url "23.1.0"
    [ "$status" -eq 0 ]
    [[ "$output" == *"23.1.0"* ]]
    [[ "$output" != *"24.1.1"* ]]
}

@test "get_truffleruby_url: respects variant parameter" {
    run get_truffleruby_url "24.1.1" "community-jvm"
    [ "$status" -eq 0 ]
    [[ "$output" == *"community-jvm"* ]]
}

@test "TRUFFLERUBY_VERSION: can be overridden via environment" {
    TRUFFLERUBY_VERSION="23.0.0"
    run get_truffleruby_url
    [ "$status" -eq 0 ]
    [[ "$output" == *"23.0.0"* ]]
}

@test "log_info: outputs with arrow prefix" {
    run log_info "Test message"
    [ "$status" -eq 0 ]
    [ "$output" = "-----> Test message" ]
}

@test "log_step: outputs with indentation" {
    run log_step "Step message"
    [ "$status" -eq 0 ]
    [ "$output" = "       Step message" ]
}

@test "log_error: outputs to stderr with error prefix" {
    run log_error "Error message"
    [ "$status" -eq 0 ]
    [[ "$output" == *"ERROR: Error message"* ]]
}

@test "indent: adds proper indentation" {
    result=$(echo "test line" | indent)
    [[ "$result" == "       test line" ]]
}

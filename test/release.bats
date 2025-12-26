#!/usr/bin/env bats

load test_helper

setup() {
    setup_build_dir
}

teardown() {
    teardown_build_dir
}

@test "release: outputs YAML header" {
    run "${BUILDPACK_DIR}/bin/release" "$BUILD_DIR"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "---" ]
}

@test "release: detects Rack app and suggests rackup" {
    touch "$BUILD_DIR/config.ru"
    echo "gem 'rack'" > "$BUILD_DIR/Gemfile"
    run "${BUILDPACK_DIR}/bin/release" "$BUILD_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"rackup"* ]]
    [[ "$output" == *"default_process_types"* ]]
}

@test "release: detects Rails app with single quotes" {
    echo "gem 'railties'" > "$BUILD_DIR/Gemfile"
    run "${BUILDPACK_DIR}/bin/release" "$BUILD_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"rails server"* ]]
    [[ "$output" == *"rails console"* ]]
}

@test "release: detects Rails app with double quotes" {
    echo 'gem "railties"' > "$BUILD_DIR/Gemfile"
    run "${BUILDPACK_DIR}/bin/release" "$BUILD_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"rails server"* ]]
}

@test "release: detects PostgreSQL addon with pg gem (single quotes)" {
    echo "gem 'pg'" > "$BUILD_DIR/Gemfile"
    run "${BUILDPACK_DIR}/bin/release" "$BUILD_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"heroku-postgresql"* ]]
}

@test "release: detects PostgreSQL addon with pg gem (double quotes)" {
    echo 'gem "pg"' > "$BUILD_DIR/Gemfile"
    run "${BUILDPACK_DIR}/bin/release" "$BUILD_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"heroku-postgresql"* ]]
}

@test "release: skips default_process_types when Procfile exists" {
    touch "$BUILD_DIR/Procfile"
    run "${BUILDPACK_DIR}/bin/release" "$BUILD_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" != *"default_process_types"* ]]
}

@test "release: provides rake and console for generic Ruby app" {
    touch "$BUILD_DIR/Gemfile"
    run "${BUILDPACK_DIR}/bin/release" "$BUILD_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"rake: bundle exec rake"* ]]
    [[ "$output" == *"console: bundle exec irb"* ]]
}

@test "release: Rails takes precedence over Rack" {
    touch "$BUILD_DIR/config.ru"
    echo "gem 'railties'" > "$BUILD_DIR/Gemfile"
    run "${BUILDPACK_DIR}/bin/release" "$BUILD_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"rails server"* ]]
    [[ "$output" != *"rackup"* ]]
}

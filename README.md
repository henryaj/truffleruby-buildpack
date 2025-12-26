# TruffleRuby Heroku Buildpack

A Heroku buildpack for deploying Ruby applications using [TruffleRuby](https://www.graalvm.org/ruby/), a high-performance Ruby implementation built on GraalVM.

## Features

- TruffleRuby 24.1.1 (compatible with GraalVM for JDK 21 LTS)
- Automatic Bundler installation and dependency resolution
- rbenv integration for Ruby version management
- Support for Rack and Rails applications
- Automatic Procfile generation
- PostgreSQL addon detection

## Usage

### Set the Buildpack

```bash
heroku buildpacks:set https://github.com/henryaj/truffleruby-buildpack
```

Or add it to your `app.json`:

```json
{
  "buildpacks": [
    { "url": "https://github.com/henryaj/truffleruby-buildpack" }
  ]
}
```

### Requirements

- Heroku stack: heroku-22 or heroku-24
- `Gemfile` in repository root
- `Gemfile.lock` for dependency installation

## Configuration

Configure the buildpack using environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `TRUFFLERUBY_VERSION` | `24.1.1` | TruffleRuby version to install |
| `TRUFFLERUBY_VARIANT` | `community-jvm` | Distribution variant (`community` or `community-jvm`) |
| `TRUFFLERUBY_ARCH` | `linux-amd64` | Target architecture |

### Variants

- **`community-jvm`** (default): Runs on the JVM. Better compatibility across Linux distributions. Slower cold start but better peak performance after warmup. Includes GraalVM JDK.
- **`community`**: Native standalone image. Faster cold start but may have glibc compatibility issues on some systems (e.g., Heroku-24).

### Examples

```bash
# Use a specific TruffleRuby version
heroku config:set TRUFFLERUBY_VERSION=24.0.0

# Use native variant (faster startup, but may have compatibility issues)
heroku config:set TRUFFLERUBY_VARIANT=community
```

## Compatibility

| TruffleRuby Version | GraalVM JDK | Ruby Compatibility |
|--------------------|-------------|-------------------|
| 24.1.x | JDK 21 LTS | Ruby 3.2 |
| 24.0.x | JDK 21 LTS | Ruby 3.2 |
| 23.1.x | JDK 21 LTS | Ruby 3.2 |

## How It Works

The buildpack follows Heroku's standard three-phase buildpack interface:

### 1. Detection (`bin/detect`)

Checks for a `Gemfile` in the application root. If found, the buildpack is activated.

### 2. Compilation (`bin/compile`)

1. Installs required APT packages (openssl, make, clang, llvm, libssl-dev, git)
2. Downloads and installs TruffleRuby standalone distribution
3. Runs TruffleRuby's post-install hook (compiles OpenSSL bindings)
4. Installs rbenv for Ruby version management
5. Links TruffleRuby as an rbenv-managed version
6. Installs Bundler and runs `bundle install`

### 3. Release (`bin/release`)

Generates default process types based on detected application type:

- **Rails apps**: `rails server` for web, `rails console` for console
- **Rack apps**: `rackup` for web
- **Generic Ruby**: `rake` and `irb` console

Also suggests the `heroku-postgresql` addon if the `pg` gem is detected.

## Development

### Running Tests

This buildpack uses [BATS](https://github.com/bats-core/bats-core) (Bash Automated Testing System) for testing.

```bash
# Install BATS (macOS)
brew install bats-core

# Install BATS (Ubuntu/Debian)
sudo apt-get install bats

# Run all tests
bats test/

# Run specific test file
bats test/detect.bats
```

### Linting

Shell scripts are linted with [ShellCheck](https://www.shellcheck.net/):

```bash
# Install ShellCheck (macOS)
brew install shellcheck

# Run linting
shellcheck bin/* lib/*.sh .profile.d/*
```

### Project Structure

```
truffleruby-buildpack/
├── bin/
│   ├── compile          # Main build script
│   ├── detect           # Buildpack detection
│   ├── install_binaries # APT package installation
│   └── release          # Release configuration
├── lib/
│   └── common.sh        # Shared functions and configuration
├── .profile.d/
│   └── graal_env        # Runtime environment setup
├── test/
│   ├── test_helper.bash # BATS test utilities
│   ├── detect.bats      # Detection tests
│   ├── common.bats      # Library function tests
│   ├── release.bats     # Release script tests
│   └── fixtures/        # Test fixtures
└── .github/
    └── workflows/
        └── ci.yml       # GitHub Actions CI
```

## Troubleshooting

### Build fails with "Failed to download TruffleRuby"

Check that the TruffleRuby version exists. View available releases at:
https://github.com/oracle/truffleruby/releases

### "required file not found" or binary execution errors

If you see errors like `cannot execute: required file not found` at runtime, this usually indicates glibc compatibility issues with the native variant. Switch to the JVM variant:

```bash
heroku config:set TRUFFLERUBY_VARIANT=community-jvm
git commit --allow-empty -m "Trigger rebuild"
git push heroku main
```

### OpenSSL errors

The buildpack automatically runs TruffleRuby's post-install hook to compile OpenSSL bindings. If you encounter SSL errors, ensure `libssl-dev` is available (it's included by default).

### Memory issues

TruffleRuby may require more memory than MRI Ruby. Consider:

- Using a larger dyno size
- Using the `community` variant (native image, lower memory) if compatible with your system
- Tuning JVM memory with `JAVA_OPTS` for the `community-jvm` variant

## License

MIT

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `bats test/`
5. Run linting: `shellcheck bin/* lib/*.sh`
6. Submit a pull request

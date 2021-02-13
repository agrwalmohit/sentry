#!/bin/bash
# This script correctly installs Python dependencies
set -eu

# XXX: Ideally, we should make this import relative rather than from where the Makefile
# invokes this
# shellcheck disable=SC1091
source scripts/lib.sh

ensure-venv() {
    ./scripts/ensure-venv.sh
}

ensure-pinned-pip() {
    pip install --no-cache-dir --upgrade "pip>=20.0.2"
}

install-py-dev() {
    ensure-venv
    ensure-pinned-pip
    echo "--> Installing Sentry (for development)"
	pip_version=$(pip -V |  awk '{print $2}')
    # Older versions of pip require SYSTEM_VERSION_COMPAT in Big Sur
    # shellcheck disable=SC2072
    if query_big_sur && [[ $pip_version < 20.3 ]]; then
        SENTRY_LIGHT_BUILD=1 SYSTEM_VERSION_COMPAT=1 pip install -e '.[dev]'
    else
        # SENTRY_LIGHT_BUILD=1 disables webpacking during setup.py.
	    # Webpacked assets are only necessary for devserver (which does it lazily anyways)
	    # and acceptance tests, which webpack automatically if run.
        SENTRY_LIGHT_BUILD=1 pip install -e '.[dev]'
    fi
}

"$@"

#!/usr/bin/env bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# shellcheck source=/dev/null
source "$SCRIPT_DIR"/../common

# Install Python build dependencies
if [[ $OSTYPE == "darwin"* ]]; then
    run_command "installing dependencies" "installed dependencies" \
        "xcode-select --install && brew install openssl readline sqlite3 xz zlib tcl-tk"
else
    run_command "installing dependencies" "installed dependencies" \
        "sudo apt-get install -y python3 python3-setuptools build-essential libssl-dev zlib1g-dev \\
            libbz2-dev libreadline-dev libsqlite3-dev curl \\
            libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \\
            libpq-dev"
fi

# Install and configure pyenv
if [[ ! -d ~/.pyenv ]]; then
    run_command "cloning pyenv to -> $HOME/.pyenv" "cloned pyenv to -> $HOME/.pyenv" \
        "git clone https://github.com/pyenv/pyenv.git ~/.pyenv"

    run_command "configuring pyenv" "configuring pyenv" \
        "cd ~/.pyenv && src/configure && make -C src && cd -"
fi

# Install and set global Python version using pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Only install provided Python version if it isn't already available
if ! pyenv global | grep "$PYTHON_VERSION" > /dev/null 2>&1; then
    run_command "installing python $PYTHON_VERSION" "installed python $PYTHON_VERSION" \
        "pyenv install -s $PYTHON_VERSION"

    run_command "setting global python version to $PYTHON_VERSION" "setted global python version to $PYTHON_VERSION" \
        "pyenv global $PYTHON_VERSION"

    # Need to make sure flake8 is installed for coc-pyright to work correctly
    # for some reason. I also added other packages here for general use so 
    # my vim setup works when editing standalone files outside of a project.
    run_command "installing python linters and formatters" "installed python linters and formatters"\
        "pip install flake8 black isort mypy"

    # Make sure executables are available
    run_command "rehashing pyenv" "rehashed pyenv" \
        "pyenv rehash"
fi

if ! poetry -V | grep "$POETRY_VERSION" > /dev/null 2>&1; then
    # Install poetry package manager
    run_command "installing poetry version $POETRY_VERSION" "installed poetry version $POETRY_VERSION" \
        "curl -sSL https://install.python-poetry.org | python3 - --uninstall" \
        "curl -sSL https://install.python-poetry.org | POETRY_VERSION=$POETRY_VERSION python3 -"
fi


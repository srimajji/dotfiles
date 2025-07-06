#!/bin/zsh

# MIT license
#
# Copyright (c) 2020 Manish Sahani
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


# Install and configure FZF if it's in brew bins list
[[ "${VAR_BREW_BINS[@]} " =~ " fzf " ]] && \
    $(brew --prefix)/opt/fzf/install --all

# Install and configure NVM (Node Version Manager)
if [[ "${VAR_BREW_BINS[@]} " =~ " nvm " ]]; then
    echo "Setting up NVM..."
    # Check if NVM is properly configured in .zshrc
    if ! grep -q "opt/nvm/nvm.sh" ~/.zshrc; then
        echo "Adding NVM configuration to .zshrc..."
        cat >> ~/.zshrc << 'EOF'

# NVM setup
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
EOF
    else
        echo "NVM is already configured in .zshrc"
    fi
    
    # Source NVM for the current session
    export NVM_DIR="$HOME/.nvm"
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
    
    # Install the latest LTS version of Node.js
    echo "Installing latest Node.js LTS version..."
    nvm install --lts
    nvm use --lts
    nvm alias default 'lts/*'
    
    echo "Node.js $(node -v) and npm $(npm -v) installed successfully."
fi

# Install and configure pyenv (Python Version Manager)
if [[ "${VAR_BREW_BINS[@]} " =~ " pyenv " ]]; then
    echo "Setting up pyenv..."
    
    # Check if pyenv is properly configured in .exports
    if ! grep -q "PYENV_ROOT" ~/.exports; then
        echo "Adding pyenv configuration to .exports..."
        cat >> ~/.exports << 'EOF'

# pyenv initialization
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
    else
        echo "pyenv is already configured in .exports"
    fi
    
    # Set up pyenv for the current session
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    
    # Install the latest stable Python version
    echo "Installing latest stable Python version..."
    # Get the latest Python version
    latest_python=$(pyenv install --list | grep -v - | grep -v b | grep -v a | grep -v rc | grep -E '^  [0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | sed 's/^  //')
    
    echo "Latest Python version: $latest_python"
    pyenv install -s "$latest_python"
    pyenv global "$latest_python"
    
    echo "Python $(python --version) installed successfully."
fi

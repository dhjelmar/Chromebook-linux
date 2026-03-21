#!/bin/bash

# --- THE UNIVERSAL UV-SETUP SCRIPT ---

uv-setup() {
    # 0. Root Discovery
    local original_dir=$(pwd)
    local project_root=""
    while [[ "$PWD" != "/" ]]; do
        if [[ -f "pyproject.toml" || -f "environment.yml" || -d ".git" || -f ".python-version" ]]; then
            project_root=$PWD
            break
        fi
        cd ..
    done

    if [ -z "$project_root" ]; then
        cd "$original_dir"
    else
        echo "📂 Project root identified at: $project_root"
    fi

    # 1. The Nuclear Reset
    # Note: 'deactivate' and 'conda' are shell functions, so we check if they exist
    [ "$(type -t deactivate)" = "function" ] && deactivate 2>/dev/null
    [ "$(type -t conda)" = "function" ] && conda deactivate 2>/dev/null
    pkill -9 uv 2>/dev/null

    # 2. Flags & Help
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        echo "Usage: uv-setup [URL] [--clean]"
        return 0
    fi

    local clean=false
    [[ "$*" == *"--clean"* ]] && clean=true

    # 3. Clone Logic
    local target="$1"
    if [[ $target == http* ]] || [[ $target == git@* ]]; then
        git clone "$target"
        cd "$(basename "$target" .git)" || return
    fi

    # 4. Deep Clean
    if [ "$clean" = true ]; then
        echo "🧹 Deep cleaning: Removing .venv and .vscode..."
        rm -rf .venv .vscode
    fi

    # 5. Determine Python Version
    local py_version=""
    if [ -f "environment.yml" ]; then
        if command -v yq >/dev/null 2>&1; then
            py_version=$(yq eval '.dependencies[] | select(. == "python*")' environment.yml | sed 's/python[=:]//')
        else
            py_version=$(grep -E "^\s*-\s*python\s*[:=]" environment.yml | sed -E 's/.*python[:=]\s*([0-9]+\.[0-9]+).*/\1/')
        fi
    fi
    [ -z "$py_version" ] && [ -f ".python-version" ] && py_version=$(cat .python-version | tr -d '[:space:]')
    [ -z "$py_version" ] && [ -f "pyproject.toml" ] && py_version=$(grep "requires-python" pyproject.toml | sed -E 's/.*([0-9]+\.[0-9]+).*/\1/')
    [ -z "$py_version" ] && py_version=$(uv python list --only-installed | awk '{print $2}' | sort -V | tail -n 1)

    # 6. Build & Configure
    echo "🚀 Initializing environment with Python $py_version..."
    uv venv --python "$py_version"
    
    mkdir -p .vscode
    cat <<EOF > .vscode/settings.json
{
    "python.defaultInterpreterPath": "\${workspaceFolder}/.venv/bin/python",
    "python.terminal.activateEnvInSelectedTerminal": true,
    "python.experiments.enabled": false
}
EOF

    # 7. Git Privacy & Sync
    [ -d ".git" ] && (grep -q ".vscode/" .git/info/exclude || echo ".vscode/" >> .git/info/exclude)

    if [ -f "pyproject.toml" ]; then
        uv sync
    elif [ -f "requirements.txt" ]; then
        uv pip install -r requirements.txt
    fi

    # 8. Activation
    source .venv/bin/activate
    echo "✅ Setup complete. Prompt updated to (uv:$py_version)."
    # code .     # uncomment this to start vscode
}

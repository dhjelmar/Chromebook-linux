#!/bin/bash

# this is activated by sourcing the file from _bash_aliases
# `uv-setup` is then run from the command line when needed

uv-setup() {
    local clean=false
    local target=""
    local original_dir="$PWD"

    # --- 0. Argument Parsing ---
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                echo "Usage  : uv-setup [URL] [--clean | -c]"
                echo "Options: --clean : Forces removal of .venv and .vscode"
                return 0
                ;;
            -c|--clean)
                clean=true
                shift
                ;;
            *)
                target="$1" # Fixed: No spaces around '='
                shift
                ;;
        esac
    done

    # --- 1. Git-Fast Root Discovery ---
    local project_root=""
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        project_root=$(git rev-parse --show-toplevel)
        cd "$project_root" || return
    else
        # Fallback walk
        while [[ "$PWD" != "/" ]]; do
            if [[ -f "pyproject.toml" || -f "environment.yml" || -f ".python-version" ]]; then
                project_root="$PWD"
                break
            fi
            cd ..
        done
    fi

    [[ -z "$project_root" && -z "$target" ]] && cd "$original_dir"

    # --- 2. Lockfile Integrity Check (Stale Check) ---
    # Skip everything if .venv is newer than pyproject.toml and not cleaning
    if [[ "$clean" == false && -d ".venv" && -f "pyproject.toml" ]]; then
        if [[ "pyproject.toml" -ot ".venv" ]]; then
            echo "✨ Environment is up-to-date. Activating..."
            source .venv/bin/activate 2>/dev/null || . .venv/bin/activate
            return 0
        fi
    fi

    # --- 3. The Reset ---
    [ "$(type -t deactivate)" = "function" ] && deactivate 2>/dev/null
    [ "$(type -t conda)" = "function" ] && conda deactivate 2>/dev/null
    pkill -TERM uv 2>/dev/null

    # --- 4. Clone Logic ---
    if [[ $target == http* ]] || [[ $target == git@* ]]; then
        git clone "$target"
        cd "$(basename "$target" .git)" || return
        project_root="$PWD"
    fi

    # --- 5. Deep Clean ---
    if [ "$clean" = true ]; then
        echo "🧹 Deep cleaning: Removing .venv and .vscode..."
        rm -rf .venv .vscode
    fi

    # --- 6. Python Version Logic ---
    local py_version=""
    if [ -f "environment.yml" ]; then
        py_version=$(grep -E "python[:=]" environment.yml | sed -E 's/.*python[:=][[:space:]]*([^[:space:]]+).*/\1/' | head -n 1)
    fi
    [ -z "$py_version" ] && [ -f ".python-version" ] && py_version=$(cat .python-version | tr -d '[:space:]')
    [ -z "$py_version" ] && [ -f "pyproject.toml" ] && py_version=$(grep "requires-python" pyproject.toml | sed -E 's/.*([0-9]+\.[0-9]+).*/\1/')
    # Final fallback: Latest installed Python
    [ -z "$py_version" ] && py_version=$(uv python list --only-installed | awk '{print $2}' | grep '^3\.' | sort -V | tail -n 1)

    # --- 7. Build & Sync ---
    echo "🚀 Initializing with Python $py_version..."
    [ ! -d ".venv" ] && uv venv --python "$py_version"
    
    # Generate VS Code settings
    mkdir -p .vscode
    cat <<EOF > .vscode/settings.json
{
    "python.defaultInterpreterPath": "\${workspaceFolder}/.venv/bin/python",
    "python.terminal.activateEnvInSelectedTerminal": true,
    "python.experiments.enabled": false
}
EOF

    # Git Privacy
    [ -d ".git" ] && (grep -q ".vscode/" .git/info/exclude || echo ".vscode/" >> .git/info/exclude)

    if [ -f "pyproject.toml" ]; then
        uv sync
    elif [ -f "requirements.txt" ]; then
        uv pip install -r requirements.txt
    fi

    # --- 8. Activation ---
    source .venv/bin/activate 2>/dev/null || . .venv/bin/activate
    echo "✅ Setup complete. (uv:$py_version)"
}

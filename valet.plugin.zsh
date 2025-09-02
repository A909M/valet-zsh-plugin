#!/usr/bin/env zsh
#compdef valet

# Universal Valet Zsh Plugin
# Compatible with both Laravel Valet (macOS) and Valet Linux
# Provides autocompletion and helper functions for Laravel Valet

# Plugin initialization and compatibility detection
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"
typeset -g VALET_PLUGIN_DIR="${0:A:h}"

# User configurable options
typeset -g VALET_PLUGIN_AUTO_UPDATE=${VALET_PLUGIN_AUTO_UPDATE:-false}
typeset -g VALET_PLUGIN_SILENT_LOAD=${VALET_PLUGIN_SILENT_LOAD:-false}
typeset -g VALET_PLUGIN_DEFAULT_TLD=${VALET_PLUGIN_DEFAULT_TLD:-test}

# Detect OS and Valet version
_valet_detect_environment() {
    local os_type=""
    local valet_version=""
    
    case "$OSTYPE" in
        darwin*)
            os_type="macOS"
            ;;
        linux*)
            os_type="Linux"
            ;;
        *)
            os_type="Unknown"
            ;;
    esac
    
    if command -v valet >/dev/null 2>&1; then
        # Try to detect if it's official Laravel Valet or Valet Linux
        if valet --version 2>/dev/null | grep -qi "laravel"; then
            valet_version="Laravel Valet (Official)"
        elif valet --version 2>/dev/null | grep -qi "linux"; then
            valet_version="Valet Linux"
        else
            # Fallback detection based on OS
            if [[ "$os_type" == "macOS" ]]; then
                valet_version="Laravel Valet (Official)"
            else
                valet_version="Valet Linux"
            fi
        fi
    else
        valet_version="Not Installed"
    fi
    
    echo "$os_type|$valet_version"
}

# Parse environment detection
typeset -g VALET_ENV_INFO=$(_valet_detect_environment)
typeset -g VALET_OS="${VALET_ENV_INFO%%|*}"
typeset -g VALET_VERSION="${VALET_ENV_INFO##*|}"

# Plugin manager detection
_valet_detect_plugin_manager() {
    if [[ -n "$ZSH" ]] && [[ -d "$ZSH" ]]; then
        echo "oh-my-zsh"
    elif [[ -n "$ZINIT" ]] || [[ -n "$ZPLG_HOME" ]]; then
        echo "zinit"
    elif [[ -n "$ADOTDIR" ]]; then
        echo "antigen"
    elif [[ -n "$ZPLUG_HOME" ]]; then
        echo "zplug"
    elif [[ -n "$ZPREZTODIR" ]]; then
        echo "prezto"
    elif [[ -n "$ANTIBODY_HOME" ]]; then
        echo "antibody"
    else
        echo "manual"
    fi
}

typeset -g VALET_PLUGIN_MANAGER=$(_valet_detect_plugin_manager)

# Service management functions (OS-specific)
_valet_get_services() {
    if [[ "$VALET_OS" == "macOS" ]]; then
        echo "nginx dnsmasq php"
    else
        echo "nginx dnsmasq php-fpm"
    fi
}

_valet_check_service_status() {
    local service=$1
    
    if [[ "$VALET_OS" == "macOS" ]]; then
        # macOS uses brew services
        if command -v brew >/dev/null 2>&1; then
            brew services list | grep -q "^$service.*started"
        else
            return 1
        fi
    else
        # Linux uses systemctl
        if command -v systemctl >/dev/null 2>&1; then
            if [[ "$service" == "php-fpm" ]]; then
                # Check for any PHP-FPM version
                for version in 8.4 8.3 8.2 8.1 8.0 7.4; do
                    if systemctl is-active --quiet "php${version}-fpm" 2>/dev/null; then
                        return 0
                    fi
                done
                return 1
            else
                systemctl is-active --quiet "$service" 2>/dev/null
            fi
        else
            return 1
        fi
    fi
}

# Lazy loading: Check if valet is available
if ! command -v valet >/dev/null 2>&1; then
    # Create a stub function that will load when valet is first used
    valet() {
        if ! command -v valet >/dev/null 2>&1; then
            echo "❌ Laravel Valet is not installed or not in PATH"
            if [[ "$VALET_OS" == "macOS" ]]; then
                echo "📖 Install guide: https://laravel.com/docs/valet"
                echo "💡 Run: composer global require laravel/valet && valet install"
            else
                echo "📖 Install guide: https://cpriego.github.io/valet-linux/"
                echo "💡 Run: composer global require cpriego/valet-linux && valet install"
            fi
            return 1
        fi
        
        # Remove the stub and source the real functionality
        unfunction valet
        _valet_load_full_plugin
        valet "$@"
    }
    
    # Show a minimal message for stub loading
    if [[ "$VALET_PLUGIN_SILENT_LOAD" != "true" ]] && [[ -o interactive ]]; then
        echo "🚀 Universal Valet Zsh Plugin loaded (lazy mode) - $VALET_OS detected"
    fi
    return 0
fi

# Full plugin loading function
_valet_load_full_plugin() {
    # Main completion function
    _valet() {
        local context state line
        typeset -A opt_args

        _arguments -C \
            '1: :_valet_commands' \
            '*::arg:->args' \
            && return 0

        case $state in
            args)
                case $words[1] in
                    link)
                        _arguments \
                            '--secure[Create a secure (HTTPS) link]' \
                            '1:name:'
                        ;;
                    unlink)
                        _valet_linked_sites
                        ;;
                    links)
                        # No additional arguments
                        ;;
                    park)
                        _path_files -/
                        ;;
                    unpark)
                        _valet_parked_directories
                        ;;
                    paths)
                        # No additional arguments
                        ;;
                    start)
                        local services=($(_valet_get_services))
                        _arguments "*:service:(${services[@]})"
                        ;;
                    stop)
                        local services=($(_valet_get_services))
                        _arguments "*:service:(${services[@]})"
                        ;;
                    restart)
                        local services=($(_valet_get_services))
                        _arguments "*:service:(${services[@]})"
                        ;;
                    install)
                        # No additional arguments
                        ;;
                    uninstall)
                        _arguments \
                            '--force[Force uninstall without confirmation]'
                        ;;
                    secure)
                        _valet_unsecured_sites
                        ;;
                    unsecure)
                        _valet_secured_sites
                        ;;
                    share)
                        _valet_linked_sites
                        ;;
                    log)
                        if [[ "$VALET_OS" == "macOS" ]]; then
                            _arguments '1:service:(nginx php)'
                        else
                            _arguments '1:service:(nginx php-fpm)'
                        fi
                        ;;
                    trust)
                        # No additional arguments
                        ;;
                    domain)
                        _arguments '1:domain:'
                        ;;
                    tld)
                        _arguments '1:tld:'
                        ;;
                    isolate)
                        _arguments \
                            '1:php-version:' \
                            '--site[Isolate specific site]:site:_valet_linked_sites'
                        ;;
                    unisolate)
                        _valet_isolated_sites
                        ;;
                    isolated)
                        # No additional arguments
                        ;;
                    php)
                        _arguments '1:version:(7.4 8.0 8.1 8.2 8.3 8.4)'
                        ;;
                    which-php)
                        _valet_linked_sites
                        ;;
                    fetch-share-url)
                        _valet_linked_sites
                        ;;
                    on-latest-version)
                        # No additional arguments
                        ;;
                    # macOS specific commands
                    use)
                        if [[ "$VALET_OS" == "macOS" ]]; then
                            _arguments '1:php-version:(7.4 8.0 8.1 8.2 8.3 8.4)'
                        fi
                        ;;
                    # Linux specific commands  
                    status)
                        if [[ "$VALET_OS" == "Linux" ]]; then
                            # No additional arguments
                        fi
                        ;;
                esac
                ;;
        esac
    }

    # Get available valet commands (OS-specific)
    _valet_commands() {
        local commands
        
        # Common commands for both versions
        local common_commands=(
            'install:Install Valet and its dependencies'
            'uninstall:Uninstall Valet'
            'start:Start the Valet services'
            'stop:Stop the Valet services'
            'restart:Restart the Valet services'
            'park:Park the current directory'
            'unpark:Remove the current directory from parked directories'
            'paths:Get all parked directories'
            'link:Link the current directory to Valet'
            'unlink:Remove the current directory link from Valet'
            'links:Display all linked sites'
            'secure:Secure a site with TLS'
            'unsecure:Remove TLS security from a site'
            'share:Generate a publicly accessible URL'
            'fetch-share-url:Get the share URL for a site'
            'log:View Valet logs'
            'trust:Add the Valet certificate to system trust store'
            'domain:Change the domain used for Valet sites'
            'tld:Change the TLD used for Valet sites'
            'isolate:Use a specific PHP version for a site'
            'unisolate:Stop using a specific PHP version for a site'
            'isolated:List all isolated sites'
            'php:Switch between PHP versions'
            'which-php:Display the PHP version for a site'
            'on-latest-version:Check if Valet is on the latest version'
        )
        
        commands=("${common_commands[@]}")
        
        # Add OS-specific commands
        if [[ "$VALET_OS" == "macOS" ]]; then
            commands+=(
                'use:Set the PHP version for the current site'
                'loopback:Create a loopback alias'
            )
        else
            commands+=(
                'status:Show Valet service status'
            )
        fi
        
        _describe 'valet commands' commands
    }

    # Helper functions for completion (cross-platform)
    _valet_linked_sites() {
        local sites config_paths
        
        # Check different possible config locations
        config_paths=(
            ~/.config/valet/config.json  # Linux
            ~/.valet/config.json         # Linux alternative
            ~/.composer/vendor/laravel/valet/cli/stubs/config.json  # macOS
        )
        
        for config_path in "${config_paths[@]}"; do
            if [[ -f "$config_path" ]]; then
                sites=(${(f)"$(valet links 2>/dev/null | grep -E '^\s*[a-zA-Z0-9]' | awk '{print $1}' | grep -v '^$')"})
                _describe 'linked sites' sites
                return
            fi
        done
    }

    _valet_parked_directories() {
        local paths
        if command -v valet >/dev/null 2>&1; then
            paths=(${(f)"$(valet paths 2>/dev/null | grep -v '^$')"})
            _describe 'parked directories' paths
        fi
    }

    _valet_secured_sites() {
        local sites
        if command -v valet >/dev/null 2>&1; then
            sites=(${(f)"$(valet links 2>/dev/null | grep 'https://' | awk '{print $1}' | grep -v '^$')"})
            _describe 'secured sites' sites
        fi
    }

    _valet_unsecured_sites() {
        local sites
        if command -v valet >/dev/null 2>&1; then
            sites=(${(f)"$(valet links 2>/dev/null | grep 'http://' | awk '{print $1}' | grep -v '^$')"})
            _describe 'unsecured sites' sites
        fi
    }

    _valet_isolated_sites() {
        local sites
        if command -v valet >/dev/null 2>&1; then
            sites=(${(f)"$(valet isolated 2>/dev/null | grep -E '^\s*[a-zA-Z0-9]' | awk '{print $1}' | grep -v '^$')"})
            _describe 'isolated sites' sites
        fi
    }

    # Set up completion
    compdef _valet valet
}

# Load full plugin immediately if valet is available
_valet_load_full_plugin

# Helper functions (cross-platform compatible)
valet-link-here() {
    if ! command -v valet >/dev/null 2>&1; then
        echo "❌ Laravel Valet is not installed"
        return 1
    fi
    
    local name=${1:-$(basename $PWD)}
    echo "🔗 Linking current directory as: $name"
    valet link "$name"
}

valet-secure-here() {
    if ! command -v valet >/dev/null 2>&1; then
        echo "❌ Laravel Valet is not installed"
        return 1
    fi
    
    local name=${1:-$(basename $PWD)}
    echo "🔒 Securing site: $name"
    valet secure "$name"
}

valet-open() {
    if ! command -v valet >/dev/null 2>&1; then
        echo "❌ Laravel Valet is not installed"
        return 1
    fi
    
    local site=${1:-$(basename $PWD)}
    local tld=$(valet domain 2>/dev/null | grep -oE '\.[a-z]+$' || echo ".$VALET_PLUGIN_DEFAULT_TLD")
    local protocol="http"
    
    # Check if site is secured
    if valet links 2>/dev/null | grep -q "https://$site$tld"; then
        protocol="https"
    fi
    
    local url="$protocol://$site$tld"
    echo "🌐 Opening: $url"
    
    # Cross-platform browser opening
    if [[ "$VALET_OS" == "macOS" ]]; then
        open "$url" 2>/dev/null
    else
        # Linux browser detection
        if command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$url" 2>/dev/null
        elif command -v google-chrome >/dev/null 2>&1; then
            google-chrome "$url" 2>/dev/null
        elif command -v firefox >/dev/null 2>&1; then
            firefox "$url" 2>/dev/null
        elif command -v chromium >/dev/null 2>&1; then
            chromium "$url" 2>/dev/null
        else
            echo "❌ No suitable browser found. URL: $url"
            # Copy to clipboard if available
            if command -v pbcopy >/dev/null 2>&1; then  # macOS
                echo -n "$url" | pbcopy
                echo "📋 URL copied to clipboard"
            elif command -v xclip >/dev/null 2>&1; then  # Linux
                echo -n "$url" | xclip -selection clipboard
                echo "📋 URL copied to clipboard"
            elif command -v xsel >/dev/null 2>&1; then   # Linux alternative
                echo -n "$url" | xsel --clipboard
                echo "📋 URL copied to clipboard"
            fi
        fi
    fi
}

valet-status() {
    echo "🚀 Valet Status ($VALET_VERSION on $VALET_OS):"
    echo "Plugin Manager: $VALET_PLUGIN_MANAGER"
    echo "============================================="
    
    # Check if valet is installed
    if ! command -v valet >/dev/null 2>&1; then
        echo "❌ Valet is not installed"
        if [[ "$VALET_OS" == "macOS" ]]; then
            echo "📖 Install guide: https://laravel.com/docs/valet"
        else
            echo "📖 Install guide: https://cpriego.github.io/valet-linux/"
        fi
        return 1
    fi
    
    echo "✅ Valet is installed"
    
    # Check services (OS-specific)
    local services=($(_valet_get_services))
    for service in "${services[@]}"; do
        if _valet_check_service_status "$service"; then
            echo "✅ $service is running"
        else
            echo "❌ $service is not running"
        fi
    done
    
    # Show current domain/TLD
    local domain=$(valet domain 2>/dev/null || echo "unknown")
    echo "🌐 Domain: $domain"
    
    # Show linked sites count
    local links_count=$(valet links 2>/dev/null | wc -l)
    echo "🔗 Linked sites: $links_count"
    
    # Show parked paths count
    local paths_count=$(valet paths 2>/dev/null | wc -l)
    echo "📁 Parked paths: $paths_count"
    
    # Show PHP version if available
    if command -v php >/dev/null 2>&1; then
        local php_version=$(php -v 2>/dev/null | head -n1 | grep -oE 'PHP [0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        echo "🐘 PHP: $php_version"
    fi
}

valet-logs() {
    if ! command -v valet >/dev/null 2>&1; then
        echo "❌ Laravel Valet is not installed"
        return 1
    fi
    
    local service=${1:-nginx}
    
    case $service in
        nginx)
            echo "📋 Nginx Error Log:"
            echo "==================="
            
            if [[ "$VALET_OS" == "macOS" ]]; then
                # macOS Homebrew paths
                local nginx_log_paths=(
                    "/opt/homebrew/var/log/nginx/error.log"  # Apple Silicon
                    "/usr/local/var/log/nginx/error.log"    # Intel
                )
                
                for log_path in "${nginx_log_paths[@]}"; do
                    if [[ -f "$log_path" ]]; then
                        tail -f "$log_path"
                        return
                    fi
                done
                echo "❌ Nginx error log not found"
            else
                # Linux paths
                if [[ -f /var/log/nginx/error.log ]]; then
                    tail -f /var/log/nginx/error.log
                else
                    echo "❌ Nginx error log not found at /var/log/nginx/error.log"
                fi
            fi
            ;;
        php|php-fpm)
            echo "📋 PHP-FPM Log:"
            echo "==============="
            
            if [[ "$VALET_OS" == "macOS" ]]; then
                # macOS PHP logs
                local php_log_paths=(
                    "/opt/homebrew/var/log/php-fpm.log"
                    "/usr/local/var/log/php-fpm.log"
                )
                
                for log_path in "${php_log_paths[@]}"; do
                    if [[ -f "$log_path" ]]; then
                        tail -f "$log_path"
                        return
                    fi
                done
                echo "❌ PHP-FPM log not found"
            else
                # Linux - find active PHP-FPM version
                local php_version=""
                for version in 8.4 8.3 8.2 8.1 8.0 7.4; do
                    if systemctl is-active --quiet "php${version}-fpm" 2>/dev/null; then
                        php_version=$version
                        break
                    fi
                done
                
                if [[ -n $php_version ]]; then
                    local log_file="/var/log/php${php_version}-fpm.log"
                    if [[ -f $log_file ]]; then
                        tail -f "$log_file"
                    else
                        echo "❌ PHP-FPM log not found at $log_file"
                    fi
                else
                    echo "❌ No active PHP-FPM service found"
                fi
            fi
            ;;
        *)
            if [[ "$VALET_OS" == "macOS" ]]; then
                echo "📋 Available logs: nginx, php"
            else
                echo "📋 Available logs: nginx, php-fpm"
            fi
            echo "Usage: vlog [nginx|php]"
            ;;
    esac
}

# Cross-platform info function
valet-info() {
    echo "🔍 Valet Environment Information:"
    echo "================================="
    echo "Operating System: $VALET_OS"
    echo "Valet Version: $VALET_VERSION"
    echo "Plugin Manager: $VALET_PLUGIN_MANAGER"
    echo "Plugin Directory: $VALET_PLUGIN_DIR"
    echo ""
    
    if command -v valet >/dev/null 2>&1; then
        echo "Valet Binary: $(which valet)"
        echo "Valet Version Output:"
        valet --version 2>/dev/null || echo "Version info not available"
    else
        echo "Valet Binary: Not found"
    fi
    
    echo ""
    echo "PHP Information:"
    if command -v php >/dev/null 2>&1; then
        echo "PHP Binary: $(which php)"
        echo "PHP Version: $(php -v 2>/dev/null | head -n1 || echo 'Not available')"
    else
        echo "PHP Binary: Not found"
    fi
}

# Plugin update function
valet-plugin-update() {
    if [[ "$VALET_PLUGIN_AUTO_UPDATE" == "true" ]] && [[ -d "$VALET_PLUGIN_DIR/.git" ]]; then
        echo "🔄 Updating Universal Valet Zsh Plugin..."
        (cd "$VALET_PLUGIN_DIR" && git pull --quiet)
        echo "✅ Plugin updated! Restart your shell to apply changes."
    else
        echo "Auto-update is disabled. Set VALET_PLUGIN_AUTO_UPDATE=true to enable."
        if [[ -d "$VALET_PLUGIN_DIR/.git" ]]; then
            echo "Manual update: cd $VALET_PLUGIN_DIR && git pull"
        fi
    fi
}

# Aliases for common operations
alias vl='valet links'
alias vp='valet paths'
alias vs='valet-status'
alias vo='valet-open'
alias vlh='valet-link-here'
alias vsh='valet-secure-here'
alias vlog='valet-logs'
alias vinfo='valet-info'
alias vpu='valet-plugin-update'

# Plugin initialization message
if [[ "$VALET_PLUGIN_SILENT_LOAD" != "true" ]] && [[ -o interactive ]]; then
    if command -v valet >/dev/null 2>&1; then
        echo "🚀 Universal Valet Zsh Plugin loaded!"
        echo "   Detected: $VALET_VERSION on $VALET_OS (via $VALET_PLUGIN_MANAGER)"
        echo "   Try: vs (status), vo (open), vlh (link here), vinfo (environment info)"
    fi
fi
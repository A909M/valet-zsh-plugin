#compdef valet

# Valet Linux Zsh Plugin
# Provides autocompletion and helper functions for Laravel Valet on Linux

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
                    _arguments \
                        '*:service:(nginx dnsmasq php-fpm)'
                    ;;
                stop)
                    _arguments \
                        '*:service:(nginx dnsmasq php-fpm)'
                    ;;
                restart)
                    _arguments \
                        '*:service:(nginx dnsmasq php-fpm)'
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
                    _arguments \
                        '1:service:(nginx php-fpm)'
                    ;;
                trust)
                    # No additional arguments
                    ;;
                domain)
                    _arguments \
                        '1:domain:'
                    ;;
                tld)
                    _arguments \
                        '1:tld:'
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
                    _arguments \
                        '1:version:(7.4 8.0 8.1 8.2 8.3)'
                    ;;
                which-php)
                    _valet_linked_sites
                    ;;
                db)
                    _arguments \
                        '1:action:(create drop list connect)'
                    ;;
                fetch-share-url)
                    _valet_linked_sites
                    ;;
                on-latest-version)
                    # No additional arguments
                    ;;
            esac
            ;;
    esac
}

# Get available valet commands
_valet_commands() {
    local commands
    commands=(
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
        'db:Create, drop, or list databases'
        'on-latest-version:Check if Valet is on the latest version'
    )
    _describe 'valet commands' commands
}

# Get linked sites
_valet_linked_sites() {
    local sites
    if [[ -f ~/.config/valet/config.json ]]; then
        sites=(${(f)"$(valet links 2>/dev/null | grep -E '^\s*[a-zA-Z0-9]' | awk '{print $1}' | grep -v '^$')"})
        _describe 'linked sites' sites
    fi
}

# Get parked directories
_valet_parked_directories() {
    local paths
    if command -v valet >/dev/null 2>&1; then
        paths=(${(f)"$(valet paths 2>/dev/null | grep -v '^$')"})
        _describe 'parked directories' paths
    fi
}

# Get secured sites
_valet_secured_sites() {
    local sites
    if command -v valet >/dev/null 2>&1; then
        sites=(${(f)"$(valet links 2>/dev/null | grep 'https://' | awk '{print $1}' | grep -v '^$')"})
        _describe 'secured sites' sites
    fi
}

# Get unsecured sites
_valet_unsecured_sites() {
    local sites
    if command -v valet >/dev/null 2>&1; then
        sites=(${(f)"$(valet links 2>/dev/null | grep 'http://' | awk '{print $1}' | grep -v '^$')"})
        _describe 'unsecured sites' sites
    fi
}

# Get isolated sites
_valet_isolated_sites() {
    local sites
    if command -v valet >/dev/null 2>&1; then
        sites=(${(f)"$(valet isolated 2>/dev/null | grep -E '^\s*[a-zA-Z0-9]' | awk '{print $1}' | grep -v '^$')"})
        _describe 'isolated sites' sites
    fi
}

# Helper functions
valet-link-here() {
    local name=${1:-$(basename $PWD)}
    echo "Linking current directory as: $name"
    valet link "$name"
}

valet-secure-here() {
    local name=${1:-$(basename $PWD)}
    echo "Securing site: $name"
    valet secure "$name"
}

valet-open() {
    local site=${1:-$(basename $PWD)}
    local tld=$(valet domain 2>/dev/null | grep -oE '\.[a-z]+$' || echo '.test')
    local protocol="http"
    
    # Check if site is secured
    if valet links 2>/dev/null | grep -q "https://$site$tld"; then
        protocol="https"
    fi
    
    local url="$protocol://$site$tld"
    echo "Opening: $url"
    
    # Try different browser commands
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$url"
    elif command -v google-chrome >/dev/null 2>&1; then
        google-chrome "$url"
    elif command -v firefox >/dev/null 2>&1; then
        firefox "$url"
    else
        echo "No suitable browser found. URL: $url"
    fi
}

valet-status() {
    echo " Valet Status:"
    echo "=================="
    
    # Check if valet is installed
    if ! command -v valet >/dev/null 2>&1; then
        echo "❌ Valet is not installed"
        return 1
    fi
    
    echo "✅ Valet is installed"
    
    # Check services
    local services=("nginx" "dnsmasq")
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            echo "✅ $service is running"
        else
            echo "❌ $service is not running"
        fi
    done
    
    # Check PHP-FPM (multiple versions possible)
    local php_running=false
    for php_version in 7.4 8.0 8.1 8.2 8.3; do
        if systemctl is-active --quiet "php${php_version}-fpm" 2>/dev/null; then
            echo "✅ php${php_version}-fpm is running"
            php_running=true
        fi
    done
    
    if ! $php_running; then
        echo "❌ No PHP-FPM service is running"
    fi
    
    # Show current domain/TLD
    local domain=$(valet domain 2>/dev/null || echo "unknown")
    echo " Domain: $domain"
    
    # Show linked sites count
    local links_count=$(valet links 2>/dev/null | wc -l)
    echo " Linked sites: $links_count"
    
    # Show parked paths count
    local paths_count=$(valet paths 2>/dev/null | wc -l)
    echo " Parked paths: $paths_count"
}

valet-logs() {
    local service=${1:-nginx}
    case $service in
        nginx)
            echo " Nginx Error Log:"
            echo "==================="
            tail -f /var/log/nginx/error.log
            ;;
        php|php-fpm)
            echo " PHP-FPM Log:"
            echo "==============="
            # Find the active PHP-FPM version
            local php_version=""
            for version in 8.3 8.2 8.1 8.0 7.4; do
                if systemctl is-active --quiet "php${version}-fpm" 2>/dev/null; then
                    php_version=$version
                    break
                fi
            done
            
            if [[ -n $php_version ]]; then
                tail -f "/var/log/php${php_version}-fpm.log"
            else
                echo "No active PHP-FPM service found"
            fi
            ;;
        *)
            echo "Available logs: nginx, php"
            ;;
    esac
}

# Aliases for common operations
alias vl='valet links'
alias vp='valet paths'
alias vs='valet-status'
alias vo='valet-open'
alias vlh='valet-link-here'
alias vsh='valet-secure-here'
alias vlog='valet-logs'

# Set up completion
compdef _valet valet

# Plugin initialization message
if [[ -o interactive ]]; then
    echo " Valet Linux Zsh Plugin loaded!"
    echo "   Try: vs (status), vo (open), vlh (link here), vsh (secure here)"
fi
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a universal Zsh plugin for Laravel Valet that provides smart autocompletion, aliases, and helper functions. It's designed to work with both Laravel Valet (Official) on macOS and Valet Linux on Ubuntu/Debian systems.

## Core Architecture

### Main Plugin File (`valet.plugin.zsh`)
- **Environment Detection**: Lines 19-54 handle OS and Valet version detection via `_valet_detect_environment()`
- **Plugin Manager Detection**: Lines 62-80 detect which Zsh plugin manager is being used
- **Lazy Loading**: Lines 122-148 implement lazy loading when Valet isn't installed
- **Service Management**: Lines 83-119 provide OS-specific service status checking
- **Tab Completion**: Lines 152-376 implement comprehensive Zsh completion system
- **Helper Functions**: Lines 382-627 provide cross-platform utility functions
- **Aliases**: Lines 629-638 define convenient shortcuts

### Key Global Variables
- `VALET_OS`: Detected operating system ("macOS" or "Linux") - backward compatibility
- `VALET_VERSION`: Detected Valet type ("Laravel Valet (Official)" or "Valet Linux") - backward compatibility
- `VALET_PLUGIN_MANAGER`: Detected plugin manager - backward compatibility
- `VALET_PLUGIN_DIR`: Plugin installation directory
- `Plugins[valet_os]`: Operating system (new preferred method)
- `Plugins[valet_version]`: Valet version (new preferred method)
- `Plugins[valet_plugin_manager]`: Plugin manager (new preferred method)

### Configuration Variables (User Configurable)
- `VALET_PLUGIN_AUTO_UPDATE` / `Plugins[valet_auto_update]`: Enable automatic plugin updates
- `VALET_PLUGIN_SILENT_LOAD` / `Plugins[valet_silent_load]`: Suppress loading messages
- `VALET_PLUGIN_DEFAULT_TLD` / `Plugins[valet_default_tld]`: Default TLD for site opening

## Development Commands

### Testing
```bash
# Run comprehensive compatibility tests
./test-compatibility.sh

# Test plugin loading manually
zsh -c "source valet.plugin.zsh && valet-status"

# Test specific functions
zsh -c "source valet.plugin.zsh && type valet-open"
```

### Plugin Testing
```bash
# Test syntax validation
zsh -n valet.plugin.zsh

# Test with silent loading
VALET_PLUGIN_SILENT_LOAD=true zsh -c "source valet.plugin.zsh"

# Test error handling (without valet installed)
PATH=/usr/bin:/bin zsh -c "source valet.plugin.zsh && valet-status"
```

## Platform-Specific Behavior

### Service Management
- **macOS**: Uses `brew services` for service status checking
- **Linux**: Uses `systemctl` for service management
- Service names differ: `php` vs `php-fpm`, automatic PHP version detection on Linux

### Log File Paths
- **macOS**: `/opt/homebrew/var/log/` or `/usr/local/var/log/` (Intel vs Apple Silicon)
- **Linux**: `/var/log/nginx/` and `/var/log/php{version}-fpm.log`

### Browser Opening
- **macOS**: Uses `open` command
- **Linux**: Falls back through `xdg-open`, `google-chrome`, `firefox`, `chromium`

## Supported Valet Commands

### Common Commands (Both macOS and Linux)
- `install`, `uninstall`, `start`, `stop`, `restart` - Service management
- `park`, `unpark`, `paths` - Directory management
- `link`, `unlink`, `links` - Site linking
- `secure`, `unsecure` - HTTPS management
- `share`, `fetch-share-url` - Public sharing
- `log` - Log viewing
- `trust` - Certificate management
- `domain`, `tld` - Configuration
- `isolate`, `unisolate`, `isolated` - PHP version isolation
- `php`, `which-php` - PHP management
- `on-latest-version` - Update checking
- `list` - Command listing
- `diagnose` - Diagnostic information
- `forget` - Remove parked directories

### macOS-Specific Commands
- `use` - Switch PHP versions via Homebrew
- `loopback` - Create loopback alias
- `directory-listing` - Control directory listing behavior

### Linux-Specific Commands  
- `status` - Show service status
- `port` - Change or view Nginx port

### Removed Invalid Commands
- `valet db` commands - These were from Valet Plus, not standard Valet Linux

## Function Categories

### Core Helper Functions (valet.plugin.zsh:400-640)
- `@valet-link-here()`: Links current directory to Valet
- `@valet-secure-here()`: Secures current site with HTTPS
- `@valet-open()`: Opens site in browser with protocol detection
- `@valet-status()`: Comprehensive status overview with accurate counting
- `@valet-logs()`: Platform-specific log viewing
- `@valet-info()`: Environment and version information

### Completion Helpers (valet.plugin.zsh:344-382)
- `_valet_linked_sites()`: Gets linked sites for completion (improved parsing)
- `_valet_secured_sites()`: Gets HTTPS sites for unsecure command (improved parsing)
- `_valet_unsecured_sites()`: Gets HTTP sites for secure command (improved parsing)
- `_valet_parked_directories()`: Gets parked paths (improved parsing)
- `_valet_isolated_sites()`: Gets isolated sites (improved parsing)

## Code Patterns

### Error Handling
All functions check for Valet installation and provide helpful error messages with platform-specific installation instructions.

### Cross-Platform Compatibility
Functions use `$VALET_OS` variable to branch behavior:
```bash
if [[ "$VALET_OS" == "macOS" ]]; then
    # macOS-specific code
else
    # Linux-specific code
fi
```

### Service Detection Pattern
Service checking follows the pattern in `_valet_check_service_status()` with OS-specific implementations for macOS (brew services) vs Linux (systemctl).

## Important Implementation Details

- Plugin uses lazy loading to avoid performance impact when Valet isn't installed
- Completion system is comprehensive and works with both Valet versions
- All helper functions provide cross-platform compatibility
- Service management accounts for different service names and management tools
- Log viewing automatically detects correct paths and active PHP versions
- Browser opening has extensive fallback mechanisms for Linux environments

## Aliases Reference
- `vs` → `@valet-status`
- `vo` → `@valet-open`  
- `vlh` → `@valet-link-here`
- `vsh` → `@valet-secure-here`
- `vl` → `valet links`
- `vp` → `valet paths`
- `vlog` → `@valet-logs`
- `vinfo` → `@valet-info`
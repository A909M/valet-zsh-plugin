# Valet Zsh Plugin




A comprehensive Zsh plugin that works with both **[Laravel Valet (Official)](https://laravel.com/docs/valet)** on macOS and **[Valet Linux](https://cpriego.github.io/valet-linux/)** on Ubuntu/Debian. Provides intelligent autocompletion, helpful aliases, and utility functions to streamline your local development workflow.

# All valet commands have smart completion
    valet <TAB>
    valet link <TAB>      # Shows available options
    valet secure <TAB>    # Shows unsecured sites
    valet unsecure <TAB>  # Shows secured sites

## ✨ Features

- 🌍 **Universal Compatibility** - Works with both Laravel Valet (macOS) and Valet Linux
- 🔄 **Smart Tab Completion** - Context-aware autocompletion for all Valet commands
- 🚀 **Quick Status Check** - Instant overview of Valet services and configuration
- 🌐 **Cross-Platform Site Opening** - Open current directory's site in your browser
- 🔗 **Easy Site Management** - Quick link/secure operations from any directory
- 📊 **Service Monitoring** - Real-time log viewing (adapts to your OS)
- ⚡ **Performance Optimized** - Lazy loading for faster shell startup
- 🔧 **Multi Plugin Manager Support** - Works with all major Zsh plugin managers
- 🔍 **Environment Detection** - Automatically detects your Valet version and OS

## 📋 Requirements

- **Zsh** shell
- **Laravel Valet** (either version):
  - **macOS**: [Laravel Valet (Official)](https://laravel.com/docs/valet)
  - **Linux**: [Valet Linux](https://cpriego.github.io/valet-linux/) on Ubuntu/Debian
- **Compatible OS**: macOS 10.15+ or Ubuntu 18.04+/Debian 10+

## 🚀 Installation

### Oh My Zsh

```bash
git clone https://github.com/a909m/valet-zsh-plugin.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/valet
```

Add `valet` to your plugins in `~/.zshrc`:
```bash
plugins=(... valet)
```

### Zinit

```bash
# Add to ~/.zshrc
zinit load "a909m/valet-zsh-plugin"

# Or with lazy loading for better performance
zinit ice wait lucid has'valet'
zinit load "a909m/valet-zsh-plugin"
```

### Antigen

```bash
# Add to ~/.zshrc
antigen bundle a909m/valet-zsh-plugin
antigen apply
```

### Zplug

```bash
# Add to ~/.zshrc
zplug "a909m/valet-zsh-plugin", defer:2
```

### Manual Installation

```bash
git clone https://github.com/a909m/valet-zsh-plugin.git ~/.zsh/plugins/valet
echo "source ~/.zsh/plugins/valet/valet.plugin.zsh" >> ~/.zshrc
```

Then reload your shell:
```bash
source ~/.zshrc
```

## 🎯 Usage

### Quick Commands

| Alias | Command | Description |
|-------|---------|-------------|
| `vs` | `valet-status` | Show comprehensive Valet status |
| `vo` | `valet-open` | Open current site in browser |
| `vlh` | `valet-link-here` | Link current directory |
| `vsh` | `valet-secure-here` | Secure current site with HTTPS |
| `vl` | `valet links` | List all linked sites |
| `vp` | `valet paths` | List all parked paths |
| `vlog` | `valet-logs` | View service logs |
| `vinfo` | `valet-info` | Show environment information |

### Examples

```bash
# Quick status check
vs

# Link current directory as 'myproject'
vlh myproject

# Open current site in browser
vo

# Secure current site
vsh

# View nginx error logs
vlog nginx

# View PHP-FPM logs
vlog php

# All valet commands have smart completion
valet <TAB>
valet link <TAB>      # Shows available options
valet secure <TAB>    # Shows unsecured sites
valet unsecure <TAB>  # Shows secured sites
```

### Helper Functions

#### `valet-status` (`vs`)
Displays a comprehensive overview of your Valet installation with OS-specific service detection:

**macOS Output:**
```
🚀 Valet Status (Laravel Valet (Official) on macOS):
Plugin Manager: oh-my-zsh
=============================================
✅ Valet is installed
✅ nginx is running
✅ dnsmasq is running
✅ php is running
🌐 Domain: .test
🔗 Linked sites: 5
📁 Parked paths: 2
🐘 PHP: PHP 8.2.0
```

**Linux Output:**
```
🚀 Valet Status (Valet Linux on Linux):
Plugin Manager: zinit
============================================
✅ Valet is installed
✅ nginx is running
✅ dnsmasq is running
✅ php8.1-fpm is running
🌐 Domain: .test
🔗 Linked sites: 5
📁 Parked paths: 2
🐘 PHP: PHP 8.1.2
```

#### `valet-open` (`vo`)
Opens the current directory's site in your default browser. Automatically detects HTTP/HTTPS and handles different browsers across platforms (uses `open` on macOS, `xdg-open` on Linux).

#### `valet-info` (`vinfo`)
Shows detailed environment information:
```
🔍 Valet Environment Information:
=================================
Operating System: macOS
Valet Version: Laravel Valet (Official)
Plugin Manager: oh-my-zsh
Plugin Directory: ~/.oh-my-zsh/custom/plugins/valet

Valet Binary: /usr/local/bin/valet
Valet Version Output: Laravel Valet 3.3.2

PHP Information:
PHP Binary: /opt/homebrew/bin/php
PHP Version: PHP 8.2.0 (cli)
```

#### `valet-link-here` (`vlh`)
Links the current directory to Valet. Optionally accepts a custom name:
```bash
vlh                    # Links as current directory name
vlh custom-name        # Links as 'custom-name'
```

#### `valet-logs` (`vlog`)
View real-time logs for Valet services with OS-specific paths:

**macOS:**
```bash
vlog nginx    # View Nginx logs from Homebrew paths
vlog php      # View PHP-FPM logs from Homebrew paths
```

**Linux:**
```bash
vlog nginx    # View Nginx error logs from /var/log/nginx/
vlog php-fpm  # View PHP-FPM logs (auto-detects active version)
```


```bash
# Disable loading message
export VALET_PLUGIN_SILENT_LOAD=true

# Enable auto-updates (if plugin is git-cloned)
export VALET_PLUGIN_AUTO_UPDATE=true

# Set default TLD for valet-open function
export VALET_PLUGIN_DEFAULT_TLD=test
```

## 🌍 Platform-Specific Features

### macOS (Laravel Valet Official)
- Uses Homebrew service management (`brew services`)
- Supports `valet use` command for PHP version switching
- Automatically detects Homebrew paths for logs
- Uses `open` command for browser launching

### Linux (Valet Linux)
- Uses systemctl for service management
- Supports `valet status` command
- Includes database management commands (`valet db`)
- Detects multiple PHP-FPM versions automatically
- Uses `xdg-open` for browser launching

## ⚙️ Configuration

Customize the plugin behavior with environment variables in your `~/.zshrc`:
```bash
# Disable loading message
export VALET_PLUGIN_SILENT_LOAD=true

# Enable auto-updates (if plugin is git-cloned)
export VALET_PLUGIN_AUTO_UPDATE=true

# Set default TLD for valet-open function
export VALET_PLUGIN_DEFAULT_TLD=test
```
### Adding Custom Functions

Extend the plugin by adding your own functions to `~/.zshrc`:

```bash
# Custom function to quickly restart all Valet services
valet-restart-all() {
    echo "🔄 Restarting all Valet services..."
    valet restart
    echo "✅ All services restarted!"
}

# Quick database creation for current project (Linux only)
valet-db-create() {
    if [[ "$VALET_OS" == "Linux" ]]; then
        local db_name=${1:-$(basename $PWD)}
        echo "🗄️  Creating database: $db_name"
        valet db create "$db_name"
    else
        echo "Database commands are only available on Valet Linux"
    fi
}

# Platform-specific PHP switching
valet-switch-php() {
    local version=$1
    if [[ "$VALET_OS" == "macOS" ]]; then
        valet use "$version"
    else
        valet php "$version"
    fi
}
```

### Custom Aliases

Add your own aliases:

```bash
alias vr='valet restart'
alias vdb='valet db'
alias vphp='valet php'
```

## 🔧 Troubleshooting

### Plugin Not Loading

1. **Check Valet Installation:**
   ```bash
   which valet
   valet --version
   
   # Check plugin detection
   vinfo
   ```

2. **Verify Plugin Location:**
   ```bash
   # For Oh My Zsh
   ls -la ~/.oh-my-zsh/custom/plugins/valet/
   
   # For manual installation
   ls -la ~/.zsh/plugins/valet/
   ```

3. **Test Plugin Manually:**
   ```bash
   source path/to/valet.plugin.zsh
   ```

### Platform-Specific Issues

#### macOS Issues
- **Homebrew not found**: Ensure Homebrew is installed and in PATH
- **Services not starting**: Check `brew services list`
- **PHP version conflicts**: Use `valet use php@8.2` to specify version

#### Linux Issues  
- **SystemD services**: Ensure you have permission to check service status
- **Multiple PHP versions**: Plugin auto-detects active PHP-FPM version
- **Log file permissions**: Add user to appropriate groups:
  ```bash
  sudo usermod -a -G adm $USER
  sudo usermod -a -G www-data $USER
  ```

### Completion Not Working

1. **Reload completion system:**
   ```bash
   rm ~/.zcompdump*
   exec zsh
   ```

2. **Check if completion is registered:**
   ```bash
   complete -p valet
   ```

3. **Test completion manually:**
   ```bash
   # Type and press TAB
   valet <TAB>
   valet link <TAB>
   ```

### Permission Issues

If you encounter permission issues with logs:

```bash
# macOS (if using custom Homebrew installation)
sudo chown -R $(whoami) /opt/homebrew/var/log/
sudo chown -R $(whoami) /usr/local/var/log/

# Linux
sudo usermod -a -G adm $USER
sudo usermod -a -G www-data $USER

# Logout and login again for group changes to take effect
```

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** your changes: `git commit -m 'Add amazing feature'`
4. **Push** to the branch: `git push origin feature/amazing-feature`
5. **Open** a Pull Request

### Development Setup

```bash
# Clone your fork
git clone https://github.com/a909m/universal-valet-zsh-plugin.git
cd universal-valet-zsh-plugin

# Test the plugin on your platform
zsh -c "source valet.plugin.zsh && valet-status"
zsh -c "source valet.plugin.zsh && vinfo"

# Run tests (if available)
./test-compatibility.sh
```

### Adding New Features

When adding new features:

- Follow existing naming conventions (`valet-*` for functions)
- Add appropriate completion support for both platforms
- Use OS detection (`$VALET_OS` and `$VALET_VERSION`) for platform-specific code
- Update the README with examples for both macOS and Linux
- Test with multiple plugin managers
- Ensure backward compatibility

## 📝 Changelog

### v1.0.0 (2025-08-01)
- Initial release with universal compatibility
- Smart tab completion for all Valet commands (macOS & Linux)
- Cross-platform helper functions and aliases
- Multi plugin manager support
- Lazy loading for better performance
- Automatic OS and Valet version detection
- Platform-specific service management and log viewing

## 🐛 Known Issues

- **WSL Users**: Some browser opening functions may not work in WSL environments
- **Service Detection**: Service management commands may vary on different Linux distributions
- **Log Paths**: Log file paths might differ on non-standard installations
- **macOS ARM vs Intel**: Plugin auto-detects Homebrew paths for both architectures
- **Multiple PHP Versions**: Linux users with multiple PHP-FPM versions - plugin detects the active one

## 📚 Related Projects

- [Laravel Valet (Official)](https://laravel.com/docs/valet) - The original macOS Valet
- [Valet Linux](https://cpriego.github.io/valet-linux/) - The Linux port by Carlos Priego
- [Oh My Zsh](https://ohmyz.sh/) - Framework for managing Zsh configuration
- [Zinit](https://github.com/zdharma-continuum/zinit) - Fast Zsh plugin manager

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Created with assistance from Claude AI
- Inspired by the Laravel Valet community
- Thanks to all contributors and testers

## 💬 Support

- 🐛 **Bug Reports**: [Open an issue](https://github.com/a909m/universal-valet-zsh-plugin/issues)
- 💡 **Feature Requests**: [Start a discussion](https://github.com/a909m/universal-valet-zsh-plugin/discussions)
- 📖 **Documentation**: Check the [Wiki](https://github.com/a909m/universal-valet-zsh-plugin/wiki)

---

<div align="center">

**[⭐ Star this repo](https://github.com/a909m/universal-valet-zsh-plugin)** if you find it useful!

Made with ❤️ for the Laravel community

*Compatible with Laravel Valet (macOS) and Valet Linux*

</div>
# Valet Zsh Plugin

A Zsh plugin for [Laravel Valet](https://laravel.com/docs/master/valet) on Linux. Provides autocompletion, helper functions, and aliases to streamline your Valet workflow.

## Features

-   **Autocompletion:** Comprehensive tab completion for all `valet` commands and their arguments (sites, paths, etc.).
-   **Helper Functions:**
    -   `valet-status` (`vs`): A detailed status overview of Valet services (Nginx, DnsMasq, PHP-FPM).
    -   `valet-open` (`vo`): Open the current project's Valet site in your default browser.
    -   `valet-link-here` (`vlh`): Link the current directory to Valet.
    -   `valet-secure-here` (`vsh`): Secure the current site with TLS.
    -   `valet-logs` (`vlog`): Tail Nginx or PHP-FPM logs.
-   **Aliases:**
    -   `vl`: `valet links`
    -   `vp`: `valet paths`

## Installation

### For Oh My Zsh users

1.  Clone this repository into your Oh My Zsh custom plugins directory:
    ```sh
    git clone https://github.com/<your-username>/valet-zsh-plugin.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/valet
    ```

2.  Add `valet` to the plugins list in your `~/.zshrc` file:
    ```zsh
    plugins=(... valet)
    ```

3.  Restart your shell or source your `~/.zshrc` file:
    ```sh
    source ~/.zshrc
    ```

### For other plugin managers (Antigen, Zgen, etc.)

Add the following to your `.zshrc` file, replacing with your repository URL:

```zsh
# Example for Antigen
antigen bundle <your-username>/valet-zsh-plugin
```

## Usage

-   Type `valet ` and press `<Tab>` to see available commands.
-   Use the helper functions and aliases for common tasks:
    -   `vs` to check the status of Valet.
    -   `vo` to open the current site in a browser.
    -   `vlh` to link your current project directory.

## Publishing

To publish this plugin:

1.  Create a new repository on GitHub.
2.  Push the code to the repository.
3.  Register your plugin with Zsh plugin managers like Oh My Zsh by submitting a pull request to their repositories.

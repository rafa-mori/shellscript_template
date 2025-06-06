# Secure and Modular Bash Script Template

> **License:** GNU AGPL-3.0-or-later  
> **Copyright (C) 2025 Rafael Mori**  
> **Inspired by Adrelanos' helper-scripts for Whonix ([link to repository](https://github.com/Whonix/helper-scripts))**

This repository provides a robust template for writing secure, modular, and maintainable Bash scripts. It includes best practices for error handling, logging, colored output, and secure environment configuration. The structure is designed to avoid common pitfalls, such as accidental execution as root, function name collisions, and improper sourcing.

## Key Features

- **Security First**: Prevents execution as root or via sudo and applies safe shell options (`errexit`, `nounset`, `pipefail`).
- **Modular Design**: Functions with prefixes and selective export to avoid polluting the global namespace.
- **Logging & Colors**: Integrated logger with color support, terminal background detection, and high contrast for a better experience.
- **Wrapper Example**: Demonstrates how to create a secure entry point, routing arguments and validating the environment.
- **Extensible Utilities**: Includes utilities for user prompts, secret input, and terminal buffer management.

## Usage Example

```bash
# Using the secure wrapper
./examples/secure_wrapper.sh 2 arg1 arg2
```

This will safely route execution to the appropriate script and function, ensuring all validations and logging.

## How to Use

1. **Copy the template scripts** to your project.
2. **Replace all `myname` prefixes** with your script name.
3. **Customize the wrapper** as needed.
4. **Take advantage of the logger and color utilities** for consistent output and error handling.

## Why use this template?

- Avoids common errors in shell scripting.
- Eases maintenance and extension of scripts.
- Provides a professional base for automation, DevOps, and CI/CD tasks.

---

### Share with the Community

Feel free to use this template as a basis for your own scripts and share improvements or use cases with the community via Gist, DEV.to, or other platforms!

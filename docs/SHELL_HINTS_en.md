# Best Practices for Robustness and Resilience in Shell Scripting

Shell scripting is a nuanced art – and it’s those small details that often make the difference between a script that barely works and a truly robust, reliable tool. Over the years, I have developed (and continue to develop) several techniques to improve my scripts. Here’s a consolidated guide on best practices and advanced insights that will benefit both beginners and seasoned developers.

### 1. `printf` vs. `echo`
While `echo` is convenient, its behavior can vary across shells. On the other hand, `printf` is a built-in command that reliably formats and prints exactly what you specify.  
**Tip:** Use `printf` when you need precise control over the output. Just remember to add `\n` for newlines.

```bash
# Example:
printf "Process started...\n"
```

### 2. Returning Values from Functions
To “return” a value from a function, use `echo` to print the value and capture it.  
**Note:** Ensure that logging messages do not pollute the standard output. Redirect logs to stderr so that the function’s return value remains pure.

### 3. Avoiding `exit` in Sourced Scripts
When you source a script (using `source` or `.`), avoid using `exit` outside of error-critical blocks, as this will terminate the calling shell’s execution.  
**Best Practices:**
- Use `return` with error codes within functions.
- Reserve `exit` only for terminal failures.

### 4. Exporting Functions with `export -f`
When using functions in subprocesses (for example, with GNU/Parallel), ensure they are exported using `export -f`. Without this, functions defined in a sourced script might be unavailable in child processes, causing hard-to-debug errors.

```bash
my_function() {
  echo "Exported function works correctly"
}
export -f my_function
```

### 5. Defining Default Values for Variables
Always use syntax like `${VAR:-default}` to guarantee that your script has fallback values when variables are not set.

```bash
# Example:
destination_directory="${DEST_DIR:-/usr/local/bin}"
```

### 6. Variable Naming Conventions
- **Local variables (inside functions):**  
  Use lowercase letters, and preferably start with an underscore (e.g., `_my_variable`) to prevent conflicts with environment variables.
- **Public or exported variables:**  
  Use uppercase letters and snake_case. For variables that only exist during execution, consider adding a prefix or suffix to denote their temporary nature and mark them as `readonly` before exporting.

### 7. Reliable Shell Detection
Identifying the current shell can be tricky. Use a robust function like this one, which checks `/proc/$$/comm` and analyzes the shebang:

```bash
get_current_shell() {
  local shell_proc
  shell_proc=$(cat /proc/$$/comm)
  case "${0##*/}" in
    ${shell_proc}*)
      local shebang
      shebang=$(head -1 "$0")
      printf '%s\n' "${shebang##*/}"
      ;;
    *)
      printf '%s\n' "$shell_proc"
      ;;
  esac
}
```

This method avoids common pitfalls associated with using `$0` or `$BASH_SOURCE`, ensuring accurate shell detection—which is critical for context-dependent setups (like running `sudo -v`).

### 8. Versatile Command and Package Verification
Relying on a single command to check if something exists can be risky, as a package may include multiple commands or binaries. Instead, combine methods:
- **`command -v` or `which`**: Check if the command exists in PATH.
- **`type -a`**: List all occurrences of the command (alias, function, etc.).
- **`compgen -c`**: Lists available commands.
- For Debian-based systems, use `dpkg-query` to verify package installation.

```bash
check_command() {
  local cmd="$1"
  if command -v "$cmd" > /dev/null 2>&1 || type -a "$cmd" > /dev/null 2>&1 || compgen -c "$cmd" > /dev/null 2>&1; then
      return 0
  else
      printf "Error: Command '%s' not found.\n" "$cmd" >&2
      return 1
  fi
}
```

### 9. The Final Touch: Blank Line at the End of the File
It might seem trivial, but always ending your script with a blank line is crucial. Some interpreters handle the end-of-file differently if the last line lacks a newline, leading to unexpected errors.

---

## Conclusion

Embracing these practices—from choosing `printf` over `echo`, to robustly checking for commands, carefully setting default values, and detecting the current shell—can mean the difference between a script that “just works” and one that is truly resilient and portable. These details, often overlooked, can save you hours of debugging and ensure predictability in even the most complex environments.

Whether you’re just starting out or you’re a veteran who’s seen it all, refining these practices can elevate your work to the next level. Sharing this knowledge will help strengthen the community by raising the bar for quality shell scripting.

I sincerely hope to be helping and collaborating so that your shell scripts and logic achieve - with small details - your great purposes!


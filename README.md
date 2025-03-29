# Screenlocked

Screenlocked is a macOS command-line utility written in Swift that checks if the screen is locked. It provides both exit codes and textual output to integrate smoothly with other scripts and command line workflows.

## Usage

Run `screenlocked --help` to see full usage information:

```
Usage: screenlocked [options]

Options:
  --print     Print lock status (instead of exit code)
  --help      Show this help message
  --version   Show version information

Exit Codes:
  0 - Screen is locked (or always 0 when using --print)
  1 - Screen is unlocked (only without --print)
  2 - Detection failed (e.g. insufficient permissions)
```

## Examples

```bash
# Basic usage - check if screen is locked (exit code)
screenlocked
if [ $? -eq 0 ]; then
    echo "Screen is locked"
else
    echo "Screen is unlocked"
fi

# Print lock status (always returns 0 exit code)
screenlocked --print

# Use in a script condition
if screenlocked --print | grep -q "locked"; then
    echo "Do something when locked"
fi
```

## Installation

You can install Screenlocked via Homebrew using a custom tap. Once published, you will be able to run:

```sh
brew tap medopaw/homebrew-tap
brew install screenlocked
```

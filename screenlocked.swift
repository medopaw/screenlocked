#!/usr/bin/env swift

import Cocoa

let VERSION = "v0.0.7"

// Status enum + exit code mapping
enum LockStatus: Int32 {
    case locked = 0
    case unlocked = 1
    case error = 2
}

// Help information
func printHelp() {
    let help = """
    Usage: screenlocked [OPTION]
    Check if the macOS screen is locked.

    Options:
      -h, --help     Display this help message
      -p, --print    Print locked/unlocked status to stdout
      -v, --version   Display version information

    Exit codes:
      Without -p/--print:
        0   Screen is locked
        1   Screen is unlocked
        2   Detection failed (e.g. insufficient permissions)

      With -p/--print:
        0   Always returns 0 (for both locked and unlocked states)
        2   Detection failed (e.g. insufficient permissions)

    Examples:
      # Check if screen is locked using exit code
      if screenlocked; then
        echo "Screen is locked"
      else
        echo "Screen is unlocked"
      fi

      # Use with other commands based on lock status
      if screenlocked; then
        # Do something when screen is locked
        notify-send "Screen is locked"
      fi

      # Get the status as text
      STATUS=$(screenlocked --print)
      echo "Current screen status: $STATUS"

      # Combine with other tools
      screenlocked && say "Screen is locked" || say "Screen is unlocked"
    """
    print(help)
}

func printVersion() {
    print(VERSION)
}

// Core detection logic
func checkScreenLockStatus() -> LockStatus {
    guard let sessionDict = CGSessionCopyCurrentDictionary() as? [String: Any] else {
        return .error
    }
    let isLocked = sessionDict["CGSSessionScreenIsLocked"] as? Bool ?? false
    return isLocked ? .locked : .unlocked
}

// Parse arguments
var printStatus = false
for arg in CommandLine.arguments.dropFirst() {
    switch arg {
    case "-h", "--help":
        printHelp()
        exit(0)
    case "-p", "--print":
        printStatus = true
    case "-v", "--version":
        printVersion()
        exit(0)
    default:
        fputs("Error: Invalid argument '\(arg)'\n", stderr)
        exit(LockStatus.error.rawValue)
    }
}

// Execute detection and handle result
let status = checkScreenLockStatus()

// Print status if needed
if printStatus {
    switch status {
    case .locked: print("locked")
    case .unlocked: print("unlocked")
    case .error: print("Error: Failed to detect screen lock status") // Print error message if detection failed
    }
    exit(0)
}

// Return corresponding exit code
exit(status.rawValue)

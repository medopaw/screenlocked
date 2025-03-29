#!/usr/bin/env swift

import Cocoa

// 状态枚举 + 退出码映射
enum LockStatus: Int32 {
    case locked = 0
    case unlocked = 1
    case error = 2
}

// 帮助信息
func printHelp() {
    let help = """
    Usage: screenlocked [OPTION]
    Check if the macOS screen is locked.

    Options:
      -h, --help     Display this help message
      -p, --print    Print locked/unlocked status to stdout

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

// 核心检测逻辑
func checkScreenLockStatus() -> LockStatus {
    guard let sessionDict = CGSessionCopyCurrentDictionary() as? [String: Any] else {
        return .error
    }
    let isLocked = sessionDict["CGSSessionScreenIsLocked"] as? Bool ?? false
    return isLocked ? .locked : .unlocked
}

// 解析参数
var printStatus = false
for arg in CommandLine.arguments.dropFirst() {
    switch arg {
    case "-h", "--help":
        printHelp()
        exit(0)
    case "-p", "--print":
        printStatus = true
    default:
        fputs("Error: Invalid argument '\(arg)'\n", stderr)
        exit(LockStatus.error.rawValue)
    }
}

// 执行检测并处理结果
let status = checkScreenLockStatus()

// 按需打印状态
if printStatus {
    switch status {
    case .locked: print("locked")
    case .unlocked: print("unlocked")
    case .error: print("Error: Failed to detect screen lock status") // 错误时输出错误信息
    }
    exit(0)
}

// 返回对应的退出码
exit(status.rawValue)

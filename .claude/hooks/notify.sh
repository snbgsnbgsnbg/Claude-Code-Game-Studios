#!/usr/bin/env bash
# Notification hook — fires when Claude Code sends a notification
# Cross-platform: macOS (osascript), Windows (PowerShell), Linux (notify-send)

# Read notification JSON from stdin
INPUT=$(cat)

# Extract message — try jq first, fall back to grep
if command -v jq &>/dev/null; then
  MESSAGE=$(echo "$INPUT" | jq -r '.message // empty' 2>/dev/null)
fi
if [ -z "$MESSAGE" ]; then
  MESSAGE=$(echo "$INPUT" | grep -oE '"message":"[^"]*"' | sed 's/"message":"//;s/"//')
fi
if [ -z "$MESSAGE" ]; then
  MESSAGE="Claude Code needs your attention"
fi

MESSAGE_TRIM=$(echo "$MESSAGE" | head -c 200)

case "$(uname -s)" in
  Darwin)
    # macOS notification center; escape double quotes for AppleScript
    MESSAGE_SAFE=$(echo "$MESSAGE_TRIM" | sed 's/\\/\\\\/g;s/"/\\"/g')
    osascript -e "display notification \"$MESSAGE_SAFE\" with title \"Claude Code\"" 2>/dev/null &
    ;;
  Linux)
    if command -v notify-send &>/dev/null; then
      notify-send "Claude Code" "$MESSAGE_TRIM" 2>/dev/null &
    fi
    ;;
  MINGW*|MSYS*|CYGWIN*)
    # Windows balloon tip via PowerShell (works on Windows 10/11 without extra modules)
    MESSAGE_SAFE=$(echo "$MESSAGE_TRIM" | sed "s/'/''/g")
    powershell.exe -NonInteractive -WindowStyle Hidden -Command "
      Add-Type -AssemblyName System.Windows.Forms
      \$notify = New-Object System.Windows.Forms.NotifyIcon
      \$notify.Icon = [System.Drawing.SystemIcons]::Information
      \$notify.BalloonTipTitle = 'Claude Code'
      \$notify.BalloonTipText = '$MESSAGE_SAFE'
      \$notify.Visible = \$true
      \$notify.ShowBalloonTip(5000)
      Start-Sleep -Seconds 6
      \$notify.Dispose()
    " 2>/dev/null &
    ;;
esac

echo "Notification: $MESSAGE_TRIM"

#Requires -Version 5.1
<#
    Claude Code notification hook (Windows).

    Reads the hook payload from stdin and raises a native Windows toast.
    Optionally mirrors the message to an ntfy.sh topic when NTFY_TOPIC is set.

    Wired via .claude/settings.local.json for the Stop and Notification events.
#>

# A hook must never break the session: swallow everything and always exit 0.
$ErrorActionPreference = 'SilentlyContinue'

# ---------------------------------------------------------------- read payload
$raw = [Console]::In.ReadToEnd()
$payload = $null
if ($raw) { try { $payload = $raw | ConvertFrom-Json } catch { } }

$eventName = 'Stop'
if ($payload -and $payload.hook_event_name) { $eventName = [string]$payload.hook_event_name }

$projectDir = $env:CLAUDE_PROJECT_DIR
if ($payload -and $payload.cwd) { $projectDir = [string]$payload.cwd }
if (-not $projectDir) { $projectDir = (Get-Location).Path }
$project = Split-Path -Leaf $projectDir

switch ($eventName) {
    'Notification' { $title = 'Claude needs you'; $body = 'Waiting for input' }
    'Stop'         { $title = 'Claude finished';  $body = 'Turn complete' }
    default        { $title = 'Claude Code';      $body = $eventName }
}

# The Notification event carries the actual prompt text; prefer it over the default.
if ($payload -and $payload.message) { $body = [string]$payload.message }
$body = "$body - $project"

# ------------------------------------------------------------ windows toast
# Primary path: WinRT toast. Uses the built-in PowerShell AUMID so no app
# registration is required.
$toastShown = $false
try {
    [void][Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
    [void][Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime]

    $appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
    $template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent(
        [Windows.UI.Notifications.ToastTemplateType]::ToastText02)

    $texts = $template.GetElementsByTagName('text')
    $texts.Item(0).AppendChild($template.CreateTextNode($title)) | Out-Null
    $texts.Item(1).AppendChild($template.CreateTextNode($body))  | Out-Null

    $toast = [Windows.UI.Notifications.ToastNotification]::new($template)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)
    $toastShown = $true
} catch { }

# Fallback: tray balloon. Works even when WinRT toasts are unavailable
# (Focus Assist, stripped WinRT, non-interactive session).
if (-not $toastShown) {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        $icon = New-Object System.Windows.Forms.NotifyIcon
        $icon.Icon = [System.Drawing.SystemIcons]::Information
        $icon.BalloonTipTitle = $title
        $icon.BalloonTipText = $body
        $icon.Visible = $true
        $icon.ShowBalloonTip(5000)
        Start-Sleep -Milliseconds 600
        $icon.Dispose()
    } catch { }
}

# ------------------------------------------------------------- optional ntfy
# Opt-in only. Nothing leaves the machine unless NTFY_TOPIC is set, and only
# the title/body above are sent - never file contents or credentials.
if ($env:NTFY_TOPIC) {
    try {
        $server = if ($env:NTFY_SERVER) { $env:NTFY_SERVER.TrimEnd('/') } else { 'https://ntfy.sh' }
        Invoke-RestMethod -Uri "$server/$($env:NTFY_TOPIC)" -Method Post `
            -Body ([Text.Encoding]::UTF8.GetBytes($body)) `
            -Headers @{ Title = $title; Tags = 'robot' } `
            -TimeoutSec 5 | Out-Null
    } catch { }
}

exit 0

<#
.SYNOPSIS
	Takes screenshots at regular intervals and saves them to a target folder.
.DESCRIPTION
	This PowerShell script takes screenshots at regular intervals and saves them into a target folder (default is the user's screenshots folder).
.PARAMETER TargetFolder
	Specifies the target folder (the user's screenshots folder by default).
.EXAMPLE
	PS> ./take-screenshots -TargetFolder "C:\Screenshots"
 	✔️ Screenshot saved to C:\Screenshots\2023-06-04T10-15-20.png
 	✔️ Screenshot saved to C:\Screenshots\2023-06-04T10-15-25.png
 	✔️ Screenshot saved to C:\Screenshots\2023-06-04T10-15-30.png
 	...
.LINK
	https://github.com/fleschutz/PowerShell
.NOTES
	Author: Markus Fleschutz | License: CC0
#>

Add-Type -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public static class NativeMethods
{
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    public const int SW_HIDE = 0;
}
"@

param([string]$TargetFolder = "")

function GetScreenshotsFolder {
    if ($IsLinux) {
        $Path = "$HOME/Pictures"
        if (-not (Test-Path "$Path" -PathType Container)) { throw "Pictures folder at $Path doesn't exist (yet)" }
        if (Test-Path "$Path/Screenshots" -PathType Container) { $Path = "$Path/Screenshots" }
    } else {
        $Path = [Environment]::GetFolderPath('MyPictures')
        if (-not (Test-Path "$Path" -PathType Container)) { throw "Pictures folder at $Path doesn't exist (yet)" }
        if (Test-Path "$Path\Screenshots" -PathType Container) { $Path = "$Path\Screenshots" }
    }
    return $Path
}

function TakeScreenshot {
    param([string]$FilePath)
    Add-Type -Assembly System.Windows.Forms            
    $ScreenBounds = [Windows.Forms.SystemInformation]::VirtualScreen
    $ScreenshotObject = New-Object Drawing.Bitmap $ScreenBounds.Width, $ScreenBounds.Height
    $DrawingGraphics = [Drawing.Graphics]::FromImage($ScreenshotObject)
    $DrawingGraphics.CopyFromScreen($ScreenBounds.Location, [Drawing.Point]::Empty, $ScreenBounds.Size)
    $DrawingGraphics.Dispose()
    $ScreenshotObject.Save($FilePath)
    $ScreenshotObject.Dispose()
}

try {
    if ("$TargetFolder" -eq "") { $TargetFolder = GetScreenshotsFolder }
    $DelaySeconds = 5
    $Counter = 1
    $StopTime = (Get-Date).AddMinutes(5)

    $handle = (Get-Process -PID $PID).MainWindowHandle
    [void] [NativeMethods]::ShowWindow($handle, [NativeMethods]::SW_HIDE)

    while ((Get-Date) -le $StopTime) {
        $Time = Get-Date
        $Filename = "$($Time.Year)-$($Time.Month)-$($Time.Day)T$($Time.Hour)-$($Time.Minute)-$($Time.Second).png"
        $FilePath = Join-Path $TargetFolder $Filename
        TakeScreenshot $FilePath

        "✔️ Screenshot saved to $FilePath"

        Start-Sleep -Seconds $DelaySeconds
        $Counter++
    }
} catch {
    "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    exit 1
}

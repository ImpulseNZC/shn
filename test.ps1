$code = @"
<#
.SYNOPSIS
    Saves a screenshot every 5 seconds for 5 minutes.
.DESCRIPTION
    This PowerShell script takes screenshots every 5 seconds and saves them into a target folder (default is the user's screenshots folder).
.PARAMETER TargetFolder
    Specifies the target folder (the user's screenshots folder by default).
.EXAMPLE
    PS> ./save-screenshots.ps1
    ✔️ Screenshot saved to C:\Users\Markus\Pictures\Screenshots\2023-06-04T12-30-05.png
    ✔️ Screenshot saved to C:\Users\Markus\Pictures\Screenshots\2023-06-04T12-30-10.png
    ...
.LINK
    https://github.com/fleschutz/PowerShell
.NOTES
    Author: Markus Fleschutz | License: CC0
#>

param([string]$TargetFolder = "")

function GetScreenshotsFolder {
    if ($IsLinux) {
        $Path = "$HOME/Pictures"
        if (-not (Test-Path -Path $Path -PathType Container)) { throw "Pictures folder at $Path doesn't exist (yet)" }
        if (Test-Path -Path "$Path/Screenshots" -PathType Container) { $Path = "$Path/Screenshots" }
    }
    else {
        $Path = [Environment]::GetFolderPath('MyPictures')
        if (-not (Test-Path -Path $Path -PathType Container)) { throw "Pictures folder at $Path doesn't exist (yet)" }
        if (Test-Path -Path "$Path\Screenshots" -PathType Container) { $Path = "$Path\Screenshots" }
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
    $StartTime = Get-Date
    $StopTime = $StartTime.AddMinutes(5)
    
    while ((Get-Date) -le $StopTime) {
        $Time = Get-Date
        $Filename = "{0:yyyy-MM-ddTHH-mm-ss}.png" -f $Time
        $FilePath = Join-Path -Path $TargetFolder -ChildPath $Filename
        TakeScreenshot $FilePath
        Write-Output "✔️ Screenshot saved to $FilePath"
        Start-Sleep -Seconds 5
    }

    exit 0  # success
}
catch {
    Write-Output "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    exit 1
}
"@

$scriptPath = "$env:TEMP\save-screenshots.ps1"
Set-Content -Path $scriptPath -Value $code
Invoke-Expression -Command $scriptPath
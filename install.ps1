# install.ps1 — install dchart on Windows (x86-64), no admin rights needed.
#
#   irm https://cuiqanalytics.github.io/dchart/install.ps1 | iex
#
# Installs to %LOCALAPPDATA%\dchart and adds it to your user PATH. Re-running it replaces the
# previous install (upgrade in place). $env:DCHART_URL overrides the download location.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'   # Invoke-WebRequest is much faster without the bar

$repo = 'cuiqanalytics/dchart'
$name = 'dchart-cli-windows-x86_64'
$installDir = Join-Path $env:LOCALAPPDATA 'dchart'
$url = if ($env:DCHART_URL) { $env:DCHART_URL } else { "https://github.com/$repo/releases/latest/download/$name.zip" }

if (-not [Environment]::Is64BitOperatingSystem) {
    throw 'dchart needs 64-bit Windows.'
}

$tmp = Join-Path ([IO.Path]::GetTempPath()) ([Guid]::NewGuid())
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
    Write-Host "Downloading $url"
    $zip = Join-Path $tmp "$name.zip"
    Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
    Expand-Archive -Path $zip -DestinationPath $tmp -Force

    if (Test-Path $installDir) { Remove-Item -Recurse -Force $installDir }
    Move-Item (Join-Path $tmp $name) $installDir
} finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}
Write-Host "Installed to $installDir"

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (-not (($userPath -split ';') -contains $installDir)) {
    $newPath = if ($userPath) { "$userPath;$installDir" } else { $installDir }
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "Added $installDir to your PATH (open a new terminal to pick it up)"
}
$env:Path = "$env:Path;$installDir"

& (Join-Path $installDir 'dchart.exe') --version
Write-Host "Try it: dchart --folder `"$installDir\examples\data`"   (then open http://localhost:4322)"

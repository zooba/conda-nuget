param(
    [string]$workdir="obj",
    [string]$outdir="",
    [switch]$clean
)


$root = $script:MyInvocation.MyCommand.Path | Split-Path -parent;
if (-not $outdir) {
    $outdir = $root;
}

$workdir = (mkdir -force $workdir)
pushd $workdir

$nuget = gcm nuget -ea 0
if (-not $nuget) { $nuget = gcm .\nuget -ea 0 }

if (-not $nuget) {
    iwr https://aka.ms/nugetclidl -outfile nuget.exe
    $nuget = gcm .\nuget
}

if ($clean -and (Test-Path pythonx86)) {
    rmdir pythonx86 -r -fo
}

& $nuget install pythonx86 -OutputDirectory . -ExcludeVersion

$py = gcm pythonx86\tools\python.exe

& $py -m pip install -U pip setuptools
& $py -m pip install "$root\src\menuinst-stub"
& $py -m pip install conda

& $py -m pip install pyfindvs
& $py "$root\src\entrypoint\build.py" "$workdir\pythonx86\tools\conda.exe" $workdir

'.
DLLs
Lib
Lib\site-packages
import site
' | Out-File -Encoding ASCII "$workdir\pythonx86\tools\conda._pth"

$x = mkdir -force "$workdir\pythonx86\tools\conda-meta";
'' | Out-File -Encoding ASCII "$workdir\pythonx86\tools\conda-meta\history"

'auto_update_conda: False
always_yes: True
' | Out-File -Encoding ASCII "$workdir\pythonx86\tools\condarc"

$ver = if ((pythonx86\tools\conda.exe -V) -match '\w+ ([\d\.]+)') { $Matches[1] } else { '0.0.0.0' }

& $nuget pack "$root\src\nuget\conda.nuspec" -BasePath "$workdir\pythonx86" -OutputDirectory $outdir -Version $ver -NoPackageAnalysis -NonInteractive

popd

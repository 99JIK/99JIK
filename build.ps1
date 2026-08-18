# make 없는 Windows용. .\build.ps1 또는 .\build.ps1 -Target ko
param([ValidateSet('all','en','ko','clean')][string]$Target = 'all')

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if (-not (Get-Command latexmk -ErrorAction SilentlyContinue)) {
    Write-Error "latexmk 없음. MiKTeX 또는 TeX Live 설치 필요. README 참고."
}

$flags = @('-xelatex','-interaction=nonstopmode','-file-line-error','-halt-on-error')

switch ($Target) {
    'clean' { & latexmk -C; break }
    'en'    { & latexmk @flags cv-en.tex; break }
    'ko'    { & latexmk @flags cv-ko.tex; break }
    'all'   { & latexmk @flags cv-en.tex; & latexmk @flags cv-ko.tex; break }
}

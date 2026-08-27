# make 없는 Windows용. .\build.ps1 또는 .\build.ps1 -Target ko
param([ValidateSet('all','en','ko','clean')][string]$Target = 'all')

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if (-not (Get-Command latexmk -ErrorAction SilentlyContinue)) {
    Write-Error "latexmk 없음. MiKTeX 또는 TeX Live 설치 필요. README 참고."
}

# 재현 빌드. 같은 소스면 언제 빌드하든 PDF 바이트가 같아진다.
#
# 이게 없으면 XeTeX가 빌드 시각을 PDF에 박아서, 소스를 안 고치고 다시 빌드만 해도
# git이 PDF를 변경으로 잡는다. 그러면 "git status가 깨끗하다"가 "PDF가 소스와
# 맞다"라는 뜻이 되지 못한다. 커밋된 PDF가 제출본 정본이라 이 성질이 중요하다.
#
# 값은 고정 상수여야 한다. 커밋 날짜에서 끌어오면 아직 커밋 안 한 수정본을 빌드할
# 때와 커밋 후 CI가 빌드할 때 값이 달라져서 재현이 깨진다.
# 대신 PDF 메타데이터의 생성일이 이 날짜로 굳는다.
$env:SOURCE_DATE_EPOCH = '1735689600'   # 2025-01-01T00:00:00Z
$env:FORCE_SOURCE_DATE = '1'

$flags = @('-xelatex','-interaction=nonstopmode','-file-line-error','-halt-on-error')

switch ($Target) {
    'clean' { & latexmk -C; break }
    'en'    { & latexmk @flags cv-en.tex; break }
    'ko'    { & latexmk @flags cv-ko.tex; break }
    'all'   { & latexmk @flags cv-en.tex; & latexmk @flags cv-ko.tex; break }
}

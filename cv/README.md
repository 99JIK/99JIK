# CV

프로필 저장소(`99JIK/99JIK`) 안의 `cv/` 디렉터리다. 원래 별도 저장소였는데 프로필
README와 같은 사실(논문, 프로젝트, 기술스택)을 두 군데서 관리하다 어긋나서 합쳤다.
빌드는 이 디렉터리 안에서 그대로 돌아간다.

CI는 저장소 루트의 [`.github/workflows/cv-build.yml`](../.github/workflows/cv-build.yml)에
있고 `paths: ['cv/**']`가 걸려 있다. 블로그 봇이나 스네이크 워크플로가 main에 커밋해도
LaTeX 빌드는 돌지 않는다.

학술용 CV 소스. 국문과 영문 두 판을 [`cv.cls`](cv.cls) 하나로 조판한다.
현재 국문 2쪽, 영문 3쪽. 같은 내용도 영어가 3할쯤 길어 쪽수는 맞지 않는다.

**제출본은 커밋된 `cv-ko.pdf`와 `cv-en.pdf`다.** 로컬에서 빌드해 소스와 함께 커밋한다.
CI는 결과물을 만들지 않고 컴파일이 되는지만 본다.

## 빌드

엔진은 XeLaTeX 고정. 한글 폰트를 시스템에서 직접 잡아야 해서 pdfLaTeX는 못 쓴다.

```powershell
.\build.ps1                 # 둘 다
.\build.ps1 -Target ko      # ko | en | clean
```

`make`가 있으면 `make`, `make ko`, `make en`, `make watch`(저장할 때마다 재빌드).

클래스 옵션은 둘이다. `korean`은 한글 조판을, `small`은 본문 10pt를 켠다.

## 최초 설치

셋을 깐다. TeX 배포판, Perl, 폰트. 전부 사용자 디렉터리에 들어가고 관리자 권한이 필요 없다.

### 1. MiKTeX

`winget install --id MiKTeX.MiKTeX`은 쓰지 말 것. winget이 설치 관리자를 GUI로 띄우고
그대로 멈춘다. `--disable-interactivity`를 줘도 마찬가지다. 설치 관리자를 직접 받아
포터블로 푸는 쪽이 확실하다.

```powershell
$exe = "$env:TEMP\basic-miktex.exe"
Invoke-WebRequest -OutFile $exe `
  "https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex-25.12-x64.exe"
& $exe --unattended --portable="$env:LOCALAPPDATA\Programs\MiKTeX-portable"
```

`--portable`이 핵심이다. `--shared=no`나 `--user-install=`은 이 설치 관리자가 받지 않는
옵션이라 로그도 안 남기고 exit 1로 죽는다.

푼 뒤 `...\MiKTeX-portable\texmfs\install\miktex\bin\x64`를 PATH에 넣고, 새 셸에서:

```powershell
initexmf --set-config-value "[MPM]AutoInstall=1"
miktex packages update-package-database
```

### 2. Perl

MiKTeX는 Perl을 번들하지 않는데 `latexmk`가 Perl 스크립트다. 없으면
`could not find the script engine 'perl'`로 멈춘다. xelatex 직접 호출은 되지만
상호참조(`cv@lastpage`)가 2패스를 요구해서 쪽수 표기가 틀어진다.

[Strawberry Perl portable](https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases)을
받아 풀고 `perl\bin`을 PATH에 넣는다.

### 3. 폰트

[Pretendard](https://github.com/orioncactus/pretendard/releases)를 깐다. 한글과 라틴을 한
폰트가 덮어 크기와 획 굵기 불일치가 사라진다. **static 버전을 설치할 것.** Variable(VF)은
XeTeX가 축을 못 읽어 볼드가 통째로 사라진다. 없으면 맑은 고딕 등으로 폴백한다.

배포 zip의 `public/static/*.otf` 9개를 `%LOCALAPPDATA%\Microsoft\Windows\Fonts`에 복사하고
`HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts`에 등록하면 관리자 권한 없이 깔린다.

### 확인

```powershell
.\build.ps1
```

국문 2쪽, 영문 3쪽이 나오면 된 것이다. `\TU/Pretendard`가 로그에 보이면 폰트도 제대로 잡혔다.

포터블 모드에서는 `major issue: So far, you have not checked for MiKTeX updates.`가 매번
stderr로 나온다. `miktex packages check-update`를 돌려도 안 사라지는데, 종료 코드는 0이라
빌드에는 지장이 없다. 다만 PowerShell에서 네이티브 stderr를 `2>&1`로 받으면 이 줄 때문에
실패로 잡히니 그렇게 쓰지 말 것.

## 손대기 전에

레이아웃 결정과 그 근거는 [`cv.cls`](cv.cls) 주석에 있다. 여백 층위, 폰트 폴백 순서,
minipage 안에서 양쪽정렬이 되살아나는 함정 같은 것들이라 고치기 전에 읽는 편이 빠르다.

미기재는 `\TODO{}`로 남긴다. PDF에 빨갛게 찍히고, CI가 경고를 낸다. 태그를 붙인
커밋에서는 실패시킨다.

전화번호는 넣지 않는다. 저장소가 public이라 push하면 그대로 노출된다. 필요하면 제출할
때만 한 줄 넣고 빌드한다.

## 제출본 태그

어디에 어떤 판을 냈는지 나중에 추적된다.

```bash
git tag -a 2026-09-knu-phd -m "경북대 박사 지원 제출본"
```

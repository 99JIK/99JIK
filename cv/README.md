# CV

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

```powershell
winget install --id MiKTeX.MiKTeX -e
# 새 셸을 열어 PATH 반영 후
initexmf --set-config-value "[MPM]AutoInstall=1"
```

폰트는 [Pretendard](https://github.com/orioncactus/pretendard/releases)를 깐다. 한글과 라틴을 한
폰트가 덮어 크기와 획 굵기 불일치가 사라진다. **static 버전을 설치할 것.** Variable(VF)은
XeTeX가 축을 못 읽어 볼드가 통째로 사라진다. 없으면 맑은 고딕 등으로 폴백한다.

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

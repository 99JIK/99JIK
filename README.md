# CV

학술용 CV 소스. 국문과 영문 두 판을 같은 스타일 클래스로 조판한다.

| 파일 | 내용 |
|---|---|
| [`cv.cls`](cv.cls) | 공통 스타일. 레이아웃, 색, 폰트 폴백, 항목 매크로 |
| [`cv-ko.tex`](cv-ko.tex) | 국문판 (`korean,small` 옵션) |
| [`cv-en.tex`](cv-en.tex) | 영문판 (`small` 옵션) |
| [`build.ps1`](build.ps1) / [`Makefile`](Makefile) | 빌드 |
| [`.github/workflows/build.yml`](.github/workflows/build.yml) | 컴파일 회귀 검사. 결과물은 만들지 않는다 |
| `cv-ko.pdf` / `cv-en.pdf` | **제출본 정본.** 로컬 빌드 결과를 커밋한다 |

현재 분량은 국문 2쪽, 영문 3쪽이다. 같은 내용이라도 영어가 한글보다 3할쯤 길어서
쪽수는 맞지 않는다. 두 판은 각각 따로 제출하므로 나란히 비교되지 않는다.

## 빌드

엔진은 **XeLaTeX 고정**. 한글 폰트를 시스템에서 직접 잡아야 해서 pdfLaTeX는 못 쓴다.

```powershell
# 최초 1회: TeX 배포판 설치 (다운로드 큼, 10-20분)
winget install --id MiKTeX.MiKTeX -e
# 새 셸을 열어 PATH 반영 후
initexmf --set-config-value "[MPM]AutoInstall=1"
```

```powershell
.\build.ps1          # 둘 다
.\build.ps1 -Target ko
.\build.ps1 -Target en
.\build.ps1 -Target clean
```

`make`가 있으면 `make`, `make ko`, `make en`, `make watch`(저장할 때마다 재빌드).

**제출본은 로컬에서 빌드해 커밋한 PDF다.** CI는 결과물을 만들지 않는다. 깨끗한 머신에서
소스가 컴파일되는지만 보는 회귀 검사이고, Pretendard가 없어 폰트도 폴백으로 떨어지므로
CI가 만든 PDF는 로컬 결과와 다르다. 그래서 아티팩트로 올리지 않는다.

CI는 `\TODO{`가 남아 있으면 경고를 낸다. 태그를 붙인 커밋에서는 실패시킨다.
태그는 제출본이라는 뜻이므로 미기재가 남아 있으면 안 된다.

## 폰트

`cv.cls`가 후보를 순서대로 찾아 처음 발견한 것을 쓴다. 한 종도 없으면 조용히 기본 폰트로
떨어지므로, 출력이 이상하면 폰트 설치 여부부터 본다.

- 라틴: Pretendard, Segoe UI, TeX Gyre Heros, Arial
- 한글: Pretendard, 맑은 고딕, 한컴 고딕, Noto Sans CJK KR

**Pretendard를 권한다.** 한글과 라틴을 한 폰트가 덮어서 크기와 획 굵기 불일치가 사라진다.
[릴리스](https://github.com/orioncactus/pretendard/releases)에서 받되 **static 버전을 설치할 것.**
Variable(VF)은 XeTeX가 축을 못 읽어 볼드가 통째로 사라진다.

Pretendard에는 이탤릭 자형이 없어서 `AutoFakeSlant=0.2`로 때운다. 뒤 후보들은 진짜
이탤릭이 있으므로 이 옵션은 Pretendard에만 걸려 있다.

## 클래스 옵션

| 옵션 | 효과 |
|---|---|
| `korean` | kotex 로드, 한글 폰트 폴백 적용, 섹션 제목 한글 표기 |
| `small` | 본문 11pt 대신 10pt. 분량을 줄일 때 쓰는 손잡이 |

## 매크로

```latex
\setdatewidth{32mm}                      % 왼쪽 날짜 칼럼 폭. 국문은 기간 표기가 길어 넓게
\cventry{기간}{직함}{소속}{장소}{상세}    % 3-5번 인자는 비우면 그 줄이 안 나감
\cvline{라벨}{내용}                       % 날짜 칼럼 없는 한 줄짜리
\me{이름}                                 % 저자 목록에서 본인 강조
\corr                                     % 교신저자 별표. 범례를 꼭 붙일 것
\venue{학회명}
\cvsectionnote{단서}                      % 섹션 제목 오른쪽 끝의 작은 주석
\TODO{채울 내용}                          % PDF에 빨갛게 찍힘. 제출 전 0개인지 확인
```

`\cvitems` 환경으로 항목 안에 불릿을, `publications` 환경으로 번호 매긴 논문 목록을 만든다.

## 조판 규칙

여백은 **층위별로 뚜렷하게 차이가 나야** 덩어리가 보인다. 섹션 사이 > 항목 사이 > 항목 안
줄 사이 순으로 벌린다. 이 값들이 서로 비슷해지면 전부 한 덩어리로 뭉쳐 읽기 힘들어진다.
분량을 줄이려고 여기를 건드리면 가독성이 바로 나빠지므로, 먼저 문장을 압축하고 그래도
모자라면 `small` 옵션을 쓴다.

본문 폭은 140mm 안팎, 줄당 75~80자다. 좌우 여백을 줄여 줄을 늘리는 건 행장이 길어져
역효과다.

## 채우기 규칙

- 미기재는 `\TODO{}`로 남긴다. PDF에 빨갛게 찍히므로 제출 전 `grep -c TODO cv-ko.tex`가 0인지 본다.
- 추론으로 채운 항목은 `% [확인]` 주석을 단다. 사실 확인이 끝나면 주석을 지운다.
- 저자 영문 표기는 KCC 스타일로 고정: `Jeongin Kim`, `Woojin Lee`. 논문마다 표기가 갈리면
  Google Scholar나 DBpia에서 같은 저자로 안 묶인다.
- 전화번호는 넣지 않는다. 저장소가 public이라 push하면 그대로 노출된다. 제출할 때만 한 줄
  넣고 빌드한다.

## 판 관리

제출본은 태그로 남긴다. 어디에 어떤 판을 냈는지 나중에 추적된다.

```bash
git tag -a 2026-09-knu-phd -m "경북대 박사 지원 제출본"
```

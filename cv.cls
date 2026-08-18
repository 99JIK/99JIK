\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{cv}[2026/08/18 v0.1 Academic CV class]

% 한/영 공용 클래스. korean 옵션 주면 kotex 로드 + 한글 조판 규칙 적용.
% 엔진은 XeLaTeX 고정 (fontspec + 한글 시스템 폰트 때문).
\newif\ifcv@korean \cv@koreanfalse
\DeclareOption{korean}{\cv@koreantrue}
% small 옵션: 본문 11pt 대신 10pt. 영문판은 같은 내용이 한글보다 3할쯤 길어져
% 11pt로는 쪽수가 국문판보다 한 장 더 나옴. 두 판의 쪽수를 맞출 때 쓰는 손잡이.
\newif\ifcv@small \cv@smallfalse
\DeclareOption{small}{\cv@smalltrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\ifcv@small
  \LoadClass[10pt,a4paper]{article}
\else
  \LoadClass[11pt,a4paper]{article}
\fi

% 여백은 분량 조절 손잡이. 영문판이 3쪽으로 넘어가 2쪽에 맞추려고 줄였음.
\RequirePackage[a4paper,top=17mm,bottom=17mm,left=18mm,right=18mm,footskip=8mm]{geometry}
\RequirePackage{fontspec}
\RequirePackage{xcolor}
\RequirePackage{etoolbox}
\RequirePackage{titlesec}
\RequirePackage{enumitem}
\RequirePackage{ragged2e}
\RequirePackage{fancyhdr}
\RequirePackage{needspace}
\RequirePackage[hidelinks]{hyperref}

\ifcv@korean
  \RequirePackage{kotex}
\fi

% ---------------------------------------------------------------- 색
\definecolor{cvaccent}{HTML}{1F3A5F}
\definecolor{cvmuted}{HTML}{5A6472}
\definecolor{cvrule}{HTML}{C8CDD4}
\definecolor{cvtodo}{HTML}{C0392B}

% ---------------------------------------------------------------- 폰트
% 설치 안 된 폰트는 조용히 건너뛰고 다음 후보로. 환경마다 있는 폰트가 달라서.
%
% 세리프에서 산세리프로 바꿨음. 이유 셋:
% 1. 라틴 세리프와 한글 명조는 x-height, 획 굵기가 안 맞아 한글이 작고 흐리게 보임
% 2. 이 CV는 대부분 화면(PDF 뷰어)에서 읽힘. 인쇄 기준의 세리프 관습이 화면에선 불리
% 3. Pretendard가 깔려 있으면 한 폰트가 한/영을 다 덮어 불일치가 아예 사라짐
% 세리프로 되돌리려면 아래 후보 맨 앞에 TeX Gyre Pagella, 한글 쪽엔 HCR Batang을 넣으면 됨.
% 주의: 가변폰트(VF) 한 개만 깔린 경우 XeTeX가 축을 못 읽어 볼드가 사라짐.
% Pretendard는 Variable 말고 static 버전을 설치할 것.
\newif\ifcv@mainset
\newcommand{\cv@trymain}[1]{\ifcv@mainset\else\IfFontExistsTF{#1}{\setmainfont{#1}\cv@mainsettrue}{}\fi}
% Pretendard만 따로 잡는 이유: 이탤릭 자형이 없음. 소속 줄과 학회명이 기울임을 쓰므로
% 가짜 기울임(0.2)으로 때움. 뒤의 Segoe UI 등은 진짜 이탤릭이 있으니 옵션 주면 안 됨.
\IfFontExistsTF{Pretendard}{\setmainfont[AutoFakeSlant=0.2]{Pretendard}\cv@mainsettrue}{}
\cv@trymain{Segoe UI}
\cv@trymain{TeX Gyre Heros}
\cv@trymain{Arial}

\newif\ifcv@sansset
\newcommand{\cv@trysans}[1]{\ifcv@sansset\else\IfFontExistsTF{#1}{\setsansfont{#1}\cv@sanssettrue}{}\fi}
\IfFontExistsTF{Pretendard}{\setsansfont[AutoFakeSlant=0.2]{Pretendard}\cv@sanssettrue}{}
\cv@trysans{Segoe UI}
\cv@trysans{TeX Gyre Heros}

% \newif는 반드시 \ifcv@korean 바깥에 둘 것. 안에 두면 영문 빌드에서 그 분기를 건너뛰느라
% \ifcv@hangulset이 미정의로 남고, TeX가 스킵 중에 조건문으로 세지 않아 \fi 짝이 어긋남.
\newif\ifcv@hangulset

\ifcv@korean
  % 순서 기준은 "진짜 볼드 자형이 있는가". 섹션 제목과 항목 제목이 전부 볼드라
  % 굵은 자형 없는 폰트를 쓰면 위계가 통째로 사라짐.
  % 이탤릭은 어느 한글 폰트에도 없음. 라틴만 기울고 한글은 정체로 남는데 이게 맞는 동작이라
  % 로그의 `/m/it' undefined 경고는 무시해도 됨.
  \newcommand{\cv@tryhangul}[1]{%
    \ifcv@hangulset\else\IfFontExistsTF{#1}{\setmainhangulfont{#1}\cv@hangulsettrue}{}\fi}
  \cv@tryhangul{Pretendard}          % 한/영을 한 폰트가 덮음. 깔려 있으면 이게 최선
  \cv@tryhangul{Malgun Gothic}       % Windows 기본 탑재. 진짜 볼드 있음
  \cv@tryhangul{Hancom Gothic}       % 한컴 오피스 딸려옴. 볼드 있음
  \cv@tryhangul{Noto Sans CJK KR}    % 리눅스/CI 기본 (font-noto-cjk)
  % 최후 수단. Noto Serif KR이 가변폰트(VF) 한 개로 깔리면 XeTeX가 축을 못 읽어 볼드가 없음.
  % 가짜 볼드로 때움. 인쇄 품질 떨어지니 위 셋 중 하나를 까는 게 나음.
  \ifcv@hangulset\else
    \IfFontExistsTF{Noto Serif KR}
      {\setmainhangulfont[AutoFakeBold=2.5]{Noto Serif KR}\cv@hangulsettrue}{}%
  \fi
\fi

% ---------------------------------------------------------------- 레이아웃 상수
\newlength{\cvdatewidth}\setlength{\cvdatewidth}{24mm}  % 날짜 칼럼 폭. 국문은 tex에서 늘려 씀
\newlength{\cvgap}\setlength{\cvgap}{4mm}
\newcommand{\setdatewidth}[1]{\setlength{\cvdatewidth}{#1}}

\setlength{\parindent}{0pt}
\linespread{1.12}

\raggedbottom
% 양쪽정렬 해제. 좁은 칼럼에서 단어 간격이 들쭉날쭉해짐. CV는 왼끝맞춤이 표준.
\AtBeginDocument{\RaggedRight}

% ---------------------------------------------------------------- 섹션
% 영문도 대문자화 안 함. 한글은 대문자 개념이 없어서 국문판만 일반 표기가 되는데,
% 두 판을 나란히 놓으면 영문 쪽만 무겁고 폭도 넓어 배치가 달라 보임.
% 국/영문 시각 무게를 맞추려고 둘 다 일반 표기로 통일.
\newcommand{\cv@sectionfmt}{\large\bfseries\color{cvaccent}}
\newcommand{\cv@sectionwrap}[1]{#1}
\titleformat{\section}
  {\cv@sectionfmt}{}{0pt}{\cv@sectionwrap}
  [\vspace{0.2em}{\color{cvrule}\titlerule[0.9pt]}]  % 음수로 당기면 밑선이 디센더를 관통함
% 여백은 층위별로 뚜렷하게 차이가 나야 덩어리가 보임.
% 섹션 사이 > 항목 사이 > 항목 안 줄 사이 순으로 벌린다.
% 이 값들이 서로 비슷해지면 전부 한 덩어리로 뭉쳐 보여서 읽기 힘들어짐.
\titlespacing*{\section}{0pt}{1.7em plus 0.35em minus 0.2em}{0.55em}

% 섹션 제목만 페이지 끝에 남는 고아 방지. 제목 뒤로 최소 4줄이 안 들어가면 통째로 다음 장으로.
% titlesec의 titlespacing으로는 못 막아서 \section 자체를 감쌈.
\pretocmd{\section}{\needspace{4\baselineskip}}{}{}

% 섹션 제목 오른쪽 끝에 붙이는 작은 주석. 범례나 (all in Korean) 같은 단서를 넣는 자리.
% 목록 아래에 두면 다 읽고 나서야 표기법을 알게 되고 줄도 하나 더 먹음.
\newcommand{\cvsectionnote}[1]{\hfill{\normalfont\small\color{cvmuted}#1}}

% 논문 종류 구분용 소제목 (학술지/학술대회/투고 중)
\titleformat{\subsection}{\normalsize\bfseries\color{cvmuted}}{}{0pt}{}
\titlespacing*{\subsection}{0pt}{1.0em plus 0.2em}{0.35em}

% ---------------------------------------------------------------- 머리말
\newcommand{\cvname}[1]{\def\cv@name{#1}}
\newcommand{\cvtagline}[1]{\def\cv@tagline{#1}}
\newcommand{\cvcontact}[1]{\def\cv@contact{#1}}
\cvname{}\cvtagline{}\cvcontact{}

\newcommand{\cvsep}{\;\textcolor{cvrule}{\textbar}\;}
% 주의: URL/메일 인자에 다른 매크로 넣지 말 것. hyperref가 URL 정규화하다 입력 스택 터짐.
% \cvmail{\TODO{...}} 중첩이 실제로 컴파일을 죽였음. 미정이면 링크 없이 평문으로 둘 것.
\newcommand{\cvlink}[2]{\href{#1}{\underline{#2}}}
\newcommand{\cvmail}[1]{\href{mailto:#1}{\underline{#1}}}

\newcommand{\makecvheader}{%
  \begin{center}
    {\fontsize{24}{28}\selectfont\bfseries\color{cvaccent}\cv@name\par}
    \notblank{\cv@tagline}{\vspace{0.35em}{\color{cvmuted}\cv@tagline\par}}{}
    \notblank{\cv@contact}{\vspace{0.5em}{\small\cv@contact\par}}{}
  \end{center}
  \vspace{0.2em}
}

% 2쪽 이상이면 쪽번호 필요. 심사자가 흩어진 장 순서 확인함.
\pagestyle{fancy}\fancyhf{}
\renewcommand{\headrulewidth}{0pt}
\fancyfoot[C]{\small\color{cvmuted}\cv@name\cvsep\thepage/\pageref{cv@lastpage}}

% ---------------------------------------------------------------- 항목
% 왼쪽 칼럼에서 \color는 반드시 \strut 뒤에 올 것.
% 수직 모드에서 \color를 부르면 vlist 맨 앞에 whatsit이 들어가는데, \vtop은 첫 항목이 박스일 때만
% 높이를 잡는다. whatsit이 먼저면 높이가 0이 되고 minipage 통째로 baseline 아래로 내려간다.
% 실제로 라벨이 값보다 반 줄 처져 보였던 원인.
\newcommand{\cv@datecol}[1]{%
  \begin{minipage}[t]{\cvdatewidth}%
    \RaggedRight\small\strut\color{cvmuted}#1%
  \end{minipage}\hspace{\cvgap}%
}

% \cventry{기간}{직함/학위}{소속}{장소}{상세}
% 3-5번은 비워도 됨. 빈 인자는 줄 자체가 안 나감.
\newcommand{\cventry}[5]{%
  \cv@datecol{#1}%
  \begin{minipage}[t]{\dimexpr\linewidth-\cvdatewidth-\cvgap\relax}
    \strut\textbf{#2}\notblank{#4}{\hfill{\small\color{cvmuted}#4}}{}\par
    \notblank{#3}{\vspace{0.1em}{\itshape #3}\par}{}
    \notblank{#5}{\vspace{0.25em}{\small #5}\par}{}
  \end{minipage}\par\vspace{0.85em}
}

% 날짜 칼럼 없는 단순 줄. 기술 스택, 어학성적 같은 것.
% \cvline{라벨}{내용}
\newcommand{\cvline}[2]{%
  \cv@datecol{#1}%
  \begin{minipage}[t]{\dimexpr\linewidth-\cvdatewidth-\cvgap\relax}
    \strut #2
  \end{minipage}\par\vspace{0.32em}
}

\newenvironment{cvitems}
  {\begin{itemize}[leftmargin=1.1em,itemsep=2.5pt,topsep=2.5pt,parsep=0pt,label=\textcolor{cvmuted}{\textbullet}]}
  {\end{itemize}}

% ---------------------------------------------------------------- 논문 목록
% 번호는 1부터 올라감. 최신 논문을 맨 위에 적으면 [1]이 최신이 됨.
% 선택 인자로 시작 번호를 줄 수 있음: \begin{publications}[5] 하면 [6]부터.
\newcounter{cvpub}
\newenvironment{publications}[1][0]
  {\setcounter{cvpub}{#1}%
   \begin{list}{[\arabic{cvpub}]}%
     {\usecounter{cvpub}\setlength{\leftmargin}{2.4em}\setlength{\labelwidth}{2em}%
      \setlength{\labelsep}{0.4em}\setlength{\itemsep}{0.65em}\setlength{\parsep}{0pt}%
      \setlength{\topsep}{0.3em}}}
  {\end{list}}

\newcommand{\me}[1]{\textbf{#1}}          % 저자 목록에서 본인 강조
\newcommand{\corr}{\textsuperscript{*}}   % 교신저자. 목록 아래 범례 한 줄 꼭 붙일 것
\newcommand{\venue}[1]{\textit{#1}}       % 학회/저널명
\newcommand{\cvnote}[1]{{\small\color{cvmuted}#1}}

% ---------------------------------------------------------------- 채우기 표식
% PDF에서 빨갛게 보임. 남아 있으면 아직 안 채운 것.
\newcommand{\TODO}[1]{{\color{cvtodo}\bfseries[TODO: #1]}}

\AtEndDocument{\label{cv@lastpage}}
\endinput

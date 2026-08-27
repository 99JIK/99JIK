# 재현 빌드. 같은 소스면 언제 빌드하든 PDF 바이트가 같아진다. 이게 없으면 XeTeX가
# 빌드 시각을 PDF에 박아서, 소스를 안 고치고 다시 빌드만 해도 git이 변경으로 잡는다.
# 커밋된 PDF가 제출본 정본이라 "git status 깨끗함 = PDF가 소스와 맞음"이 성립해야 한다.
# 고정 상수여야 함. 커밋 날짜에서 끌어오면 커밋 전후로 값이 달라져 재현이 깨진다.
export SOURCE_DATE_EPOCH = 1735689600
export FORCE_SOURCE_DATE = 1

# XeLaTeX 고정. 한글 폰트를 시스템에서 직접 잡아야 해서 pdflatex 안 씀.
LATEXMK = latexmk -xelatex -interaction=nonstopmode -file-line-error -halt-on-error

TARGETS = cv-en.pdf cv-ko.pdf

.PHONY: all en ko clean distclean watch
all: $(TARGETS)
en: cv-en.pdf
ko: cv-ko.pdf

%.pdf: %.tex cv.cls
	$(LATEXMK) $<

# 저장할 때마다 다시 빌드. 작성 중에 쓰면 편함.
watch:
	$(LATEXMK) -pvc cv-en.tex

clean:
	latexmk -c

distclean:
	latexmk -C

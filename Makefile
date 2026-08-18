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

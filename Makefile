EXAM_REPORT_PDF="./output/OSCP-OS-${OSID}-Exam-Report.pdf"
LAB_REPORT_PDF="./output/OSCP-OS-${OSID}-Lab-Report.pdf"
ZIP_OUTPUT_FILE="output/OSCP-OS-${OSID}-Exam-Report.7z"

LAB_TEMPLATE_PATH = ./lib/lab-report.mdpp
LAB_PREPROCESSED_PATH = ./Lab/lab-report.md
LAB_HOSTS_FILES = ./Lab/Targets/*.md
LAB_HOSTS_MDPP = ./Lab/Parts/03-hosts.mdpp
LAB_HOSTS_CONSOLIDATED = ./Lab/Parts/03-hosts.md
LAB_EXERCISES_FILES = ./Lab/Exercises/*.md
LAB_EXERCISES_MDPP = ./Lab/Parts/05-exercises.mdpp
LAB_EXERCISES_CONSOLIDATED = ./Lab/Parts/05-exercises.md
LAB_APPENDIX_FILES= ./Lab/Appendices/*.md
LAB_APPENDIX_MDPP = ./Lab/Parts/04-appendices.mdpp
LAB_APPENDIX_CONSOLIDATED = ./Lab/Parts/04-appendices.md


EXAM_TEMPLATE_PATH = ./lib/exam-report.mdpp
EXAM_PREPROCESSED_PATH = ./Exam/exam-report.md
EXAM_HOSTS_FILES = ./Exam/Targets/*.md
EXAM_HOSTS_MDPP = ./Exam/Parts/03-hosts.mdpp
EXAM_HOSTS_CONSOLIDATED = ./Exam/Parts/03-hosts.md
EXAM_APPENDIX_FILES= ./Exam/Appendices/*.md
EXAM_APPENDIX_MDPP = ./Exam/Parts/04-appendices.mdpp
EXAM_APPENDIX_CONSOLIDATED = ./Exam/Parts/04-appendices.md

# Setup instructions
define SETUP_INSTRUCTIONS
#
# Copy and paste this
#
# Install dependencies
sudo pip3 install MarkdownPP
sudo apt install -y pandoc texlive-full
sudo wget https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/master/eisvogel.tex -O /usr/share/pandoc/data/templates/eisvogel.latex

sudo apt install -y fonts-noto-color-emoji fonts-firacode

# Install VS Code plugins
code --install-extension bierner.github-markdown-preview
code --install-extension DavidAnson.vscode-markdownlint
code --install-extension telesoho.vscode-markdown-paste-image
code --install-extension jrieken.md-navigate
code --install-extension yzhang.markdown-all-in-one
code --install-extension streetsidesoftware.code-spell-checker
code --install-extension eamodio.gitlens
code --install-extension ms-vscode.PowerShell
code --install-extension ms-python.python
code --install-extension rebornix.Ruby
code --install-extension ms-vscode.cpptools
code --install-extension vscode-icons-team.vscode-icons
code --install-extension pnp.polacode
code --install-extension tomoki1207.pdf
code --install-extension slevesque.vscode-hexdump
endef
export SETUP_INSTRUCTIONS


PHONY : check-OSID all

check-OSID:
ifndef OSID
	$(error OSID enviromental variable is undefined)
endif


setupenv:
	@echo "$$SETUP_INSTRUCTIONS"

clean:
	rm -f \
	  $(LAB_HOSTS_MDPP) \
	  $(LAB_EXERCISES_MDPP) \
	  $(LAB_APPENDIX_MDPP) \
	  $(LAB_HOSTS_CONSOLIDATED) \
	  $(EXAM_HOSTS_MDPP) \
	  $(EXAM_APPENDIX_MDPP) \
	  $(EXAM_HOSTS_CONSOLIDATED)

lab-hosts:
	echo -n > $(LAB_HOSTS_CONSOLIDATED)
	echo "\\\newpage" >  $(LAB_HOSTS_MDPP)
	$(foreach file, $(shell ls -v $(LAB_HOSTS_FILES)), echo \!INCLUDE \"$(file)\"\\n\\\\newpage\\n\\n >> $(LAB_HOSTS_MDPP);)
	markdown-pp $(LAB_HOSTS_MDPP) -o $(LAB_HOSTS_CONSOLIDATED)
	sed -i 's|](images|](Lab/Targets/images|' $(LAB_HOSTS_CONSOLIDATED)

lab-exercises:
	echo -n > $(LAB_EXERCISES_MDPP)
	echo -n > $(LAB_EXERCISES_CONSOLIDATED)
	$(foreach file, $(shell ls -v $(LAB_EXERCISES_FILES)), echo \!INCLUDE \"$(file)\"\\n\\\\newpage\\n\\n >> $(LAB_EXERCISES_MDPP);)
	markdown-pp $(LAB_EXERCISES_MDPP) -o $(LAB_EXERCISES_CONSOLIDATED)
	sed -i 's|](images|](Lab/Exercises/images|' $(LAB_EXERCISES_CONSOLIDATED)

lab-appendix:
	echo -n > $(LAB_APPENDIX_MDPP)
	echo -n > $(LAB_APPENDIX_CONSOLIDATED)
	$(foreach file, $(shell ls -v $(LAB_APPENDIX_FILES)), echo \!INCLUDE \"$(file)\"\,1\\n\\n >> $(LAB_APPENDIX_MDPP);)
	markdown-pp $(LAB_APPENDIX_MDPP) -o $(LAB_APPENDIX_CONSOLIDATED)
	sed -i 's|](images|](Lab/Appendices/images|' $(LAB_APPENDIX_CONSOLIDATED)

lab-pdf:
	markdown-pp $(LAB_TEMPLATE_PATH) -o $(LAB_PREPROCESSED_PATH)
	sed -i 's|user@example.com|${EMAIL}|' $(LAB_PREPROCESSED_PATH)
	sed -i 's|OS-XXXXX|OS-${OSID}|' $(LAB_PREPROCESSED_PATH)
	sed -i 's|202x-xx-xx|$(shell date "+%Y-%m-%d")|' $(LAB_PREPROCESSED_PATH)
	sed -i -E 's/```cmd/```bash/g' $(LAB_PREPROCESSED_PATH)
	pandoc $(LAB_PREPROCESSED_PATH) \
	  -o $(LAB_REPORT_PDF) \
	  --from=markdown \
	  --template=eisvogel.latex \
	  --table-of-contents \
	  --toc-depth=6 \
	  --number-sections \
	  --top-level-division=chapter \
	  --highlight-style=tango \
	  --syntax-definition=lib/text.xml

lab: \
	lab-hosts \
	lab-exercises \
	lab-appendix \
	lab-pdf


exam-hosts:
	echo -n > $(EXAM_APPENDIX_CONSOLIDATED)
	echo "\\\newpage" >  $(EXAM_HOSTS_MDPP)
	$(foreach file, $(shell ls -v $(EXAM_HOSTS_FILES)), echo \!INCLUDE \"$(file)\"\\n\\\\newpage\\n\\n >> $(EXAM_HOSTS_MDPP);)
	markdown-pp $(EXAM_HOSTS_MDPP) -o $(EXAM_HOSTS_CONSOLIDATED)
	sed -i 's|](images|](Exam/Targets/images|' $(EXAM_HOSTS_CONSOLIDATED)

exam-appendix:
	echo -n > $(EXAM_APPENDIX_MDPP)
	echo -n > $(EXAM_APPENDIX_CONSOLIDATED)
	$(foreach file, $(shell ls -v $(EXAM_APPENDIX_FILES)), echo \!INCLUDE \"$(file)\"\,1\\n\\n >> $(EXAM_APPENDIX_MDPP);)
	markdown-pp $(EXAM_APPENDIX_MDPP) -o $(EXAM_APPENDIX_CONSOLIDATED)
	sed -i 's|](images|](Exam/Appendices/images|' $(EXAM_APPENDIX_CONSOLIDATED)

exam-pdf:
	markdown-pp $(EXAM_TEMPLATE_PATH) -o $(EXAM_PREPROCESSED_PATH)
	sed -i 's|user@example.com|${EMAIL}|' $(EXAM_PREPROCESSED_PATH)
	sed -i 's|OS-XXXXX|OS-${OSID}|' $(EXAM_PREPROCESSED_PATH)
	sed -i 's|202x-xx-xx|$(shell date "+%Y-%m-%d")|' $(EXAM_PREPROCESSED_PATH)
	sed -i -E 's/```cmd/```bash/g' $(EXAM_PREPROCESSED_PATH)
	pandoc $(EXAM_PREPROCESSED_PATH) \
	-o $(EXAM_REPORT_PDF) \
	--from=markdown \
	--template=eisvogel.latex \
	--table-of-contents \
	--toc-depth=6 \
	--number-sections \
	--top-level-division=chapter \
	--highlight-style=tango \
	--syntax-definition=lib/text.xml

exam: \
	exam-hosts \
	exam-appendix \
	exam-pdf


zip:
	7z a \
	  $(ZIP_OUTPUT_FILE) \
	  -pOS-$(OSID) \
	  $(EXAM_REPORT_PDF) \
	  $(LAB_REPORT_PDF)

all: \
    check-OSID \
	lab \
	exam \
	zip \
	clean

BRANCH_NAME := feature/new-raw-data
SRC_DIR := /code/app/src
PROJECT := hidden-outrider-390502
DATA_ENV_DIR := .
PYTHON_VERSION := f
var1 := test2

.SILENT:
.ONESHELL:

git-config:
	@echo "## Configuring  repository"
	git config --global --add safe.directory /root/Models/human_coc_follicular
	git pull
	git branch -r | grep -v 'main'| while read remote; do git branch -f "$${remote#origin/}" "$$remote";done
	
branch:
	@echo "## Creating branch in current repository"
	git switch develop
	git branch $(BRANCH_NAME)
	git switch $(BRANCH_NAME)
	
login:
	@echo "Please login to your account"
	gcloud auth login
	gcloud auth application-default login
	gcloud config set project $(PROJECT)


pull-data:
	@echo "## Downloading data from bucket with DVC"
	. $(SRC_DIR)/.venv/bin/activate \
	&& dvc pull

push-video:
	@echo "## Pushing data to bucket with DVC"
	. $(SRC_DIR)/.venv/bin/activate \
	&& dvc add data/ \
	&& dvc push -r storage

push-branch: # exec : make push-branch mail=yourmail@conceivable.life
	@echo "## Pushing branch to git repository"
	git config --global user.email = "test@test" 
	git add . | if read line; then git commit -m "new videos added in data/raw folder and uploaded to bucket with DVC";else echo  "\t no commit added due to there are no changes";fi
	git push -u origin $(BRANCH_NAME)
	
test:
	@echo "## testing dvc"
	. $(SRC_DIR)/.venv/bin/activate \
	&& dvc status

clean:
	@echo "## cleaning current project"
	find . -name '*.pyc' -delete

dvenv: clean $(DATA_ENV_DIR)/.venv/touchfile validation## 💻 Install all python libraries in requirements.txt

$(DATA_ENV_DIR)/.venv/touchfile: data-req.txt
	python -m venv $(DATA_ENV_DIR)/.venv
	. $(DATA_ENV_DIR)/.venv/bin/activate; pip install -Ur data-req.txt
	touch $(DATA_ENV_DIR)/.venv/touchfile

pull: dvenv
	@echo "## pulling data from bucket"
	. $(DATA_ENV_DIR)/.venv/bin/activate \
	&& dvc pull \
	&& unzip Data.zip

push: dvenv num-dvc-changes dvc-push
	@echo "## generating dvc doctor info"
	. $(DATA_ENV_DIR)/.venv/bin/activate \
	&& dvc doctor > dvc_doctor_info\
	&& git add dvc_doctor_info\
	&& git commit -m "dvc_doctor_info file updated"

info:
	@echo "## executing dvc doctor command"
	. $(DATA_ENV_DIR)/.venv/bin/activate \
	&& dvc doctor

validation:
	@echo "## validating python version"
	. $(DATA_ENV_DIR)/.venv/bin/activate \
	&& python -V | grep 3.12.2 |if read remote; then echo "\t- .venv has $${remote} ";else echo "\tYou have not installed PYTHON VERSION 3.12.2 \n\t- Delete .venv and activate conda environment with python version 3.12.2 \n\t- pull again \n\t- validation failed ❌";exit 125 ;fi \
	&& echo "\t- validation success ✅"

# ----------- EXERCICES ---------------#
testingcom:
	@echo "..............."
	@echo ${PYTHON_VERSION}
	. $(DATA_ENV_DIR)/.venv/bin/activate \
	PYTHON_VERSION := && python -V | grep 3.12.2
	@echo ${PYTHON_VERSION}

# ----------     exit code     ----------
# needs .ONESHELL: at the begining lines
exit1:
	@ echo hi second
	exit
	@ echo "i wont be printed"

# ---------- make if condition ----------
testif:
# change test2 value to modify condition execution
ifeq (test2 , $(var1))
	echo "equals"
# next line changes variable value
	$(eval PYTHON_VERSION=t)
else
	echo "no tequals"
endif
	@echo ${PYTHON_VERSION} 
# ---------- if condition shell ---------
all: first dosomething

first:
	@echo "hello"

dosomething:
	@if [ "test1" = $(var1) ]; then\
		echo "world";\
		exit 0;\
	elif [ "test2" = $(var1) ]; then\
		echo "second if"
	fi


dvc-push:
	@echo "Pushing data..."
	. $(DATA_ENV_DIR)/.venv/bin/activate \
	&& dvc status | grep .dvc |while read remote; do \
	echo "\t-->" $${remote}
	if [ "Data.zip.dvc:" = $${remote} ]; then \
		echo "\t--> Please wait, zipping Data folder ..."
		zip -r -qq Data.zip Data/
		dvc add Data.zip
		git add Data.zip.dvc
		git commit -m "Data.zip.dvc added with 'dvc add' command"
		dvc push Data.zip.dvc
		git add Data.zip.dvc
		git commit -m "Data.zip pushed with 'dvc push' command"\;

	elif [ "Weights.dvc:" = $${remote} ]; then\
		dvc add Weights
		git add Weights.dvc
		git commit -m "Weights.dvc added with 'dvc add' command"
		dvc push Weights.dvc
		git add Weights.dvc
		git commit -m "Weights.dvc pushed with 'dvc push' command";
	fi; \
	done

num-dvc-changes:
	@echo "## Number of dvc files that has changed"
	. $(DATA_ENV_DIR)/.venv/bin/activate \
	&& dvc status | grep .dvc | wc -l

testcondi:
ifeq ($(findstring NT-5.1,$(VARIABLE)),NT-5.1)
	echo "found"
	@echo ${VARIABLE}
else
	@echo ${VARIBALE}
	echo "not found"
endif
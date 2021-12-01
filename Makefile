.PHONY: clean upgrade test quality quality-python test-python requirements
# Generates a help message. Borrowed from https://github.com/pydanny/cookiecutter-djangopackage.
help: ## display this help message
	@echo "Please use \`make <target>\` where <target> is one of"
	@perl -nle'print $& if m{^[\.a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-25s\033[0m %s\n", $$1, $$2}'

clean: ## delete generated byte code and coverage reports
	find . -name '*.pyc' -delete
	find . -name '__pycache__' -type d -exec rm -rf {} ';' || true
	rm -rf coverage htmlcov
	rm -rf assets
	rm -rf pii_report

upgrade: export CUSTOM_COMPILE_COMMAND=make upgrade
upgrade: ## update the requirements/*.txt files with the latest packages satisfying requirements/*.in
	pip install -q -r requirements/pip_tools.txt
	pip-compile --upgrade -o requirements/pip_tools.txt requirements/pip_tools.in
	pip-compile --upgrade -o requirements/base.txt requirements/base.in
	pip-compile --upgrade -o requirements/dev.txt requirements/dev.in
	pip-compile --upgrade -o requirements/production.txt requirements/production.in
	pip-compile --upgrade -o requirements/doc.txt requirements/doc.in
	pip-compile --upgrade -o requirements/test.txt requirements/test.in
	pip-compile --upgrade -o requirements/ci.txt requirements/ci.in


requirements: ## install development environment requirements
	pip install -q -r requirements/pip_tools.txt
	pip install -qr requirements/base.txt --exists-action w
	pip-sync requirements/base.txt requirements/constraints.txt requirements/test.txt requirements/ci.txt

quality-python: ## Run python linters
	flake8 . --count --select=E901,E999,F821,F822,F823 --show-source --statistics
	flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

quality: quality-python ## Run linters

test-python: clean ## run tests and generate coverage report
	pytest --cov-branch --cov=ease ease/tests

test: test-python ## run tests

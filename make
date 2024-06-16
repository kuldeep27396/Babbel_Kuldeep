# Variables
PYTHON_INTERPRETER := python3
TF_DIR := terraform
LAMBDA_ZIP := process_events.zip
LAMBDA_FUNCTION_NAME := ProcessEventsLambda
TF_VARS := $(TF_DIR)/terraform.tfvars

# Targets
.PHONY: setup deploy test clean

setup:
	@echo "=== Setting up Python environment ==="
	@$(PYTHON_INTERPRETER) -m venv venv
	@venv\Scripts\activate.bat
	@$(PYTHON_INTERPRETER) -m pip install --upgrade pip setuptools wheel
	@$(PYTHON_INTERPRETER) -m pip install -r requirements.txt

deploy: $(LAMBDA_ZIP)
	@echo "=== Deploying Lambda function and infrastructure ==="
	@cd $(TF_DIR) && terraform init
	@cd $(TF_DIR) && terraform apply -auto-approve

test:
	@echo "=== Running tests ==="
	@$(PYTHON_INTERPRETER) -m pytest tests

clean:
	@echo "=== Cleaning up ==="
	@cd $(TF_DIR) && terraform destroy -auto-approve
	@rm -rf venv $(LAMBDA_ZIP)

$(LAMBDA_ZIP): lambda_function.py
	@zip -r $(LAMBDA_ZIP) process_events.py

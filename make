# Variables
TF_DIR := terraform
LAMBDA_ZIP := lambda_function.zip
LAMBDA_FUNCTION_NAME := ProcessEventsLambda
TF_VARS := $(TF_DIR)/terraform.tfvars

# Targets
.PHONY: setup deploy test clean

setup:
	@echo "=== Setting up environment ==="
	@echo "Installing Terraform dependencies..."
	@cd $(TF_DIR) && terraform init

deploy: $(LAMBDA_ZIP)
	@echo "=== Deploying Lambda function and infrastructure ==="
	@echo "Packaging Lambda function..."
	@zip -r $(LAMBDA_ZIP) lambda_function.py
	@echo "Deploying infrastructure with Terraform..."
	@cd $(TF_DIR) && terraform apply -auto-approve

test:
	@echo "=== Running tests ==="
	@echo "Running unit tests..."
	@python -m unittest discover -s tests -p '*_test.py'

clean:
	@echo "=== Cleaning up ==="
	@echo "Removing Terraform state and temporary files..."
	@cd $(TF_DIR) && terraform destroy -auto-approve
	@rm -f $(LAMBDA_ZIP)

$(LAMBDA_ZIP): lambda_function.py
	@zip -r $(LAMBDA_ZIP) lambda_function.py

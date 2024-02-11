init:
	@terraform init -upgrade

fmt:
	@terraform fmt -recursive

validate:
	@terraform validate

apply:
	@terraform apply -auto-approve -var-file=secrets.tfvars

destroy:
	@terraform destroy -auto-approve -var-file=secrets.tfvars

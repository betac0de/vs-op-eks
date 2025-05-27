terraform init -reconfigure
terraform validate
terraform fmt -recursive
terraform plan -out=tfplan
#terraform show -no-color tfplan > tfplan.txt
#terraform apply -auto-approve tfplan
terraform destroy -auto-approve
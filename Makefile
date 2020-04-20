
all:
	dotnet clean src \
		&& dotnet build src \
		&& dotnet run src

clean: 
	dotnet clean src

tf-init:
	cd terraform \
		&& terraform init

aws-lambda-build: 
	rm -f randomize.zip \
		&& dotnet build -c Release src \
		&& zip -j -r randomize.zip src/bin/Release/netcoreapp3.1

aws-lambda-cb: clean aws-lambda-build

aws-bucket-create:
	aws s3api create-bucket --bucket=randomize-lambda --region=eu-central-1 --create-bucket-configuration "LocationConstraint='eu-central-1'"

aws-bucket-delete:
	aws s3api delete-bucket --bucket=randomize-lambda --region=eu-central-1

aws-deploy:
	aws s3 cp randomize.zip s3://randomize-lambda/randomize.zip

aws-init:
	cd terraform/aws-lambda \
		&& terraform init

aws-plan:
	cd terraform/aws-lambda \
		&& terraform plan		

aws-apply:
	cd terraform/aws-lambda \
		&& terraform apply

aws-destroy:
	cd terraform/aws-lambda \
		&& terraform destroy

aws-show:
	cd terraform/aws-lambda \
		&& terraform show

aws-test:
	curl --verbose --request POST ${AWS_ENDPOINT} --data '{wizardName}'

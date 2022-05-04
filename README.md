# Use Terraform (insfrastructure as a code)

## To start
first follow [THIS INSTRUCTION](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

for local usage, you can use `aws` cli and add credentials to file `~/.aws/credentials`
```
[default]
aws_access_key_id = your_access_key_id
aws_secret_access_key = your_secret_access_key
```

or add credentials as environment variables
```
export AWS_ACCESS_KEY_ID=your_access_key_id
export AWS_SECRET_ACCESS_KEY=your_secret_access_key
```
or add credentials to TF (terraform)

```
provider "aws" {
  region     = "us-west-2"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}
```

### Generate key

generate rsa key
ssh-keygen -t rsa -b 4096 -f deploy_key

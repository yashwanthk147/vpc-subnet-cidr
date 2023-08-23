#!/bin/bash

# Configure access key and secret key
if [[ ! -f ~/.aws/credentials ]]; then
  echo "AWS credentials not found. Configuring..."
  mkdir -p ~/.aws
  echo "[default]" > ~/.aws/credentials
  echo "aws_access_key_id = AKIAVCY2ACKXRYFQRKEA" >> ~/.aws/credentials
  echo "aws_secret_access_key = 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" >> ~/.aws/credentials
  echo "region = us-east-1" >> ~/.aws/credentials
fi

# Fetch VPC IDs
vpc_ids=$(aws ec2 describe-vpcs --query 'Vpcs[*].VpcId' --output json)

# Save VPC and subnet details in a CSV file
output_file="vpc_us-east-1_cidr.csv"
echo "vpcid, cidrblock, subnetcidrblock" > "$output_file"

# Iterate over VPC IDs
for vpc_id in $(echo "$vpc_ids" | jq -r '.[]'); do
  vpc_cidr=$(aws ec2 describe-vpcs --vpc-ids "$vpc_id" --query 'Vpcs[0].CidrBlock' --output json)
  subnet_cidrs=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id" --query 'Subnets[*].CidrBlock' --output json | jq -r '@csv')
  echo "$vpc_id,$vpc_cidr,$subnet_cidrs" | sed 's/\"//g' >> "$output_file"
done

# Print success message
echo "VPC and subnet details saved in $output_file"

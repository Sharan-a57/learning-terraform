
# ✅ Terraform, GitHub Actions, OIDC, EC2 Runner Setup — Summary Notes

## 📌 Part 1: GitHub OIDC with AWS — Detailed Steps

### 🔐 Goal:
Let GitHub Actions assume an IAM role via OIDC without storing AWS credentials.

### 🧭 Step-by-Step:

#### 1. Create the OIDC Provider in AWS
**Path:** IAM > Identity providers > Add provider  
- **Provider type:** OIDC  
- **Provider URL:** `https://token.actions.githubusercontent.com`  
- **Audience:** `sts.amazonaws.com`  

#### 2. Create an IAM Role with OIDC Trust Policy
**Path:** IAM → Roles → Create role  
- **Select:** Web identity  
- **Choose Provider:** `token.actions.githubusercontent.com`  
- **Audience:** `sts.amazonaws.com`  

**Trust Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Principal": {
        "Federated": "arn:aws:iam::<your-account-id>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:<owner>/<repo>:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

**Example:**  
`"repo:Sharan-a57/learning-terraform:ref:refs/heads/main"`

#### 3. Give the Role Necessary Policies
Attach policies like:
- `AmazonS3FullAccess`
- `AmazonEC2ReadOnlyAccess`
- Or your custom least-privilege policies

#### 4. Store the Role ARN in GitHub Repo Variables
**Path:** GitHub → Repo → Settings > Actions > Variables  
- **Key:** `awsOIDCroleARN`  
- **Value:** `arn:aws:iam::<account-id>:role/<your-role-name>`

#### 5. GitHub Actions Workflow Config
```yaml
name: Terraform Deploy

on:
  push:
    branches:
      - main
    paths:
      - 'dev/**'

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v3
        with:
          role-to-assume: ${{ vars.awsOIDCroleARN }}
          aws-region: us-east-1

      - name: Verify identity
        run: aws sts get-caller-identity
```

## 🖥️ Part 2: Self-Hosted GitHub Runner on EC2

### ✅ Steps:
1. SSH into EC2 instance  
2. Create a user (optional):  
   ```bash
   sudo useradd -m github
   ```
3. Download GitHub Actions runner from the repo settings  
4. Configure runner:  
   ```bash
   ./config.sh --url https://github.com/<owner>/<repo> --token <token>
   ```
5. Install and start the service:  
   ```bash
   sudo ./svc.sh install
   sudo ./svc.sh start
   ```

## ☁️ Part 3: Terraform Job Splitting

### Separate Jobs for `init`, `plan`, and `apply`
```yaml
jobs:
  init:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v3
        with:
          role-to-assume: ${{ vars.awsOIDCroleARN }}
          aws-region: us-east-1
      - run: terraform init

  plan:
    runs-on: self-hosted
    needs: init
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v3
        with:
          role-to-assume: ${{ vars.awsOIDCroleARN }}
          aws-region: us-east-1
      - run: terraform plan

  apply:
    runs-on: self-hosted
    needs: plan
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v3
        with:
          role-to-assume: ${{ vars.awsOIDCroleARN }}
          aws-region: us-east-1
      - run: terraform apply -auto-approve
```

## 📦 Part 4: Importing EC2 into Terraform

**Create `ec2.tf` with:**
```hcl
resource "aws_instance" "github_runner" {
  ami                    = "ami-020cba7c55df1f615"
  instance_type          = "t2.micro"
  key_name               = "orca"
  subnet_id              = "subnet-0e6e74cce606d5543"
  vpc_security_group_ids = ["sg-03ceef03176846b70"]
  tags = {
    Name = "github_runner"
  }
}
```

**Run import:**
```bash
terraform import aws_instance.github_runner i-09ce023c79469e59d
```

**Or if in a module:**
```bash
terraform import module.ec2_runner.aws_instance.github_runner i-09ce023c79469e59d
```

## 📁 Part 5: Creating an S3 Bucket with Terraform

```hcl
resource "aws_s3_bucket" "my_bucket" {
  bucket        = "sharan-terraform-bucket-2025"
  force_destroy = true
  tags = {
    Name        = "MyBucket"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.my_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket = aws_s3_bucket.my_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

## 🧠 Bonus: GitHub Actions Triggers

Trigger only on push to main and changes in `dev/` directory:
```yaml
on:
  push:
    branches:
      - main
    paths:
      - 'dev/**'
```

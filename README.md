# Football Application ⚽

## Overview
This is a **Football Application** where users can log in and view player data fetched from AWS services.

## Infrastructure
- Provisioned using **Terraform** and **AWS**.
- Services used:
  - AWS Lambda
  - API Gateway
  - DynamoDB
  - IAM Policies and Roles
  - S3 Buckets and Triggers

## How It Works
- **Data Population**:  
  Upload a `data.csv` file to the S3 bucket to automatically populate the DynamoDB table via S3 triggers.
  
- **Frontend**:  
  A **React application** with:
  - Login system (Access and Refresh Tokens)
  - Fetches player data securely using AWS API Gateway.

- **Backend**:
  - Lambda functions handle the logic.
  - Code is organized into three main directories:
    - `frontend/` - React application
    - `backend/` - Lambda function code
    - `terraform/` - Terraform scripts for infrastructure as code

- **Deployment Pipeline**:
  - A `make_packages.groovy` script is available to create Lambda deployment artifacts, helping streamline the CI/CD pipeline.

---

## Directory Structure
football_app/ 
├── backend/ # Lambda code 
├── frontend/ # React app 
├── terraform/ # Terraform scripts 
└── make_packages.groovy

---

## Setup Instructions (Coming Soon)---
# Football Application ⚽

## Overview
This is a **Football Application** built using **AWS** services and a **React** frontend. It allows users to log in, retrieve player data, and display information on football players.

## Infrastructure
- **Terraform** and **AWS** are used to provision the infrastructure.
- **AWS Services** utilized:
  - **Lambda**: For backend logic
  - **API Gateway**: To expose RESTful APIs
  - **DynamoDB**: To store player data
  - **IAM**: For policies and roles
  - **S3 Buckets**: To store CSV files
  - **Triggers**: For S3 to DynamoDB integration

## Data Flow
1. **Populate DynamoDB**:  
   The `data.csv` file is uploaded to the S3 bucket, which triggers an AWS Lambda function to process the file and populate the DynamoDB table.
   
2. **Frontend**:  
   - Built with **React**.
   - Includes a **Login system** utilizing **Access Tokens** and **Refresh Tokens** for authentication.
   - The React app fetches football player data via **AWS API Gateway**.

3. **Backend**:  
   - **Lambda** functions reside in the `backend/` folder, handling the core logic such as CSV parsing and data insertion into DynamoDB.
   - **Frontend** code resides in the `frontend/` folder.
   - **Terraform** code, located in `terraform/`, handles the infrastructure setup.

4. **Deployment Pipeline**:
   - The project includes a **make_packages.groovy** script to streamline the process of creating Lambda artifacts and deploying them.

---

## Deployment Process
1. **Terraform** scripts are in the `terraform/` folder, used to provision AWS resources like DynamoDB, S3, Lambda, and API Gateway.
2. The **make_packages.groovy** script is used to package and deploy Lambda artifacts.

---
### Backend
- To set up the backend (Lambda), use AWS CLI or SDK to test the functions locally.

### Frontend
- Navigate to the `frontend/` directory.
- Update your .env file to the apigateway endpoint.
- Run the React app:

#### For Development Environment
```
yarn dev 
```

#### For Production build the project and serve it (In future will move to vercel or AWS Amplify)
```
yarn build 
```

```
yarn serve 
```

## Setup Instructions
1. Make sure you have your aws credentials configured using 
```
aws configure
```
2. Validate terraform scripts using 
```
terraform validate
```
3. Check out infra by  
```
terraform plan
```
4. Finally deploy the infrastructure using 
```
terraform apply
```
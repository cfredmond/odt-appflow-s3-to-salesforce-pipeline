# ODT Terraform Infrastructure

This Terraform configuration sets up the necessary AWS infrastructure for the ODT (Operational Data Transfer) project in the development (dev) environment. It provisions Amazon S3 buckets for source and destination data storage, configures appropriate IAM policies for AWS AppFlow integration, and establishes an AppFlow flow to transfer data from the source to the destination bucket.

## Table of Contents

- [ODT Terraform Infrastructure](#odt-terraform-infrastructure)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Usage](#usage)
  - [Resources Created](#resources-created)
    - [S3 Buckets](#s3-buckets)
    - [IAM Policies](#iam-policies)
    - [AppFlow Flow](#appflow-flow)
  - [Outputs](#outputs)
  - [Project Structure](#project-structure)
  - [Notes](#notes)
  - [License](#license)
- [Acknowledgements](#acknowledgements)
- [Contact](#contact)

## Prerequisites

Before deploying this Terraform configuration, ensure you have the following:

- **Terraform**: Version 0.12 or later. [Download Terraform](https://www.terraform.io/downloads.html)
- **AWS CLI**: Configured with appropriate credentials and permissions. [Install AWS CLI](https://aws.amazon.com/cli/)
- **AWS Account**: With permissions to create S3 buckets, IAM policies, and AppFlow flows.

## Usage

1. **Clone the Repository**

   ```bash
   git clone https://github.com/cfredmond/odt-aws-to-salesforce-pipeline.git
   cd odt-aws-to-salesforce-pipeline/terraform
   ```

2. **Initialize Terraform**

   Initialize the Terraform working directory. This command downloads the necessary provider plugins.

   ```bash
   terraform init
   ```

3. **Review the Plan**

   Generate and review the execution plan to understand the changes Terraform will make.

   ```bash
   terraform plan
   ```

4. **Apply the Configuration**

   Apply the Terraform configuration to create the resources.

   ```bash
   terraform apply
   ```

   Confirm the apply step by typing `yes` when prompted.

5. **Retrieve Outputs**

   After a successful apply, Terraform will display the outputs, including the names of the created S3 buckets.

   ```bash
   terraform output
   ```

## Resources Created

### S3 Buckets

1. **ODT Source Bucket (Dev Environment)**

   - **Resource Name**: `aws_s3_bucket.odt_source_dev`
   - **Bucket Name**: `odt-source-dev-<random_suffix>`
   - **Tags**:
     - Name: `odt-source-dev`
     - Environment: `dev`
     - Project: `odt`
     - ManagedBy: `Terraform`

   This bucket serves as the source for data in the ODT pipeline.

2. **ODT Destination Bucket (Dev Environment)**

   - **Resource Name**: `aws_s3_bucket.odt_destination_dev`
   - **Bucket Name**: `odt-destination-dev-<random_suffix>`
   - **Tags**:
     - Name: `odt-destination-dev`
     - Environment: `dev`
     - Project: `odt`
     - ManagedBy: `Terraform`

   This bucket serves as the destination for data processed by the ODT pipeline.

### IAM Policies

1. **Source Bucket Policy**

   - **Resource Name**: `aws_s3_bucket_policy.odt_source_policy`
   - **Policy**: Allows AWS AppFlow to perform `s3:ListBucket` and `s3:GetObject` actions on the source bucket.

2. **Destination Bucket Policy**

   - **Resource Name**: `aws_s3_bucket_policy.odt_destination_policy`
   - **Policy**: Allows AWS AppFlow to perform actions such as `s3:PutObject`, `s3:AbortMultipartUpload`, `s3:ListMultipartUploadParts`, `s3:ListBucketMultipartUploads`, `s3:GetBucketAcl`, `s3:PutObjectAcl`, and `s3:ListBucket` on the destination bucket.

### AppFlow Flow

- **Resource Name**: `aws_appflow_flow.odt_aws_to_s3_flow`
- **Flow Name**: `odt-aws-to-s3-dev`
- **Configuration**:
  - **Source**: ODT Source S3 Bucket
    - **Connector Type**: S3
    - **Bucket Prefix**: `odt-source-dev-data.csv`
  - **Destination**: ODT Destination S3 Bucket
    - **Connector Type**: S3
    - **Output Format**: Path-based prefix
  - **Tasks**:
    - **FilterTask**: Projects specific fields (`CustomerID`, `FirstName`, `LastName`, `Email`, `Phone`) from the source data.
    - **Mapping Tasks**: Maps each source field to the corresponding destination field without any transformation.
  - **Trigger**: On-demand (manual trigger)

## Outputs

After applying the Terraform configuration, the following outputs will be available:

- **`odt_source_s3_bucket_name`**
  - **Description**: The name of the ODT source S3 bucket (Dev environment)
  - **Value**: `odt-source-dev-<random_suffix>`

- **`odt_destination_s3_bucket_name`**
  - **Description**: The name of the ODT destination S3 bucket (Dev environment)
  - **Value**: `odt-destination-dev-<random_suffix>`

You can access these outputs using the `terraform output` command.

## Project Structure

```
odt-terraform-infrastructure/
├── main.tf          # Main Terraform configuration file
├── variables.tf     # (Optional) Variable definitions
├── outputs.tf       # Output definitions
├── README.md        # This README file
└── terraform.tfstate # Terraform state file (generated after apply)
```

*Note: The state file (`terraform.tfstate`) is generated after applying the configuration and should be managed securely.*

## Notes

- **Bucket Naming**: The S3 bucket names include a random suffix to ensure uniqueness across AWS. The `random_string` resource generates a 6-character lowercase alphanumeric string for this purpose.

- **Access Control**: The ACL for both S3 buckets is commented out (`# acl = "private"`). By default, S3 buckets are private. Ensure that the appropriate access controls are in place based on your security requirements.

- **AppFlow Trigger**: The AppFlow flow is configured with an `OnDemand` trigger. This means the flow needs to be triggered manually. You can modify the trigger configuration to suit your automation needs (e.g., schedule-based triggers).

- **Terraform State Management**: Ensure that the Terraform state file is stored securely, especially if using remote backends. Consider using Terraform Cloud, AWS S3 with state locking, or other secure backends for state management.

## License

This project is licensed under the [MIT License](LICENSE).

# Acknowledgements

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS AppFlow Documentation](https://docs.aws.amazon.com/appflow/index.html)

# Contact

For any questions or issues, please open an issue in the repository or contact the maintainer at [charles.redmond@gmail.com](mailto:charles.redmond@gmail.com).
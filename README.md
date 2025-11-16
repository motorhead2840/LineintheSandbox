# LineintheSandbox - Terraform Configuration

This repository contains Terraform configurations for managing Google Cloud Platform (GCP) infrastructure.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.8.0
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- GCP Project with appropriate permissions

## Getting Started

### 1. Configure Variables

Copy the example variables file and update with your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and provide your GCP project ID and preferred region.

### 2. Initialize Terraform

Initialize the Terraform working directory:

```bash
terraform init
```

If using a GCS backend for state storage:

```bash
terraform init -backend-config="bucket=your-terraform-state-bucket"
```

### 3. Plan Changes

Review the execution plan:

```bash
terraform plan
```

### 4. Apply Changes

Apply the Terraform configuration:

```bash
terraform apply
```

## Testing

This repository includes automated tests for Terraform configurations using the native `terraform test` command.

### Running Tests Locally

To run all tests:

```bash
terraform test
```

The tests validate:
- Variable configuration and defaults
- Output values match expected inputs
- Configuration is valid and can be planned

Test files are located in the `tests/` directory:
- `tests/main.tftest.hcl` - Core configuration tests
- `tests/variables.tftest.hcl` - Variable validation tests

### Test Coverage

The test suite covers:
- Required variables (project_id)
- Default values (region defaults to us-central1)
- Custom variable overrides
- Output value correctness

## CI/CD

This repository includes automated CI/CD pipelines:

- **GitHub Actions**: See `.github/workflows/terraform.yml`
- **Google Cloud Build**: See `cloudbuild.yaml`

## Security

Please refer to [SECURITY.md](SECURITY.md) for security policies and reporting procedures.

## License

See [LICENSE](LICENSE) file for details.

# Copilot Custom Instructions

## Project Purpose

This is a sandbox repository for testing and experimenting with infrastructure as code (IaC) using Terraform and cloud deployment pipelines. The repository is designed to demonstrate CI/CD workflows for Terraform deployments on Google Cloud Platform (GCP) and GitHub Actions.

## Repository Structure

- `Terraform.yml` - GitHub Actions workflow for Terraform CI/CD
- `cloudbuild.yaml` - Google Cloud Build configuration for Terraform deployments
- `SECURITY.md` - Security policy and vulnerability reporting guidelines
- `LICENSE` - Repository license information

## Workflow and Development Process

### CI/CD Pipelines

1. **GitHub Actions Workflow** (`Terraform.yml`):
   - Triggers on pushes and pull requests to the `main` branch
   - Performs Terraform initialization, formatting checks, planning, and apply operations
   - Requires GCP credentials stored in GitHub Secrets (`GCP_CREDENTIALS`)

2. **Google Cloud Build** (`cloudbuild.yaml`):
   - Executes Terraform init, validate, plan, and apply steps
   - Designed for GCP Cloud Build triggers

### Making Changes

- Any infrastructure changes should be implemented through Terraform configurations
- Always run `terraform fmt` to format code before committing
- Ensure terraform files validate successfully with `terraform validate`
- Test changes in a non-production environment first

## Coding Standards

### Terraform Best Practices

- Use Terraform 1.8.x or compatible versions
- Format all Terraform code with `terraform fmt`
- Validate configurations with `terraform validate` before committing
- Use meaningful resource names and add comments for complex configurations
- Store state files in remote backends (currently configured for GCS bucket)

### GitHub Workflows

- Keep workflow files well-documented with clear step names
- Use pinned versions for actions (e.g., `@v4`, `@v3`)
- Store sensitive credentials in GitHub Secrets, never in code

### Documentation

- Update documentation when adding new infrastructure or workflows
- Keep README files current with setup and usage instructions
- Document any prerequisites or dependencies

## Environment Setup

### Prerequisites

- Terraform 1.8.x or later
- Google Cloud SDK (for GCP deployments)
- Appropriate GCP service account with necessary permissions
- GitHub repository secrets configured for CI/CD

### Local Development

If working with Terraform locally:
1. Install Terraform 1.8.x from [terraform.io](https://www.terraform.io/downloads)
2. Configure GCP credentials using `gcloud auth application-default login`
3. Initialize Terraform: `terraform init -backend-config="bucket=your-terraform-state-bucket"`
4. Format code: `terraform fmt`
5. Validate: `terraform validate`
6. Plan changes: `terraform plan`

## Security Considerations

- Never commit sensitive information (API keys, credentials, passwords)
- Use GitHub Secrets for storing credentials
- Follow the security policy outlined in `SECURITY.md`
- Review and validate all Terraform plans before applying
- Use appropriate IAM roles with least privilege principle

## Testing

- Test infrastructure changes in a development/staging environment first
- Review Terraform plans carefully before applying to production
- Validate configurations with `terraform validate`
- Use `terraform plan` to preview changes before applying

## Support and Issues

For security vulnerabilities, follow the reporting process in `SECURITY.md`.
For other issues or questions, open an issue in the repository.

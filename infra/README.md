# ZenMarket Platform - Infrastructure as Code

This directory contains Terraform configurations for deploying the ZenMarket GCP web application platform infrastructure.

## Overview

The ZenMarket infrastructure includes:

- **Google Cloud APIs** - Enabled services for Cloud Run, Firestore, Vertex AI, Secret Manager, Cloud Build, Artifact Registry, and Storage
- **Firestore Database** - Native mode NoSQL database for application data
- **Cloud Storage Bucket** - Object storage for resource/media content
- **Secret Manager Secrets** - Secure storage for sensitive configuration (Stripe, Bitcoin credentials)
- **Artifact Registry** - Docker container image repository
- **Service Account** - Dedicated service account with appropriate IAM permissions

## Prerequisites

Before deploying this infrastructure, ensure you have:

1. **Terraform** >= 1.8.0 installed ([Download](https://www.terraform.io/downloads))
2. **Google Cloud SDK** installed and configured ([Install Guide](https://cloud.google.com/sdk/docs/install))
3. **GCP Project** with billing enabled
4. **Appropriate permissions** to create resources (Project Owner or Editor recommended)
5. **GCS bucket** for Terraform state storage (recommended for team environments)

### Required GCP Permissions

The user or service account running Terraform needs the following roles:

- `roles/serviceusage.serviceUsageAdmin` - To enable APIs
- `roles/iam.serviceAccountAdmin` - To create service accounts
- `roles/iam.securityAdmin` - To manage IAM bindings
- `roles/secretmanager.admin` - To create secrets
- `roles/storage.admin` - To create buckets
- `roles/artifactregistry.admin` - To create repositories
- `roles/datastore.owner` - To create Firestore databases

## Quick Start

### 1. Authenticate with GCP

```bash
# Login to Google Cloud
gcloud auth login

# Set application default credentials for Terraform
gcloud auth application-default login

# Set your project (default is "sruti")
gcloud config set project sruti
```

### 2. Configure Variables

```bash
# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars  # or your preferred editor
```

Optional variable to update (default provided):
- `project_id` - GCP project ID (default: sruti)

Optional variables (defaults provided):
- `region` - GCP region (default: us-central1)
- `environment` - Deployment environment: dev, staging, or prod (default: dev)
- `firestore_location` - Firestore database location (default: us-central)

### 3. Initialize Terraform

```bash
# Without remote state (local state file)
terraform init

# With remote GCS state (recommended for teams)
terraform init -backend-config="bucket=your-terraform-state-bucket" -backend-config="prefix=zenmarket/state"
```

### 4. Review the Execution Plan

```bash
terraform plan
```

Review the planned changes carefully before proceeding.

### 5. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### 6. Note the Outputs

After successful deployment, Terraform will display important outputs including:

- Service account email
- Storage bucket name
- Docker repository URL
- Secret IDs for updating

## Post-Deployment Steps

### Update Secret Values

The secrets are created with placeholder values. **You must update them with real values before deploying your application.**

Using gcloud CLI:

```bash
# Update Stripe secret key
echo -n "sk_live_your_actual_stripe_key" | \
  gcloud secrets versions add zenmarket-stripe-secret-key-dev --data-file=-

# Update Bitcoin node RPC password
echo -n "your_btc_rpc_password" | \
  gcloud secrets versions add zenmarket-btc-node-rpc-password-dev --data-file=-

# Update Bitcoin wallet extended private key
echo -n "your_btc_wallet_xpriv" | \
  gcloud secrets versions add zenmarket-btc-wallet-xpriv-dev --data-file=-
```

Or using the GCP Console:
1. Navigate to **Secret Manager** in the Cloud Console
2. Click on each secret
3. Click **+ NEW VERSION**
4. Enter the actual secret value
5. Click **ADD NEW VERSION**

### Build and Push Container Image

```bash
# Configure Docker for Artifact Registry
gcloud auth configure-docker REGION-docker.pkg.dev

# Build your container image
docker build -t REGION-docker.pkg.dev/PROJECT_ID/zenmarket-docker-dev/zenmarket:latest .

# Push to Artifact Registry
docker push REGION-docker.pkg.dev/PROJECT_ID/zenmarket-docker-dev/zenmarket:latest
```

### Deploy to Cloud Run

After building and pushing your container image:

```bash
gcloud run deploy zenmarket-dev \
  --image=REGION-docker.pkg.dev/PROJECT_ID/zenmarket-docker-dev/zenmarket:latest \
  --platform=managed \
  --region=REGION \
  --service-account=zenmarket-app-dev@PROJECT_ID.iam.gserviceaccount.com \
  --set-secrets=STRIPE_SECRET_KEY=zenmarket-stripe-secret-key-dev:latest \
  --set-secrets=BTC_NODE_RPC_PASSWORD=zenmarket-btc-node-rpc-password-dev:latest \
  --set-secrets=BTC_WALLET_XPRIV=zenmarket-btc-wallet-xpriv-dev:latest \
  --allow-unauthenticated
```

## File Structure

```
infra/
├── main.tf                    # Main Terraform configuration and providers
├── variables.tf               # Input variable definitions
├── outputs.tf                 # Output definitions
├── versions.tf                # Provider version constraints
├── apis.tf                    # GCP API enablement
├── firestore.tf               # Firestore database configuration
├── storage.tf                 # Cloud Storage bucket configuration
├── secrets.tf                 # Secret Manager secrets
├── artifact_registry.tf       # Artifact Registry Docker repository
├── service_account.tf         # Service account and IAM bindings
├── terraform.tfvars.example   # Example variables file
└── README.md                  # This file
```

## Configuration Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `project_id` | GCP project ID | `sruti` | No |
| `region` | GCP region | `us-central1` | No |
| `zone` | GCP zone | `us-central1-a` | No |
| `app_name` | Application name | `zenmarket` | No |
| `environment` | Environment (dev/staging/prod) | `dev` | No |
| `firestore_location` | Firestore location | `us-central` | No |
| `storage_class` | Storage class | `STANDARD` | No |
| `labels` | Additional resource labels | `{}` | No |

## Important Notes

### Firestore Database

- Only one default Firestore database can exist per GCP project
- The database location cannot be changed after creation
- In some regions, you may need to create an App Engine app first (the console will guide you)

### Secrets Management

- Secrets are created with placeholder values
- **Never commit actual secret values to version control**
- Update secrets via gcloud CLI or GCP Console before deploying your application
- Use secret versions for rotation (the app should reference `:latest` or a specific version)

### Service Account Permissions

The application service account is granted:

| Role | Purpose |
|------|---------|
| `roles/datastore.user` | Read/write Firestore data |
| `roles/aiplatform.user` | Use Vertex AI services |
| `roles/secretmanager.secretAccessor` | Access secrets (per-secret) |
| `roles/storage.objectAdmin` | Manage objects in content bucket |
| `roles/artifactregistry.reader` | Pull container images |
| `roles/run.invoker` | Invoke Cloud Run services |

### Production Considerations

When deploying to production (`environment = "prod"`):

- Storage bucket versioning is enabled
- Artifact Registry uses immutable tags
- Point-in-time recovery is enabled for Firestore
- Consider enabling deletion protection on critical resources

## Destroying Infrastructure

To destroy all created resources:

```bash
terraform destroy
```

**Warning**: This will delete all resources including data in Firestore and Cloud Storage. Ensure you have backups before destroying production infrastructure.

## Troubleshooting

### API Enablement Errors

If you see errors about APIs not being enabled, wait a few minutes and retry. API enablement can take time to propagate.

### Firestore Already Exists

If you see an error that the Firestore database already exists, you may need to import it:

```bash
terraform import google_firestore_database.main projects/YOUR_PROJECT_ID/databases/(default)
```

### Permission Denied

Ensure your user account or service account has the required roles listed in the Prerequisites section.

## Support

For issues with this infrastructure code, please open an issue in the repository.

For GCP-specific issues, consult the [Google Cloud documentation](https://cloud.google.com/docs).

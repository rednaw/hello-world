# Deploy Your Application (Developer Guide)

**Audience:** Application developers working in their application repository (e.g., `hello-world`)

This guide explains how to **deploy and inspect your application** from your application directory. You don't need to know about infrastructure internals—just run simple commands.

---

## Quick Start

**Deploy a version:**
```bash
task iac:deploy -- dev 706c88c
```

**Arguments:**
- `<environment>`: `dev` or `prod`
- `<sha>`: Short commit SHA (7 characters) of the image to deploy

**See available versions:**
```bash
task iac:versions -- dev
```

That's it! The rest of this guide explains the details.

---

## Prerequisites

**Repository layout:**
```
~/projects/
  ├── hello-world/                      # Your app (you work here)
  |    |-- .github/workflows/
  |    |    |-- build-and-push.yml      # CI/CD workflow
  |    |-- Taskfile.yml                 # Deployment config & commands
  |    |-- docker-compose.yml           # Service definition
  |    |-- Dockerfile                   # Build instructions
  |    |-- env.enc                      # Optional: encrypted secrets
  └── iac/                              # Infrastructure repo (cloned next to your app)
```

**To enable deployment for your app:**

1. **Clone the IAC repo** next to your app and do all steps in the 'getting started' guide
   ```
   ~/projects/
     ├── your-app/
     └── iac/
   ```
2. **Copy `Taskfile.yml`** from `hello-world` to your app root
   - Change `REGISTRY_NAME` to your registry (e.g., `registry.mydomain.com`)
   - Change `IMAGE_NAME` to your image (e.g., `mydomain/myimage`)

3. **Copy `.github/workflows/build-and-push.yml`** from `hello-world`
   - Change `REGISTRY` to match your `REGISTRY_NAME`
   - Change `IMAGE_NAME` to match your `IMAGE_NAME`

4. **Edit your `docker-compose.yml`**
   - Set your app service's image to: `image: ${IMAGE}`

---

## Application Configuration

Your `Taskfile.yml` contains the deployment configuration:

```yaml
version: '3'

vars:
  REGISTRY_NAME: registry.rednaw.nl
  IMAGE_NAME: rednaw/my-app

includes:
  iac:
    taskfile: ../iac/tasks/Taskfile.app.yml
```

**Required vars:**
- `REGISTRY_NAME`: Your Docker registry hostname
- `IMAGE_NAME`: Your image name in the registry

---

## Commands

### `task iac:deploy`

Deploy a specific version to an environment:

```bash
task iac:deploy -- <environment> <sha>
```

**Arguments:**
- `<environment>`: `dev` or `prod`
- `<sha>`: Short commit SHA (7 characters) of the image to deploy

**Examples:**
```bash
task iac:deploy -- dev 706c88c
task iac:deploy -- prod abc1234
```

**What happens:**
1. Resolves the SHA tag → immutable digest
2. Extracts image metadata (description, build time)
3. Deploys to the server via Ansible
4. Records deployment metadata

If the tag doesn't exist or the environment is invalid, you'll get a clear error.

---

### `task iac:versions`

List available versions and deployment status:

```bash
task iac:versions -- <environment>
```

**Arguments:**
- `<environment>`: `dev` or `prod`

**Example:**
```bash
task iac:versions -- dev
```

**Output shows:**
- All available image tags (sorted newest first)
- Build timestamps
- Descriptions (from git commit messages)
- Currently deployed version marked with `→`

Use this to decide what to deploy.

---

## Rollback

Rollback is just deploying an earlier version:

```bash
task iac:deploy -- dev <older-sha>
```

No special rollback logic. No hidden state. Just deploy the version you want.

---

## GitHub Actions Workflow

Your app's GitHub Actions workflow handles:

1. **Building** the Docker image on push to `main`
2. **Tagging** with short commit SHA (`${GITHUB_SHA:0:7}`)
3. **Pushing** to your registry
4. **Adding OCI labels** (description, timestamp, revision, source)

Copy `.github/workflows/build-and-push.yml` from `hello-world` and update `IMAGE_NAME` and `REGISTRY` at the top.

---

## Troubleshooting

**"IAC repository not found"**
- Ensure `../iac` exists
- The IAC repo must be cloned next to your app

**"Could not resolve digest"**
- Make sure the image exists in the registry
- Verify you're logged in: `docker login registry.rednaw.nl`
- Check the SHA tag is correct (7 hex characters)

**"missing required vars"**
- Ensure `REGISTRY_NAME` and `IMAGE_NAME` are set in your Taskfile.yml

---

## Design Principles

- **You deploy versions, not servers** — focus on what, not where
- **Tags are for humans** — use short SHAs you can read
- **Digests are for safety** — deployment uses immutable digests automatically
- **History is never lost** — all deployments are recorded
- **Config over code** — simple YAML, no Ansible knowledge needed

You stay in control of when and what gets deployed. Infrastructure handles the rest.

---

## See Also

- [IAC Ops Guide](../iac/docs/application-deployment.md) — For infrastructure maintainers

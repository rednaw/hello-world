# Deploy Your Application (Developer Guide)

**Audience:** Application developers working in their application repository (e.g., `hello-world`)

This guide explains how to **deploy and inspect your application** from your application directory. You don't need to know about infrastructure internals—just run simple commands.

---

## Quick Start

**Deploy a version:**
```bash
task deploy -- dev 706c88c
```

**Arguments:**
- `<environment>`: `dev` or `prod`
- `<sha>`: Short commit SHA (7 characters) of the image to deploy

**See what's running:**
```bash
task overview -- dev
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
  |    |-- Taskfile.yml                 # Deployment commands
  |    |-- deploy.yml                   # Deployment config
  |    |-- docker-compose.yml           # Service definition
  |    |-- Dockerfile                   # Build instructions
  |    |-- env.enc                      # Optional: encrypted secrets
  └── iac/                              # Infrastructure repo (cloned next to your app)
```

**Your application needs:**
- `Taskfile.yml` — copy **verbatim** from `hello-world`
- `deploy.yml` — copy and adapt (set your registry and image name)
- `docker-compose.yml` — must use `image: ${IMAGE}`
- `Dockerfile` — standard Dockerfile, no special requirements
- `.github/workflows/build-and-push.yml` — copy and adapt (handles OCI labels)

The IAC repository is discovered automatically via `../iac` (or set `IAC_ROOT` environment variable).

---

## Application Configuration

Your `deploy.yml` is a simple config file:

```yaml
# deploy.yml
registry_name: registry.rednaw.nl
image_name: rednaw/my-app
```

**Required fields:**
- `registry_name`: The Docker registry hostname
- `image_name`: Your image name in the registry

---

## Commands

### `task deploy`

Deploy a specific version to an environment:

```bash
task deploy -- <environment> <sha>
```

**Arguments:**
- `<environment>`: `dev` or `prod`
- `<sha>`: Short commit SHA (7 characters) of the image to deploy

**Examples:**
```bash
task deploy -- dev 706c88c
task deploy -- prod abc1234
```

**What happens:**
1. Validates the IAC repository is available
2. Resolves the SHA tag → immutable digest
3. Extracts image metadata (description, build time)
4. Deploys to the server via Ansible
5. Records deployment metadata

If the tag doesn't exist or the environment is invalid, you'll get a clear error.

---

### `task overview`

See available versions and deployment status:

```bash
task overview -- <environment>
```

**Arguments:**
- `<environment>`: `dev` or `prod`

**Examples:**
```bash
task overview -- dev
task overview -- dev rednaw/my-other-app
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
task deploy -- dev <older-sha>
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
- Ensure `../iac` exists (or set `IAC_ROOT` environment variable)
- The IAC repo must be cloned next to your app

**"Could not resolve digest"**
- Make sure the image exists in the registry
- Verify you're logged in: `docker login registry.rednaw.nl`
- Check the SHA tag is correct (7 hex characters)

**"Usage: task deploy..."**
- Check you're running from the app directory (where `Taskfile.yml` is)
- Verify argument count matches the usage

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

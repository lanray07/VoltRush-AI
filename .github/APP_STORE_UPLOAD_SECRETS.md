# App Store Upload Secrets

The `iOS App Store Upload` workflow archives VoltRush AI and uploads an IPA to App Store Connect. It is manually triggered from GitHub Actions.

Add these repository secrets in GitHub:

`Settings -> Secrets and variables -> Actions -> New repository secret`

## Required Secrets

| Secret | Value |
| --- | --- |
| `APPLE_TEAM_ID` | Your Apple Developer Team ID. |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API key ID. |
| `APP_STORE_CONNECT_API_ISSUER_ID` | App Store Connect API issuer ID. |
| `APP_STORE_CONNECT_API_PRIVATE_KEY` | Full contents of the `.p8` private key file, including the `BEGIN PRIVATE KEY` and `END PRIVATE KEY` lines. |

## App Store Connect API Key

Create the API key in App Store Connect:

`Users and Access -> Integrations -> App Store Connect API -> Keys`

Use a key with enough access to manage app builds and TestFlight/App Store upload, such as Admin or App Manager access for this app.

## Running the Workflow

1. Push the workflow to `main`.
2. Add the secrets above.
3. Go to GitHub -> Actions -> `iOS App Store Upload`.
4. Click `Run workflow`.
5. Wait for the build to process in App Store Connect.
6. Return to App Store Connect -> VoltRush AI -> Distribution -> `1.0 Prepare for Submission`.
7. Select the processed build in the Build section.

The workflow sets `CURRENT_PROJECT_VERSION` to the GitHub Actions run number so every upload gets a unique build number.

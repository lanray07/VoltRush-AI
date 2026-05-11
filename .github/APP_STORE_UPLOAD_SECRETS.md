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
| `IOS_DISTRIBUTION_CERTIFICATE_BASE64` | Base64-encoded `.p12` Apple Distribution certificate. |
| `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD` | Password used when exporting the `.p12` certificate. |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64-encoded App Store provisioning profile for `com.voltrushai.app`. |
| `KEYCHAIN_PASSWORD` | Any strong temporary password used by the workflow to create its signing keychain. |

## App Store Connect API Key

Create the API key in App Store Connect:

`Users and Access -> Integrations -> App Store Connect API -> Keys`

Use a key with enough access to manage app builds and TestFlight/App Store upload, such as Admin or App Manager access for this app.

## Signing Certificate and Provisioning Profile

GitHub-hosted macOS runners do not have your Apple signing certificate or App Store provisioning profile. Create/export these from Apple Developer/Xcode:

1. Create or use an `Apple Distribution` certificate.
2. Export it from Keychain Access as a password-protected `.p12`.
3. Create an App Store provisioning profile for bundle ID `com.voltrushai.app`.
4. Download the `.mobileprovision` profile.
5. Base64 encode both files and add them as secrets.

PowerShell examples:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\ios_distribution.p12"))
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\VoltRush_AppStore.mobileprovision"))
```

macOS examples:

```bash
base64 -i ios_distribution.p12 | pbcopy
base64 -i VoltRush_AppStore.mobileprovision | pbcopy
```

## Running the Workflow

1. Push the workflow to `main`.
2. Add the secrets above.
3. Go to GitHub -> Actions -> `iOS App Store Upload`.
4. Click `Run workflow`.
5. Wait for the build to process in App Store Connect.
6. Return to App Store Connect -> VoltRush AI -> Distribution -> `1.0 Prepare for Submission`.
7. Select the processed build in the Build section.

The workflow sets `CURRENT_PROJECT_VERSION` to the GitHub Actions run number so every upload gets a unique build number.

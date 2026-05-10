# App Store Assets

Generated App Store Connect assets for VoltRush AI.

## Product Page Screenshots

Upload these on the app version page under `Previews and Screenshots`:

`AppScreenshots-6.5in-1242x2688/`

These files are sized for the 6.5-inch iPhone slot.

## In-App Purchase Review Screenshots

Upload these on each matching product under `Review Information -> Screenshot`:

`IAPReviewScreenshots-1242x2208/`

These files are sized for App Store Connect's IAP review screenshot upload requirements.

## Regenerating

Run these from PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\AppStoreAssets\Generate-AppStoreScreenshots.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File ".\AppStoreAssets\Generate-IAPReviewScreenshots.ps1"
```

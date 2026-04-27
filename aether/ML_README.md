AetherMind - ML Integration README
=================================

This document explains how the Flutter app integrates with the ML microservice
and how to run the app locally pointing at either the local ML server or the
production Render-hosted ML endpoint.

Configuration
-------------
The Flutter app uses `lib/services/ml_api_config.dart` to determine which ML
endpoints to call. There are three ways to configure the endpoints:

1. Explicit endpoint overrides (highest precedence):
   - `KEYSTROKE_API_URL` : full URL to the keystroke prediction endpoint
   - `TEXT_EMOTION_API_URL` : full URL to the text prediction endpoint

2. Manual local/prod toggle (convenient for development):
   - `ML_USE_LOCAL` : set via `--dart-define=ML_USE_LOCAL=1` to point at the
     local ML server; default is `0` (production Render URL).

3. Local base URL override:
   - `LOCAL_ML_BASE_URL` : if `ML_USE_LOCAL=1` you can override the host and port.

Examples
--------
- Run Flutter and use the remote (default):

```bash
flutter run
```

- Run Flutter and force local ML server (default local port is 10000):

```bash
flutter run --dart-define=ML_USE_LOCAL=1
```

- Run Flutter and explicitly set the text prediction URL:

```bash
flutter run --dart-define=TEXT_EMOTION_API_URL=http://127.0.0.1:10000/predict/text
```

Notes
-----
- Timeouts: The client applies a 4s timeout to ML calls to avoid blocking the
  UI. If the ML server is slow, the controller falls back to the local parser
  and the app continues to save the journal entry.
- Logs: `MlApiConfig.logActiveConfigOnce()` prints the active mode and the
  effective endpoint URIs at runtime which helps confirm the app is using the
  intended backend.
- To test the full production stack make sure the backend `ml_service` is
  deployed (see `ml_service/README.md`) and reachable at
  `https://aethermind-ml.onrender.com` or the host/URL you configured.

Troubleshooting
---------------
- If you get HTTP 404 from the deployed endpoint, verify that `/predict/text`
  exists on the deployed service and redeploy the `ml_service` if necessary.
- When debugging locally, run the ML service with uvicorn and confirm the
  endpoint is reachable using `curl` before launching the Flutter app.

Contact
-------
For issues with model behavior or endpoint availability, check the `ml_service`
logs and confirm model files are present under `ml_service/model/`.

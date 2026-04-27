AetherMind ML Integration Summary
=================================

This short README highlights the ML integration points and next steps for
developers maintaining the project.

Where ML is used
----------------
- Frontend (Flutter):
  - `aether/lib/services/text_emotion_service.dart` — calls `/predict/text`
  - `aether/lib/services/keystroke_service.dart` — calls `/predict`
  - `aether/lib/services/ml_api_config.dart` — central endpoint configuration
  - `aether/lib/services/journal_controller.dart` — orchestrates prediction
    calls and fallbacks
  - `aether/lib/services/journal_parser.dart` — local fallback rule-based
    parser used when ML calls fail
  - `aether/lib/screens/journal_test_screen.dart` — captures keystroke
    features and submits them with journal entries

- Backend (FastAPI):
  - `ml_service/app/keystroke_api.py` — main FastAPI app with `/predict` and
    `/predict/text` routes
  - `ml_service/app/model_loader.py` — loads keystroke and text models
  - `ml_service/app/text_emotion.py` — text prediction wrapper

Developer notes
---------------
- Default behavior in production builds is to call the Render-hosted ML
  service at `https://aethermind-ml.onrender.com`. To point to a local ML
  server during development use `--dart-define=ML_USE_LOCAL=1`.
- The backend must be deployed with the `/predict/text` route available for
  production builds to receive text emotion predictions; otherwise the
  frontend will fallback to the local parser.

Recommended next steps for deployment
-------------------------------------
1. Deploy `ml_service` to Render and verify `/predict/text` returns a
   valid JSON response.
2. Run a production Flutter build and test creating a journal entry to
   confirm the server-side ML predictions are stored correctly.
3. Consider adding a small UI indicator in `ReportScreen` or the journal
   entry UI that shows whether a prediction was provided by ML or the
   fallback parser for easier QA.

Thanks — the ML integration is designed to be robust and fallback-safe.

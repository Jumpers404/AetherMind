import argparse
from pathlib import Path

import joblib
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split

FEATURES = [
    "typing_speed",
    "avg_pause",
    "max_pause",
    "backspace_count",
    "total_time",
    "keystroke_count",
]
TARGET = "emotion"


def train_model(dataset_path: Path, model_output_path: Path) -> float:
    df = pd.read_csv(dataset_path)

    missing_cols = [c for c in FEATURES + [TARGET] if c not in df.columns]
    if missing_cols:
        raise ValueError(f"Missing required columns in dataset: {missing_cols}")

    df = df.dropna(subset=FEATURES + [TARGET])

    x = df[FEATURES]
    y = df[TARGET]

    x_train, x_test, y_train, y_test = train_test_split(
        x,
        y,
        test_size=0.2,
        random_state=42,
        stratify=y if y.nunique() > 1 else None,
    )

    model = RandomForestClassifier(n_estimators=200, random_state=42)
    model.fit(x_train, y_train)

    y_pred = model.predict(x_test)
    accuracy = accuracy_score(y_test, y_pred)
    print(f"Accuracy: {accuracy:.4f}")

    model_output_path.parent.mkdir(parents=True, exist_ok=True)
    joblib.dump(model, model_output_path)
    print(f"Model saved to: {model_output_path}")
    return float(accuracy)


def main() -> None:
    base_dir = Path(__file__).resolve().parents[1]

    parser = argparse.ArgumentParser(description="Train keystroke emotion model")
    parser.add_argument(
        "--dataset",
        default=str(base_dir / "data" / "keystroke_dataset.csv"),
        help="Path to keystroke dataset CSV",
    )
    parser.add_argument(
        "--output",
        default=str(base_dir / "model" / "keystroke_model.pkl"),
        help="Output path for trained model",
    )
    args = parser.parse_args()

    dataset_path = Path(args.dataset)
    output_path = Path(args.output)

    if not dataset_path.exists():
        raise FileNotFoundError(
            f"Dataset not found: {dataset_path}. Place CSV at ml_service/data/keystroke_dataset.csv or pass --dataset."
        )

    train_model(dataset_path, output_path)


if __name__ == "__main__":
    main()

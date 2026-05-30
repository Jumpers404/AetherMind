# AetherMind

AetherMind is a mental wellness platform that integrates machine learning with high-fidelity user experiences to provide deep insights into emotional well-being. The system leverages natural language processing and behavioral metrics to analyze journal entries, offering a data-driven approach to mental health tracking.

## Core Capabilities

### Sentiment and Emotion Analysis
The platform utilizes a multi-layered NLP pipeline to extract emotional markers from textual input. This allows for real-time sentiment tracking and historically aggregated emotional trends.

### Behavioral Keystroke Dynamics
A specialized machine learning service analyzes typing patterns (keystroke dynamics) during the journaling process. This behavioral biometrics approach provides an additional layer of psychological insight, identifying patterns that may correspond to specific mental states.

### Hybrid Inference Engine
To ensure high availability and robust performance, AetherMind employs a hybrid inference strategy. The system prioritizes high-accuracy predictions from a dedicated FastAPI-based ML service while maintaining local, rule-based fallback mechanisms to ensure data processing continuity in offline or high-latency environments.

### Unified Security and Privacy
Authentication and data persistence are handled through a secure Firebase architecture. Data is siloed and encrypted to ensure user privacy, with role-based access control for administrative reporting.

## Planning: Upcoming Features

### Dynamic Pet System
Implementation of an interactive mental health companion utilizing custom GLSL shaders for high-fidelity animations and visual feedback. The pet system is designed to respond dynamically to the user's emotional state, providing a visual anchor for wellness progress.

### Behavioral Gamification
A comprehensive incentive system designed to encourage consistent journaling and mindfulness practices. This includes reward loops tied to emotional regulation milestones and longitudinal engagement metrics.

## Technical Architecture

The platform is designed as a distributed system comprising a cross-platform mobile/web application and a scalable microservice for heavy computational tasks.

*   **Frontend Interface**: Built with Flutter for multi-platform delivery, focusing on a premium, glassmorphic design system that prioritizes aesthetic calm and user engagement.
*   **Intelligence Layer**: A FastAPI-powered Python service that hosts scikit-learn and Transformer-based models for real-time inference.
*   **Data Orchestration**: Firebase Cloud Firestore serves as the primary persistence layer, facilitating real-time synchronization across devices.

## Technology Stack

### Frontend (Flutter/Dart)
*   **UI Framework**: Flutter SDK
*   **State Management**: Bloc/Provider patterns (depending on specific module requirements)
*   **Design System**: Custom implementation featuring Glassmorphism, Google Fonts (Doto, Poppins), and hardware-accelerated animations.
*   **Backend Integration**: Firebase Core, Firestore, and Authentication.

### Machine Learning Service (Python)
*   **API Framework**: FastAPI, Uvicorn.
*   **Data Science Stack**: Pandas, NumPy, scikit-learn.
*   **Deep Learning**: PyTorch, HuggingFace Transformers.
*   **Model Management**: Joblib for serialized model persistence.

### Infrastructure
*   **Database**: Google Cloud Firestore.
*   **Hosting**: Render (ML Service), Firebase Hosting (Web).

## Project Structure

```text
AetherMind/
├── aether/               
│   ├── lib/              
│   ├── assets/           
│   └── web/              
├── ml_service/           
│   ├── app/              
│   ├── model/            
│   └── train/            
└── docker/               
```

## License
Refer to the `LICENSE` file for full terms and conditions.
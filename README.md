# UTP Smart Campus Assistant

A comprehensive mobile application designed to assist students at Universiti Teknologi PETRONAS (UTP) with their daily campus life. Powered by Google's Gemini AI, this app serves as a smart companion for academic and campus-related activities.

## Features

*   **🤖 AI Chat Assistant**: Interactive chat interface powered by Gemini AI to answer questions about campus life, academic matters, and more.
*   **🗺️ Campus Map**: Navigate the campus easily with a built-in map feature.
*   **📊 GPA Calculator**: Track your academic performance with a dedicated GPA and CGPA calculator.
*   **📅 Dashboard**: A central hub to access all key features and view important updates.
*   **📝 Chat History**: Save and review your past conversations with the AI assistant.
*   **🎨 Theme Support**: Fully customizable interface with Light and Dark mode support.
*   **👤 User Profile**: Manage your personal information and app settings.

## Tech Stack

*   **Framework**: [Flutter](https://flutter.dev/)
*   **Language**: [Dart](https://dart.dev/)
*   **AI Model**: [Google Gemini](https://ai.google.dev/) (via `google_generative_ai`)
*   **State Management**: [Provider](https://pub.dev/packages/provider)
*   **Local Storage**: [Hive](https://pub.dev/packages/hive)
*   **Maps**: [Flutter Map](https://pub.dev/packages/flutter_map)

## Getting Started

### Prerequisites

*   Flutter SDK (Version 3.9.2 or higher)
*   Dart SDK
*   An IDE (VS Code or Android Studio)
*   A Google Gemini API Key

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/Nameless456/UTP-Smart-Campus-Assitant.git
    cd UTP-Smart-Campus-Assitant
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Configure API Key**
    *   Open `lib/api/api_service.dart`.
    *   Replace the placeholder with your actual Gemini API key:
        ```dart
        static const apikey = 'YOUR_API_KEY_HERE';
        ```

4.  **Run the app**
    ```bash
    flutter run
    ```

## Project Structure

```
lib/
├── api/            # API services and configurations
├── models/         # Data models
├── providers/      # State management providers
├── screens/        # UI screens (Dashboard, Chat, Map, etc.)
├── widgets/        # Reusable UI widgets
└── main.dart       # Application entry point
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

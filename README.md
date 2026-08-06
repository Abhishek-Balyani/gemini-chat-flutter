# 🤖 AI Chatbot - Intelligent Flutter Assistant

An intelligent, multi-featured AI Chatbot mobile application built with **Flutter**, **Google Gemini API**, and **Firebase**. Features real-time conversational AI, document processing (PDF parsing), voice input & speech synthesis, flexible authentication modes, and customizable theme settings.

---

## ✨ Features

- **🧠 Powered by Gemini AI**: Seamless integration with Google's Gemini models (`gemini-1.5-flash` & `gemini-1.5-pro`).
- **🔐 Multi-Method Authentication**:
  - Email & Password Sign-In / Sign-Up
  - Google Sign-In
  - Anonymous Guest Sign-In
- **🎙️ Voice Assistant Capabilities**:
  - **Speech-to-Text (STT)**: Dictate prompts using speech recognition.
  - **Text-to-Speech (TTS)**: Listen to AI responses read aloud.
- **📄 Document & PDF Attachment Parsing**: Attach PDF documents or plain text files to chat prompts for contextual analysis.
- **📝 Rich Text & Code Highlighting**: Full Markdown rendering with syntax-highlighted code blocks and one-tap code copying.
- **💾 Local Chat History**: Persistent local storage powered by `GetStorage` to save conversations across app sessions.
- **🎨 Dynamic Themes & Customization**:
  - Dark and Light mode toggle with smooth theme transitions.
  - Custom API key entry option (override default key).
  - Dynamic font scale adjustment.

---

## 🛠️ Architecture & Tech Stack

This project follows **Clean Architecture** combined with the **GetX Pattern** for state management, dependency injection, and reactive UI updates.

- **Framework**: [Flutter SDK](https://flutter.dev) (Dart 3+)
- **State Management & Routing**: [GetX](https://pub.dev/packages/get)
- **Networking**: [Dio](https://pub.dev/packages/dio) HTTP client
- **Authentication**: [Firebase Auth](https://firebase.google.com/docs/auth) & [Google Sign-In](https://pub.dev/packages/google_sign_in)
- **Local Storage**: [GetStorage](https://pub.dev/packages/get_storage)
- **Environment Config**: [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)
- **PDF & File Parsing**: [Syncfusion Flutter PDF](https://pub.dev/packages/syncfusion_flutter_pdf) & [file_picker](https://pub.dev/packages/file_picker)
- **Voice & Speech**: [speech_to_text](https://pub.dev/packages/speech_to_text) & [flutter_tts](https://pub.dev/packages/flutter_tts)

```
lib/
├── core/                  # App constants, themes, network client, services
│   ├── constants/         # App strings, colors, API endpoints
│   ├── network/           # Dio client & API exception handler
│   ├── services/          # Gemini API, Audio, Storage, Theme services
│   └── theme/             # Light & Dark app themes, typography
├── data/                  # Models, datasources, and repositories
│   ├── datasources/       # Local chat data source
│   ├── models/            # Chat message, conversation, attachment models
│   └── repositories/      # Chat repository
├── modules/               # Feature-based modular structure
│   ├── auth/              # Views, controllers, bindings, services
│   ├── chat/              # Chat view, controllers, bindings
│   ├── home/              # Navigation drawer & home view
│   ├── profile/           # User profile & privacy settings
│   ├── settings/          # App settings & Gemini model selector
│   └── splash/            # Splash screen & auth routing check
└── widgets/               # Reusable UI widgets (chat bubbles, markdown, voice overlay)
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.10.8`)
- Dart SDK (`>=3.10.8`)
- Android Studio / Xcode for device simulation
- A Google Gemini API Key from [Google AI Studio](https://aistudio.google.com/)

---

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/YOUR_GITHUB_USERNAME/ai_chatbot.git
   cd ai_chatbot
   ```

2. **Configure Environment Variables**:
   Create a `.env` file in the root directory by copying `.env.example`:
   ```bash
   cp .env.example .env
   ```
   Open `.env` and add your Gemini API Key:
   ```env
   GEMINI_API_KEY=your_actual_gemini_api_key_here
   ```

3. **Firebase Configuration (Optional for Full Auth)**:
   - For **Android**: Place your `google-services.json` inside `android/app/`.
   - For **iOS**: Place your `GoogleService-Info.plist` inside `ios/Runner/`.

4. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

5. **Run the App**:
   ```bash
   flutter run
   ```

---

## 🧪 Testing

Run unit tests using Flutter Test:

```bash
flutter test
```

Perform static analysis check:

```bash
flutter analyze
```

---

## 📄 License

This project is open-source under the [MIT License](LICENSE).

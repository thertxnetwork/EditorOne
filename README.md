# EditorOne - Lightweight Code Editor for Android

<p align="center">
  <img src="assets/icons/app_icon.png" alt="EditorOne Logo" width="128" height="128">
</p>

A fast, lightweight, and feature-rich code editor for Android built with Flutter and Material Design 3.

## ✨ Features

### Core Editor Features
- **Syntax Highlighting** - Support for 40+ programming languages including Dart, JavaScript, TypeScript, Python, Java, Kotlin, Go, Rust, C/C++, and many more
- **Line Numbers** - Optional line number display
- **Word Wrap** - Toggle word wrapping for long lines
- **Multiple Tabs** - Work with multiple files simultaneously
- **Undo/Redo** - Full undo/redo support

### File Management
- **File Explorer** - Navigate project directories with tree view
- **Open Folder** - Open entire project directories
- **Create/Delete/Rename** - Full file system operations
- **Recent Files** - Quick access to recently opened files
- **File Type Detection** - Automatic language detection based on file extension

### Search & Navigation
- **Search in Files** - Find text across all project files
- **Search by Filename** - Quickly locate files by name
- **Case Sensitive Search** - Toggle case sensitivity
- **Regex Support** - Use regular expressions for advanced search

### Customization
- **Editor Fonts** - Choose from JetBrains Mono, Fira Code, Source Code Pro, or system monospace
- **Font Size** - Adjustable font size (10-32px)
- **Tab Size** - Configure tab width (2-8 spaces)
- **Theme Support** - Light, Dark, and System themes
- **Editor Themes** - Multiple syntax highlighting themes (Monokai, Dracula, VS Code, and more)

### Modern UI/UX
- **Material Design 3** - Clean, modern Android-native experience
- **Dynamic Colors** - Adapts to your system accent color
- **Responsive Layout** - Optimized for phones and tablets
- **Gesture Support** - Swipe to open file explorer

## 📱 Screenshots

*Coming soon*

## 🛠️ Building the APK

### Prerequisites

1. **Flutter SDK** (3.5.0 or higher)
   ```bash
   # Check Flutter version
   flutter --version
   
   # If needed, upgrade Flutter
   flutter upgrade
   ```

2. **Android SDK** (API 21+)
   - Android Studio with Android SDK
   - Or standalone Android command line tools

3. **Java JDK 17**
   ```bash
   java -version
   ```

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/thertxnetwork/EditorOne.git
   cd EditorOne
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Download fonts** (optional - for custom fonts)
   
   Download the following fonts and place them in `assets/fonts/`:
   - [JetBrains Mono](https://www.jetbrains.com/lp/mono/)
   - [Fira Code](https://github.com/tonsky/FiraCode)
   - [Source Code Pro](https://github.com/adobe-fonts/source-code-pro)

### Building

#### Debug APK (for testing)
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

#### Release APK (optimized)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

#### Split APKs by Architecture (smallest size)
```bash
flutter build apk --release --split-per-abi
```
Outputs:
- `app-armeabi-v7a-release.apk` - For older 32-bit ARM devices
- `app-arm64-v8a-release.apk` - For modern 64-bit ARM devices
- `app-x86_64-release.apk` - For x86 emulators

#### App Bundle (for Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### APK Size Optimization

The project is already configured for optimal APK size:

1. **Code Shrinking** (R8/ProGuard)
   - Enabled in release builds
   - Removes unused code

2. **Resource Shrinking**
   - Removes unused resources
   - Enabled in release builds

3. **ABI Splits**
   - Builds separate APKs for each CPU architecture
   - Reduces download size by ~40%

4. **To further reduce size:**
   ```bash
   # Analyze APK size
   flutter build apk --analyze-size --target-platform android-arm64
   
   # Build with specific optimizations
   flutter build apk --release --shrink --obfuscate --split-debug-info=build/debug-info
   ```

### Signing for Release

1. **Generate a keystore**
   ```bash
   keytool -genkey -v -keystore editorone-release.keystore -alias editorone -keyalg RSA -keysize 2048 -validity 10000
   ```

2. **Create `android/key.properties`**
   ```properties
   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=editorone
   storeFile=<path-to-keystore>/editorone-release.keystore
   ```

3. **Update `android/app/build.gradle.kts`** to use the keystore for release builds

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── editor_file.dart      # File model
│   ├── file_item.dart        # File explorer item
│   ├── editor_settings.dart  # Settings model
│   └── search_result.dart    # Search result model
├── providers/                # State management
│   ├── editor_provider.dart  # Editor state
│   ├── file_explorer_provider.dart
│   ├── settings_provider.dart
│   └── search_provider.dart
├── screens/                  # UI screens
│   ├── editor_screen.dart    # Main editor
│   ├── settings_screen.dart  # Settings
│   └── search_screen.dart    # Search
├── services/                 # Business logic
│   ├── file_service.dart     # File operations
│   ├── settings_service.dart # Persistence
│   └── search_service.dart   # Search engine
├── themes/                   # App theming
│   └── app_theme.dart        # Material 3 theme
├── utils/                    # Utilities
│   ├── language_detector.dart
│   └── helpers.dart
└── widgets/                  # Reusable widgets
    ├── file_tree_view.dart
    ├── editor_tab_bar.dart
    └── search_results_view.dart
```

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `flutter_code_editor` | Code editor widget with syntax highlighting |
| `flutter_highlight` | Syntax highlighting themes |
| `highlight` | Language definitions |
| `file_picker` | File/folder selection |
| `path_provider` | File system paths |
| `permission_handler` | Android permissions |
| `shared_preferences` | Local storage |
| `google_fonts` | Custom fonts |

## 🔧 Configuration

### Supported Languages

The editor supports syntax highlighting for:

| Category | Languages |
|----------|-----------|
| **Web** | HTML, CSS, SCSS, JavaScript, TypeScript, JSON |
| **Mobile** | Dart, Kotlin, Swift, Java |
| **Backend** | Python, Ruby, PHP, Go, Rust, C# |
| **Systems** | C, C++, Assembly |
| **Data** | SQL, GraphQL, YAML, XML, TOML |
| **Shell** | Bash, PowerShell, Batch |
| **Docs** | Markdown, LaTeX |

### Editor Settings

All settings are persisted locally and include:

- Font family and size
- Tab size and spaces/tabs preference
- Word wrap toggle
- Line numbers toggle
- Auto-save configuration
- Theme preferences
- Recent files list

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - UI framework
- [Material Design 3](https://m3.material.io/) - Design system
- [JetBrains Mono](https://www.jetbrains.com/lp/mono/) - Editor font
- [re_editor](https://pub.dev/packages/re_editor) - Code editor widget


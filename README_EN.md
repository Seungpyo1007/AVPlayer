# AVPlayer

[English](README_EN.md) | [한국어](README.md)

An iOS movie information app utilizing the TMDB (The Movie Database) API. It provides features for browsing popular movies, searching, viewing detailed information, and playing trailers.

## Features

### 🔒 Security
- **Passcode Lock**: Protect the app with a 6-digit numeric passcode
- **Face ID Support**: Quick unlock through biometric authentication
- **Random Keypad**: Enhanced security with randomly positioned number keypad on each launch
- **Auto Face ID**: Automatic Face ID authentication on app launch when enabled

### 🎬 Movie Information
- **Popular Movies List**: Real-time popular movie browsing via TMDB API
- **Movie Search**: Real-time search functionality (0.5s debouncing applied)
- **Infinite Scroll**: Smooth scrolling experience with pagination
- **Movie Details**: 
  - Poster image
  - Rating information
  - Overview (expand/collapse feature)
  - Trailer playback

### 🎥 Trailer Playback
- **In-App Playback**: YouTube trailer playback within the app using WKWebView
- **Safari Integration**: Option to open in Safari
- **Inline Playback**: Inline video playback support without full-screen transition

### 🖼️ Image Optimization
- **Image Caching**: Memory caching using NSCache
- **Duplicate Request Prevention**: Prevents duplicate downloads for the same image
- **Auto Cancellation**: Automatically cancels ongoing image downloads on cell reuse

## Screenshots

<div align="center">
  
### Lock Screen
<img width="296" height="640" alt="Image" src="https://github.com/user-attachments/assets/d44896dc-df46-4641-93b2-b005eb569490" />
<img width="296" height="640" alt="Image" src="https://github.com/user-attachments/assets/e0bf1e4f-1f1c-49c1-a535-9c0ffbeeab45" />

### Movie List
<img width="296" height="640" alt="Image" src="https://github.com/user-attachments/assets/6c3ddd3d-25ad-409b-9223-b12aa94f5e3b" />

### Movie Search
<img width="296" height="640" alt="Image" src="https://github.com/user-attachments/assets/8f7d6f73-e79c-4147-b29f-beeb7df608d6" />
<img width="296" height="640" alt="Image" src="https://github.com/user-attachments/assets/c3876c11-357f-40e8-b153-b124f5b9c5a0" />

### Movie Details
<img width="296" height="640" alt="Image" src="https://github.com/user-attachments/assets/88ee5677-e237-4cd2-9533-7316914c51ff" />
<img width="1320" height="2868" alt="Image" src="https://github.com/user-attachments/assets/085912f8-231f-482c-a3e3-3a8edfb5e9a8" />

### Trailer Playback
<img width="296" height="640" alt="Image" src="https://github.com/user-attachments/assets/4ae5579e-9f1b-49b6-96f6-541aa5d273dc" />
<img width="296" height="640" alt="Image" src="https://github.com/user-attachments/assets/9c48a2ba-f0ff-44a0-94c2-273e1a5b72c8" />

</div>

## Tech Stack

- **Language**: Swift
- **UI Framework**: 
  - UIKit (Main screens)
  - SwiftUI (Passcode lock screen)
- **Networking**: URLSession
- **Authentication**: LocalAuthentication (Face ID/Touch ID)
- **Media**: 
  - AVKit
  - WebKit (YouTube playback)
- **API**: [TMDB (The Movie Database) API](https://www.themoviedb.org/)

## Project Structure

```
AVPlayer/
├── AppDelegate.swift              # App lifecycle management
├── SceneDelegate.swift             # Scene setup and lock screen initialization
├── ViewController.swift            # Main movie list screen
├── MovieDetailViewController.swift # Movie detail screen
├── MovieCell.swift                 # Movie list cell
├── MovieModel.swift                # Movie data model
├── NetworkManager.swift            # TMDB API communication management
├── ImageLoader.swift               # Image download and caching
└── PasscodeLockViewController.swift # Passcode lock screen (SwiftUI)
```

## Architecture

- **MVC Pattern**: Model-View-Controller architecture applied
- **Singleton Pattern**: 
  - `ImageLoader.shared`: Image caching and loading management
  - `NetworkManager`: Network communication management

## Key Components

### NetworkManager
A class responsible for communication with the TMDB API.
- Popular movies list retrieval
- Movie search
- Trailer information retrieval
- Bearer Token authentication
- Error handling

### ImageLoader
A singleton class that manages image downloads and caching.
- Memory caching (NSCache)
- Duplicate download prevention
- Download cancellation functionality

### PasscodeLockView
A passcode lock screen implemented with SwiftUI.
- 6-digit numeric passcode input
- Face ID biometric authentication
- Random keypad layout
- Haptic feedback

## Requirements

- iOS 13.0 or higher
- Xcode 12.0 or higher
- Swift 5.0 or higher
- Internet connection (for TMDB API usage)

## Setup

1. **Clone the project**
   ```bash
   git clone [repository-url]
   cd AVPlayer
   ```

2. **Open project in Xcode**
   - Open the `AVPlayer.xcodeproj` file in Xcode.

3. **Configure TMDB API Key** (Optional)
   - You can change the `bearerToken` in `NetworkManager.swift` to your own TMDB API key.
   - A default Bearer Token is currently set.

4. **Build and Run**
   - Build and run on a simulator or physical device.

## Usage

1. **Launch App**: When you launch the app, a passcode lock screen is displayed.
2. **Unlock**: 
   - Enter 6-digit passcode (default: `100712`)
   - Or tap the Face ID button for biometric authentication
3. **Browse Movies**: 
   - Scroll through the popular movies list
   - Search for movie titles in the search bar
4. **View Details**: Tap on a movie poster to view detailed information
5. **Play Trailer**: Tap the "Play Trailer" button on the detail screen to watch the YouTube trailer

## Key Features

- ✅ Dark mode support
- ✅ Korean language support (TMDB API Korean responses)
- ✅ Memory-efficient image caching
- ✅ Smooth animations and transitions
- ✅ Network error handling
- ✅ Accessibility support

## License

This project was created for personal learning and portfolio purposes.

## References

- [TMDB API Documentation](https://developers.themoviedb.org/3)
- [TMDB Image API](https://developers.themoviedb.org/3/getting-started/images)


# Shelfmark

Shelfmark is an iOS app for building a personal reading system: track your library, organize reading lists, and save meaningful quotes from books.

## Features

- Personal library management
  - Add books manually or by ISBN lookup
  - Track reading status and progress
- Reading lists
  - Create, rename, and delete custom lists
  - Add and remove books from lists
- Quotes
  - Save, edit, and delete book quotes
  - Link quotes to specific books and optional page references
  - Browse quotes by book and author
- Profile and reading insights
  - Lightweight profile persistence
  - Reading stats and summary views

## Tech Stack

- SwiftUI
- SwiftData
- Clean Architecture style:
  - `Core/Domain` for entities and contracts
  - `Core/Data` for repositories, mappers, persistence, and use case implementations
  - `Features/*` for screen-level views and view models
  - `App/*` for dependency injection and app wiring

## Project Structure

```text
Shelfmark/
  App/
  Core/
    Data/
    Domain/
    DesignSystem/
    Utilities/
  Features/
    Library/
    Lists/
    Quotes/
    Profile/
ShelfmarKTests/
Shelfmark.xcodeproj/
```

## Getting Started

### Requirements

- Xcode 16+
- iOS 17+ simulator/device

### Setup

1. Clone this repository.
2. Copy `Shelfmark/Secrets.example.xcconfig` to `Shelfmark/Secrets.xcconfig`.
3. Fill required keys in `Secrets.xcconfig`.
4. Open `Shelfmark.xcodeproj` in Xcode.
5. Build and run the `Shelfmark` scheme.

## Testing

This repository currently uses unit tests in `ShelfmarKTests`.

Run tests from Xcode (`Product > Test`) or with:

```bash
xcodebuild test \
  -project "Shelfmark.xcodeproj" \
  -scheme "Shelfmark" \
  -destination "platform=iOS Simulator,name=iPhone 16"
```

## Notes

- Secrets and local machine metadata are excluded from version control via `.gitignore`.
- Shared project scheme is included to keep local and CI behavior consistent.

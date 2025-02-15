# Image Viewer Web App

A Flutter web application that allows users to view images from a URL in fullscreen mode using the HTML `<img>` tag instead of Flutter's built-in `Image` widget.

## Features
- Load images from a URL
- Display images using an HTML `<img>` element
- Toggle fullscreen mode via JavaScript interop
- Double-tap gesture for fullscreen activation
- Expandable Floating Action Button (FAB) for fullscreen control
- Responsive UI with Material 3 design

## Technologies Used
- **Flutter Web** for UI
- **JavaScript Interop** for fullscreen functionality
- **HTMLImageElement** for rendering images
- **flutter_expandable_fab** package for expandable FAB
- **web/web.dart** for DOM interaction

## Installation
1. Clone the repository:
   ```sh
   git clone <repo-link>
   cd <project-folder>
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Run the application in the browser:
   ```sh
   flutter run -d chrome
   ```

## Usage
1. Enter the image URL in the text field.
2. Click the arrow button to load the image.
3. Double-tap the image to toggle fullscreen mode.
4. Use the floating action button to enter/exit fullscreen manually.

/// A Flutter web application that allows viewing and controlling images in fullscreen mode.
///
/// This application provides a simple interface for loading images from URLs and
/// viewing them using the HTML < image > tage and not the FLutter's built in [Image]
/// widget in both windowed and fullscreen modes. It uses web-specific features
/// through JavaScript interop for fullscreen functionality.
library;

import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:js/js.dart' as js;
import 'package:js/js_util.dart' as js_util;
import 'package:web/web.dart' hide Text;

/// Provides access to the browser's document object for fullscreen control.
/// This external reference is required for JavaScript interop.
@js.JS('document')
external dynamic get _document;

/// The application entry point.
///
/// Initializes the platform view registry with an HTML image element factory
/// and launches the application.
void main() {
  // Register a custom view factory for the image viewer
  // This creates an HTML image element that will be used to display images
  ui.platformViewRegistry.registerViewFactory(
    'image-viewer',
    (int viewId) => HTMLImageElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'contain'
      ..id = 'image-viewer',
  );

  runApp(const MyApp());
}

/// The root widget of the application.
///
/// Configures the application theme and sets up the initial route
/// to the [HomePage].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

/// The main page widget that displays the image viewer interface.
///
/// This widget provides:
/// * An image display area that supports fullscreen toggle
/// * A URL input field for loading new images
/// * Floating action buttons for fullscreen control
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// The state management class for [HomePage].
///
/// Manages:
/// * The current image URL
/// * Text input controller for the URL field
/// * Fullscreen toggle functionality
/// * Image source updates
class _HomePageState extends State<HomePage> {
  /// Controller for the URL input text field
  final TextEditingController _urlController = TextEditingController();

  /// Currently displayed image URL
  String? _currentImageUrl;

  /// Key for controlling the expandable FAB state
  final _fabKey = GlobalKey<ExpandableFabState>();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  /// Toggles the browser's fullscreen mode using JavaScript interop.
  ///
  /// Attempts to enter fullscreen mode if not currently fullscreen,
  /// or exit fullscreen mode if currently fullscreen.
  /// Catches and logs any errors that occur during the process.
  void _toggleFullscreen() {
    try {
      final document = js_util.getProperty(_document, 'documentElement');
      final isFullscreen = js_util.getProperty(_document, 'fullscreenElement') != null;

      if (isFullscreen) {
        js_util.callMethod(_document, 'exitFullscreen', []);
      } else {
        js_util.callMethod(document, 'requestFullscreen', []);
      }
    } catch (e) {
      debugPrint('Fullscreen error: $e');
    }
  }

  /// Updates the source URL of the image element.
  ///
  /// [url] The new URL to set as the image source.
  ///
  /// Uses JavaScript interop to find the image element by ID and update its src attribute.
  void _updateImageSource(String url) {
    final imageElement = js_util.callMethod(
      _document,
      'getElementById',
      [
        'image-viewer'
      ],
    );

    if (imageElement != null) {
      js_util.setProperty(imageElement, 'src', url);
    }
    setState(() {});
  }

  /// Builds the image display container widget.
  ///
  /// Returns a container that either displays:
  /// * A placeholder message when no image is loaded
  /// * The actual image viewer when an image URL is provided
  Widget _buildImageDisplay() {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: _currentImageUrl == null
          ? const Center(child: Text('No image loaded'))
          : HtmlElementView(
              viewType: 'image-viewer',
              onPlatformViewCreated: (int id) {
                // Set initial image source after view is created
                // Delayed to ensure the view is properly initialized
                Future.delayed(const Duration(milliseconds: 100), () {
                  _updateImageSource(_currentImageUrl!);
                });
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Viewer'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image display area with gesture detection for double-tap fullscreen
            Expanded(
              child: GestureDetector(
                onDoubleTap: _toggleFullscreen,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _buildImageDisplay(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // URL input field and load button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      hintText: 'Image URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_urlController.text.isNotEmpty) {
                      setState(() {
                        _currentImageUrl = _urlController.text;
                      });
                      _updateImageSource(_urlController.text);
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Icon(Icons.arrow_forward),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
      // Expandable FAB with fullscreen controls
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _fabKey,
        type: ExpandableFabType.up,
        childrenAnimation: ExpandableFabAnimation.none,
        distance: 70,
        overlayStyle: ExpandableFabOverlayStyle(
          color: Colors.black.withOpacity(0.5),
        ),
        children: [
          Row(
            children: [
              Text('Enter fullscreen'),
              SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {
                  _toggleFullscreen();
                  _fabKey.currentState?.toggle();
                },
                child: Icon(Icons.fullscreen),
              ),
            ],
          ),
          Row(
            children: [
              Text('Exit fullscreen'),
              SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {
                  _toggleFullscreen();
                  _fabKey.currentState?.toggle();
                },
                child: Icon(Icons.fullscreen_exit_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

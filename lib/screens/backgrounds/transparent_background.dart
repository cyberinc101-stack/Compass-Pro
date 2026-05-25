import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class TransparentBackground extends StatefulWidget {
  final Widget child;
  final bool isPreview;

  const TransparentBackground({
    Key? key,
    required this.child,
    this.isPreview = false,
  }) : super(key: key);

  @override
  State<TransparentBackground> createState() => _TransparentBackgroundState();
}

class _TransparentBackgroundState extends State<TransparentBackground> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    // Only initialize camera if NOT in preview mode
    if (!widget.isPreview) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        return;
      }

      // Use the back camera (index 0 is usually back camera)
      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      // Initialize camera controller
      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // If in preview mode, just show light grey card
    if (widget.isPreview) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
        ),
        child: widget.child,
      );
    }

    // Full camera implementation for actual compass screen
    return Stack(
      children: [
        // Camera feed background
        if (_isCameraInitialized && _cameraController != null)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _cameraController!.value.previewSize!.height,
                height: _cameraController!.value.previewSize!.width,
                child: CameraPreview(_cameraController!),
              ),
            ),
          )
        else
          // Fallback gradient if camera fails
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey.shade50,
                  Colors.grey.shade100,
                ],
              ),
            ),
          ),
        // Overlay child content on top of camera
        widget.child,
      ],
    );
  }
}
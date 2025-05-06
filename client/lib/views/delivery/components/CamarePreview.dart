import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';

class CameraPreviewWidget extends StatefulWidget {
  final CameraController? cameraController;
  final bool isCameraInitialized;
  const CameraPreviewWidget({super.key, required this.cameraController, required this.isCameraInitialized});

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.cameraController == null || !widget.isCameraInitialized) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSecondary,
          borderRadius: BorderRadius.circular(Tokens.radius8),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(Tokens.radius8),
      child: AspectRatio(
        aspectRatio: widget.cameraController!.value.aspectRatio,
        child: CameraPreview(widget.cameraController!),
      ),
    );
  }
}
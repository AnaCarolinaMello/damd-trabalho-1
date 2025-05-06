import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/views/delivery/components/CamarePreview.dart';

class PhotoPreview extends StatelessWidget {
  final XFile? photoFile;
  final CameraController? cameraController;
  final bool isCameraInitialized;
  final VoidCallback onReset;

  const PhotoPreview({
    super.key,
    required this.photoFile,
    required this.cameraController,
    required this.isCameraInitialized,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSecondary,
        borderRadius: BorderRadius.circular(Tokens.radius8),
        image:
            photoFile != null
                ? DecorationImage(
                  image: FileImage(File(photoFile!.path)),
                  fit: BoxFit.cover,
                )
                : null,
      ),
      child:
          photoFile == null
              ? CameraPreviewWidget(
                cameraController: cameraController,
                isCameraInitialized: isCameraInitialized,
              )
              : Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Positioned(
                    bottom: Tokens.spacing16,
                    right: Tokens.spacing16,
                    child: FloatingActionButton(
                      mini: true,
                      onPressed: onReset,
                      child: const Icon(Icons.refresh),
                    ),
                  ),
                ],
              ),
    );
  }
}

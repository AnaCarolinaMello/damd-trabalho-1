import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/components/IconButton.dart';
import 'package:damd_trabalho_1/views/order/components/Shop.dart';
import 'package:damd_trabalho_1/views/delivery/components/PhotoPreview.dart';
import 'package:damd_trabalho_1/views/main/MainScreen.dart';
import 'package:damd_trabalho_1/controllers/order.dart';

class FinishDelivery extends StatefulWidget {
  final Order order;

  const FinishDelivery({super.key, required this.order});

  @override
  State<FinishDelivery> createState() => _FinishDeliveryState();
}

class _FinishDeliveryState extends State<FinishDelivery> {
  late Future<List<CameraDescription>> _camerasFuture;
  CameraController? _cameraController;
  XFile? _photoFile;
  bool _isCameraInitialized = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _camerasFuture = availableCameras();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _camerasFuture = availableCameras();
      final cameras = await _camerasFuture;

      if (cameras.isEmpty) {
        debugPrint('No cameras available');
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
      );

      try {
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } catch (e) {
        debugPrint('Error initializing camera controller: $e');
      }
    } catch (e) {
      debugPrint('Error accessing cameras: $e');
    }
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _photoFile = photo;
      });
    } catch (e) {
      debugPrint('Error taking photo: $e');
    }
  }

  Future<void> _submitDelivery() async {
    if (_photoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('É necessário tirar uma foto para confirmar a entrega'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulating API call
    await OrderController.deliverOrder(widget.order.id!, _photoFile!);

    if (!mounted) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao entregar o pedido')),
      );
      return;
    }

    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Entrega concluída'),
        content: Text('O pedido #${widget.order.id} foi entregue com sucesso.'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
              );
            },
          ),
        ],
      );
    },
  );

    // Return to the previous screen with success message
    // Navigator.push(
      // context,
     //  MaterialPageRoute(builder: (context) => const MainScreen()),
    // );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Entrega')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Entrega de pedido', style: theme.textTheme.titleLarge),
              const SizedBox(height: Tokens.spacing8),
              Shop(
                order: widget.order,
                isActive: true,
                padding: const EdgeInsets.symmetric(vertical: Tokens.spacing16),
              ),
              const SizedBox(height: Tokens.spacing16),

              Text(
                'Tire uma foto da entrega',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: Tokens.spacing8),
              Text(
                'A foto é obrigatória para confirmar a entrega do pedido.',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: Tokens.fontSize14,
                ),
              ),
              const SizedBox(height: Tokens.spacing16),

              PhotoPreview(
                photoFile: _photoFile,
                cameraController: _cameraController,
                isCameraInitialized: _isCameraInitialized,
                onReset: () {
                  setState(() {
                    _photoFile = null;
                  });
                },
              ),
              const SizedBox(height: Tokens.spacing16),

              if (_photoFile == null) ...[
                SizedBox(
                  width: double.infinity,
                  child: CustomIconButton(
                    onPressed: _takePhoto,
                    icon: Icons.camera_alt,
                    label: 'Tirar Foto',
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: CustomIconButton(
                    icon: Icons.check_circle_outline,
                    label: 'Confirmar Entrega',
                    onPressed: _isSubmitting ? () {} : () => _submitDelivery(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

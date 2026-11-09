import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class AvatarCameraScreen extends StatefulWidget {
  const AvatarCameraScreen({super.key});

  @override
  State<AvatarCameraScreen> createState() => _AvatarCameraScreenState();
}

class _AvatarCameraScreenState extends State<AvatarCameraScreen>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  String? _error;
  bool _capturing = false;
  bool _opening = false;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _openCamera();
  }

  Future<void> _openCamera([CameraDescription? preferred]) async {
    if (_opening || !_active) return;
    _opening = true;
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) throw StateError('Fotoaparát není dostupný.');
      final camera =
          preferred ??
          _cameras.firstWhere(
            (item) => item.lensDirection == CameraLensDirection.front,
            orElse: () => _cameras.first,
          );
      final old = _controller;
      _controller = null;
      await old?.dispose();
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted || !_active) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _error = null;
      });
    } catch (error) {
      debugPrint('Avatar camera initialization failed: $error');
      if (mounted && _active) {
        setState(() {
          if (error is MissingPluginException) {
            _error = 'Kamera bude dostupná po úplném restartu aplikace.';
          } else if (error is CameraException &&
              error.code.toLowerCase().contains('denied')) {
            _error = 'Povol přístup ke kameře v nastavení telefonu.';
          } else {
            _error = 'Fotoaparát se nepodařilo otevřít ($error).';
          }
        });
      }
    } finally {
      _opening = false;
    }
  }

  Future<void> _takePhoto() async {
    final controller = _controller;
    if (controller == null || _capturing) return;
    setState(() => _capturing = true);
    try {
      final file = await controller.takePicture();
      if (mounted) Navigator.pop(context, file);
    } catch (_) {
      if (mounted) setState(() => _error = 'Fotku se nepodařilo pořídit.');
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file != null && mounted) Navigator.pop(context, file);
    } catch (_) {
      if (mounted) setState(() => _error = 'Galerii se nepodařilo otevřít.');
    }
  }

  Future<void> _switchCamera() async {
    final current = _controller?.description;
    if (current == null || _cameras.length < 2) return;
    final other = _cameras.firstWhere(
      (camera) => camera.lensDirection != current.lensDirection,
      orElse: () => current,
    );
    if (other != current) await _openCamera(other);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _active = false;
      _controller?.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed && mounted) {
      _active = true;
      _openCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Profilová fotka')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: controller != null && controller.value.isInitialized
                    ? CameraPreview(controller)
                    : _error != null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: _openCamera,
                            child: const Text('Zkusit znovu'),
                          ),
                        ],
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galerie'),
                  ),
                  IconButton.filled(
                    onPressed: controller == null || _capturing
                        ? null
                        : _takePhoto,
                    iconSize: 38,
                    icon: const Icon(Icons.camera_alt),
                    tooltip: 'Vyfotit',
                  ),
                  IconButton(
                    onPressed: _cameras.length < 2 ? null : _switchCamera,
                    icon: const Icon(Icons.cameraswitch_outlined),
                    tooltip: 'Přepnout kameru',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/theme/app_colors.dart';
import 'evidence_image_preview.dart';

class EvidenceCameraField extends StatefulWidget {
  const EvidenceCameraField({
    required this.filePath,
    required this.onChanged,
    super.key,
    this.enabled = true,
  });

  final String? filePath;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  State<EvidenceCameraField> createState() {
    return _EvidenceCameraFieldState();
  }
}

class _EvidenceCameraFieldState extends State<EvidenceCameraField> {
  final ImagePicker _picker = ImagePicker();

  bool _capturing = false;

  Future<void> _capture() async {
    if (!widget.enabled || _capturing) {
      return;
    }

    setState(() {
      _capturing = true;
    });

    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (photo != null) {
        widget.onChanged(photo.path);
      }
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.code == 'camera_access_denied'
                ? 'Debes permitir el acceso a la cámara.'
                : 'No fue posible abrir la cámara.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _capturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.filePath;

    if (path == null || path.isEmpty) {
      return InkWell(
        onTap: widget.enabled ? _capture : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_capturing)
                const CircularProgressIndicator()
              else
                const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.secondary,
                  size: 30,
                ),
              const SizedBox(height: 8),
              Text(
                _capturing
                    ? 'Abriendo cámara...'
                    : 'Tomar fotografía de evidencia',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EvidenceImagePreview(path: path),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.enabled ? _capture : null,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Cambiar foto'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Quitar evidencia',
              onPressed: widget.enabled
                  ? () {
                      widget.onChanged(null);
                    }
                  : null,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

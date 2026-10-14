import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../network/api_config.dart';

class EvidenceImagePreview extends StatelessWidget {
  const EvidenceImagePreview({
    required this.path,
    super.key,
    this.height = 190,
    this.allowFullscreen = true,
  });

  final String path;
  final double height;
  final bool allowFullscreen;

  bool get _isRemote {
    return path.startsWith('http://') ||
        path.startsWith('https://') ||
        path.startsWith('/uploads/');
  }

  Widget _image({BoxFit fit = BoxFit.cover}) {
    if (_isRemote) {
      return Image.network(
        ApiConfig.resolveFileUrl(path),
        fit: fit,
        errorBuilder: (_, _, _) => _error(),
      );
    }

    return Image.file(
      File(path),
      fit: fit,
      errorBuilder: (_, _, _) => _error(),
    );
  }

  Widget _error() {
    return Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: AppColors.textSecondary,
            size: 36,
          ),
          SizedBox(height: 8),
          Text(
            'No fue posible cargar la evidencia.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _openFullscreen(BuildContext context) async {
    if (!allowFullscreen) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 5,
                    child: _image(fit: BoxFit.contain),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filled(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: allowFullscreen ? () => _openFullscreen(context) : null,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: _image(),
        ),
      ),
    );
  }
}

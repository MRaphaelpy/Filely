import 'dart:io';
import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  final String imageUrl;
  final Widget? errorWidget;

  const ImageWidget({super.key, required this.imageUrl, this.errorWidget});

  @override
  Widget build(BuildContext context) {
    final file = File(imageUrl);

    return Hero(
      tag: imageUrl,
      child: Image.file(
        file,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Não foi possível carregar a imagem',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
        },
      ),
    );
  }
}

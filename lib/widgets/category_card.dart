import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final Color background;
  final ImageProvider image;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.background,
    required this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 56),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Image(image: image),
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 12,
              right: 16,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

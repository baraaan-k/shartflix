import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class TypographyPreview extends StatelessWidget {
  const TypographyPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Typography Preview'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('H1 48', style: AppTypography.h1),
            const SizedBox(height: AppSpacing.sm),
            Text('H2 40', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.sm),
            Text('H3 32', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.sm),
            Text('H4 24', style: AppTypography.h4),
            const SizedBox(height: AppSpacing.sm),
            Text('H5 20', style: AppTypography.h5),
            const SizedBox(height: AppSpacing.sm),
            Text('H6 18', style: AppTypography.h6),
            const SizedBox(height: AppSpacing.lg),
            _BodyRow(
              label: 'Body XL 18',
              size: AppTypography.bodyXL,
            ),
            _BodyRow(
              label: 'Body L 16',
              size: AppTypography.bodyL,
            ),
            _BodyRow(
              label: 'Body N 14',
              size: AppTypography.bodyN,
            ),
            _BodyRow(
              label: 'Body S 12',
              size: AppTypography.bodyS,
            ),
            _BodyRow(
              label: 'Body XS 10',
              size: AppTypography.bodyXS,
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyRow extends StatelessWidget {
  const _BodyRow({
    required this.label,
    required this.size,
  });

  final String label;
  final TextStyle Function(FontWeight weight) size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.h6),
          const SizedBox(height: AppSpacing.sm),
          Text('Regular 400', style: size(FontWeight.w400)),
          const SizedBox(height: AppSpacing.xs),
          Text('Medium 500', style: size(FontWeight.w500)),
          const SizedBox(height: AppSpacing.xs),
          Text('Semibold 600', style: size(FontWeight.w600)),
          const SizedBox(height: AppSpacing.xs),
          Text('Bold 700', style: size(FontWeight.w700)),
        ],
      ),
    );
  }
}

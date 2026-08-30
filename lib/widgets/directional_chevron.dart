import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class DirectionalChevron extends StatelessWidget {
  final double size;
  final Color color;

  const DirectionalChevron({
    super.key,
    this.size = 16,
    this.color = AppColors.muted,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Icon(
      isRtl ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
      size: size,
      color: color,
    );
  }
}

class DirectionalBackIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const DirectionalBackIcon({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Icon(
      isRtl ? Icons.arrow_forward : Icons.arrow_back,
      size: size,
      color: color,
    );
  }
}

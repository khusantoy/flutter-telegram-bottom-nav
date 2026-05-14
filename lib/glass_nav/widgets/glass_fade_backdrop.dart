import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/glass_nav_style.dart';

/// Bottom-anchored full-width blur strip with a vertical top fade — Flutter
/// port of Telegram's `BlurredBackgroundWithFadeDrawable`.
///
/// Total height = `style.outerHeight + bottomInset` so the blur extends
/// behind the system navigation bar.
class GlassFadeBackdrop extends StatelessWidget {
  const GlassFadeBackdrop({super.key, required this.style});

  final GlassNavStyle style;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final stripHeight = style.outerHeight + bottomInset;
    if (style.fadeHeight <= 0) {
      return SizedBox(
        height: stripHeight,
        child: _OpaqueBlur(style: style),
      );
    }
    final fadeStop = (style.fadeHeight / stripHeight).clamp(0.0, 1.0);
    return IgnorePointer(
      child: SizedBox(
        height: stripHeight,
        child: ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [Colors.transparent, Colors.black],
            stops: [0.0, fadeStop],
          ).createShader(rect),
          blendMode: BlendMode.dstIn,
          child: _OpaqueBlur(style: style),
        ),
      ),
    );
  }
}

class _OpaqueBlur extends StatelessWidget {
  const _OpaqueBlur({required this.style});
  final GlassNavStyle style;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: style.blurSigma,
          sigmaY: style.blurSigma,
        ),
        child: ColoredBox(color: style.glassTint),
      ),
    );
  }
}

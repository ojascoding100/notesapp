import 'package:flutter/material.dart';

/// ─── Neo-Brutalist Design Tokens ─────────────────────────────────────────────

class NB {
  NB._();

  // ── Surfaces & Neutrals ──────────────────────────────────────────────────
  static const Color canvas = Color(0xFFFAF9F5);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color dim = Color(0xFFDADAD6);
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textMuted = Color(0xA61E1E1E); // ~65% opacity
  static const Color borderBlack = Color(0xFF000000);

  // ── Vibrant Sticky Note Palette ──────────────────────────────────────────
  static const Color buttercupYellow = Color(0xFFFDE047);
  static const Color mintGreen = Color(0xFF4ADE80);
  static const Color lavender = Color(0xFFC084FC);
  static const Color electricPink = Color(0xFFFF6EE5);
  static const Color skyBlue = Color(0xFF38BDF8);
  static const Color hotOrange = Color(0xFFFF5722);

  static const Map<String, Color> colorMap = {
    'yellow': buttercupYellow,
    'green': mintGreen,
    'purple': lavender,
    'pink': electricPink,
    'cyan': skyBlue,
    'orange': hotOrange,
  };

  static const List<Color> cardColors = [
    buttercupYellow,
    mintGreen,
    lavender,
    electricPink,
    skyBlue,
  ];

  // ── Font Families (bundled assets) ───────────────────────────────────────
  static const String fontDisplay = 'Fredoka';
  static const String fontBody = 'Quicksand';

  // ── Shadows ──────────────────────────────────────────────────────────────
  static const double strokeWidth = 2.5;
  static const double fabStrokeWidth = 2.8;

  /// Standard resting shadow (zero blur, zero spread, pure black).
  static const BoxShadow shadowResting = BoxShadow(
    color: borderBlack,
    offset: Offset(4, 4),
    blurRadius: 0,
    spreadRadius: 0,
  );

  /// Compact resting shadow.
  static const BoxShadow shadowCompact = BoxShadow(
    color: borderBlack,
    offset: Offset(3.5, 3.5),
    blurRadius: 0,
    spreadRadius: 0,
  );

  /// Pressed / active shadow.
  static const BoxShadow shadowPressed = BoxShadow(
    color: borderBlack,
    offset: Offset(1, 1),
    blurRadius: 0,
    spreadRadius: 0,
  );

  /// FAB shadow.
  static const BoxShadow shadowFab = BoxShadow(
    color: borderBlack,
    offset: Offset(5, 5),
    blurRadius: 0,
    spreadRadius: 0,
  );

  // ── Corner Radii ─────────────────────────────────────────────────────────
  static const double cardRadius = 20.0;
  static const double pillRadius = 999.0;
  static const double badgeRadius = 13.0;

  // ── Micro-dot grid ───────────────────────────────────────────────────────
  static const double dotSpacing = 28.0;
  static const double dotRadius = 1.6;
  static const double dotOpacity = 0.04;

  // ── Typography ───────────────────────────────────────────────────────────

  /// Display 1 – home screen greeting.
  static TextStyle display1() => const TextStyle(
        fontFamily: fontDisplay,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.8,
        color: textPrimary,
      );

  /// Title Large – editor note title.
  static TextStyle titleLarge() => const TextStyle(
        fontFamily: fontDisplay,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
        color: textPrimary,
      );

  /// Title Medium – card titles, modal titles.
  static TextStyle titleMedium() => const TextStyle(
        fontFamily: fontDisplay,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.3,
        color: textPrimary,
      );

  /// Body Large – editor multi-line writing.
  static TextStyle bodyLarge() => const TextStyle(
        fontFamily: fontBody,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.6,
        letterSpacing: 0,
        color: textPrimary,
      );

  /// Body Regular – card snippet preview.
  static TextStyle bodyRegular() => const TextStyle(
        fontFamily: fontBody,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
        color: textPrimary,
      );

  /// Pill Tag / Caption.
  static TextStyle pillCaption() => const TextStyle(
        fontFamily: fontDisplay,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.0,
        letterSpacing: 0.5,
        color: textPrimary,
      );

  /// Button Label.
  static TextStyle buttonLabel() => const TextStyle(
        fontFamily: fontDisplay,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.0,
        letterSpacing: 0.2,
        color: Colors.white,
      );

  // ── Standard bordered container decoration ───────────────────────────────
  static BoxDecoration cardDecoration({
    required Color color,
    double radius = cardRadius,
    BoxShadow shadow = shadowResting,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderBlack, width: strokeWidth),
      boxShadow: [shadow],
    );
  }

  /// Pill decoration (fully rounded).
  static BoxDecoration pillDecoration({
    required Color color,
    BoxShadow? shadow,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(pillRadius),
      border: Border.all(color: borderBlack, width: strokeWidth),
      boxShadow: shadow != null ? [shadow] : null,
    );
  }
}

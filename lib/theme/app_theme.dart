import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Linear & Stripe Inspired SaaS Color Palette
  static const Color primary = Color(0xFF2563EB); // Vibrant Royal Blue (#2563EB)
  static const Color primaryLight = Color(0xFFEEF5FB); // Secondary Card Fill
  static const Color primaryDark = Color(0xFF1E40AF); // Deep Royal Blue (#1E40AF)
  
  // Background & Surface Colors
  static const Color background = Color(0xFFF5F7FB); // Background (#F5F7FB)
  static const Color surface = Color(0xFFFFFFFF); // Surface / Card (#FFFFFF)
  static const Color secondaryCard = Color(0xFFEEF5FB); // Secondary Card (#EEF5FB)
  static const Color navyAccent = Color(0xFF2563EB); // Vibrant Royal Blue
  static const Color navyAccentSecondary = Color(0xFF1E40AF);
  
  // Accent & Brand Colors
  static const Color accent = Color(0xFF5CC8FF); // Accent Blue (#5CC8FF)
  static const Color accentBlue = Color(0xFF5CC8FF); // Accent Blue (#5CC8FF)
  static const Color lightBlue = Color(0xFFEEF5FB); // Light Blue Fill
  
  // Text & Typography Colors
  static const Color heading = Color(0xFF102A5B); // Heading (#102A5B)
  static const Color textPrimary = Color(0xFF102A5B); // High Contrast Navy (#102A5B)
  static const Color textSecondary = Color(0xFF64748B); // Body Text (#64748B)
  static const Color textBody = Color(0xFF64748B); // Alias for textSecondary
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textLight = Colors.white;
  
  // Input & Border Colors
  static const Color borderLight = Color(0xFFE7EDF4); // Border (#E7EDF4)
  static const Color borderFocused = Color(0xFF5CC8FF); // Accent Blue Focus Border
  static const Color inputFill = Color(0xFFF5F7FB); // Light Background Fill
  
  // Status Colors (Vibrant Mint Success #16C784)
  static const Color success = Color(0xFF16C784); // Success Green (#16C784)
  static const Color successLight = Color(0xFFE8F9F1); // Light Green Background (#E8F9F1)
  static const Color emerald = Color(0xFF16C784);
  static const Color emeraldLight = Color(0xFFE8F9F1);
  
  static const Color teal = Color(0xFF0D9488);
  static const Color tealLight = Color(0xFFF0FDFA);
  
  static const Color indigo = Color(0xFF2563EB);
  static const Color indigoLight = Color(0xFFEEF5FB);
  
  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color warningLight = Color(0xFFFFFBEB); // Amber 50
  
  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color errorLight = Color(0xFFFEF2F2); // Red 50
  
  static const Color rose = Color(0xFFE11D48);
  static const Color roseLight = Color(0xFFFFF1F2);
  
  // Flat design configuration - No shadows
  static List<BoxShadow> get softShadow => const [];
  static List<BoxShadow> get buttonShadow => const [];
}

class AppTheme {
  static TextTheme _buildTextTheme(Color primaryTextColor, Color secondaryTextColor, String language) {
    final baseTextTheme = TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: primaryTextColor,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: primaryTextColor,
        letterSpacing: -0.5,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: primaryTextColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: secondaryTextColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );

    if (language == 'Khmer') {
      return GoogleFonts.kantumruyProTextTheme(baseTextTheme);
    } else {
      return GoogleFonts.plusJakartaSansTextTheme(baseTextTheme);
    }
  }

  static ThemeData getTheme({bool isDark = false, String language = 'English'}) {
    return isDark ? darkThemeFor(language) : lightThemeFor(language);
  }

  static ThemeData get lightTheme => lightThemeFor('English');
  static ThemeData get darkTheme => darkThemeFor('English');

  static ThemeData lightThemeFor(String language) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: AppColors.borderLight, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),

      // Text Theme: Battambang for Khmer, Plus Jakarta Sans for English
      textTheme: _buildTextTheme(AppColors.textPrimary, AppColors.textSecondary, language),

      // Input Decoration Theme (Rounded Pill Text Fields)
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
        ),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: AppColors.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: AppColors.primary,
        ),
      ),
    );
  }

  static ThemeData darkThemeFor(String language) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: Color(0xFF1E293B),
        onSurface: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: Color(0xFF334155), width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: _buildTextTheme(Colors.white, const Color(0xFF94A3B8), language),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: const Color(0xFF0F172A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

enum ToastType { success, error, info, warning }

class AppToast {
  // Show a premium styled floating toast
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final config = _toastConfig(type);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: duration,
        content: _ToastContent(
          message: message,
          icon: config.icon,
          iconColor: config.iconColor,
          iconBg: config.iconBg,
          borderColor: config.borderColor,
        ),
      ),
    );
  }

  static _ToastConfig _toastConfig(ToastType type) {
    switch (type) {
      case ToastType.success:
        return _ToastConfig(
          icon: Icons.check_circle_rounded,
          iconColor: const Color(0xFF16A34A),
          iconBg: const Color(0xFFDCFCE7),
          borderColor: const Color(0xFF86EFAC),
        );
      case ToastType.error:
        return _ToastConfig(
          icon: Icons.cancel_rounded,
          iconColor: const Color(0xFFDC2626),
          iconBg: const Color(0xFFFEE2E2),
          borderColor: const Color(0xFFFCA5A5),
        );
      case ToastType.warning:
        return _ToastConfig(
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFD97706),
          iconBg: const Color(0xFFFEF3C7),
          borderColor: const Color(0xFFFCD34D),
        );
      case ToastType.info:
        return _ToastConfig(
          icon: Icons.info_rounded,
          iconColor: const Color(0xFF2563EB),
          iconBg: const Color(0xFFDBEAFE),
          borderColor: const Color(0xFF93C5FD),
        );
    }
  }
}

class _ToastConfig {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color borderColor;
  const _ToastConfig({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.borderColor,
  });
}

class _ToastContent extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color borderColor;

  const _ToastContent({
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.borderColor,
  });

  @override
  State<_ToastContent> createState() => _ToastContentState();
}

class _ToastContentState extends State<_ToastContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.icon, color: widget.iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            // Message
            Expanded(
              child: Text(
                widget.message,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

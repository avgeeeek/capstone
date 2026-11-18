import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum ButtonVariant { primary, accent, outline, danger, ghost }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final double? width;
  final double height;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double borderRadius;
  final double fontSize;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.width,
    this.height = 54,
    this.prefixIcon,
    this.suffixIcon,
    this.borderRadius = 14,
    this.fontSize = 16,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    Widget label = widget.isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: _getForegroundColor(),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.prefixIcon != null) ...[
                Icon(widget.prefixIcon,
                    size: 20, color: _getForegroundColor()),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w800,
                  color: _getForegroundColor(),
                  fontFamily: 'Inter',
                  letterSpacing: 0.2,
                ),
              ),
              if (widget.suffixIcon != null) ...[
                const SizedBox(width: 8),
                Icon(widget.suffixIcon,
                    size: 20, color: _getForegroundColor()),
              ],
            ],
          );

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) => _pressCtrl.forward(),
        onTapUp: isDisabled
            ? null
            : (_) {
                _pressCtrl.reverse();
                widget.onPressed?.call();
              },
        onTapCancel: () => _pressCtrl.reverse(),
        child: SizedBox(
          width: widget.fullWidth ? double.infinity : widget.width,
          height: widget.height,
          child: _buildButton(label, isDisabled),
        ),
      ),
    );
  }

  Widget _buildButton(Widget child, bool isDisabled) {
    switch (widget.variant) {
      case ButtonVariant.outline:
        return OutlinedButton(
          onPressed: isDisabled ? null : widget.onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(
              color: isDisabled ? AppColors.borderLight : AppColors.primary,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            backgroundColor: AppColors.surface,
          ),
          child: child,
        );

      case ButtonVariant.danger:
        return ElevatedButton(
          onPressed: isDisabled ? null : widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
          child: child,
        );

      case ButtonVariant.accent:
        return ElevatedButton(
          onPressed: isDisabled ? null : widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.textOnAccent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              side: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          child: child,
        );

      case ButtonVariant.ghost:
        return TextButton(
          onPressed: isDisabled ? null : widget.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
          child: child,
        );

      case ButtonVariant.primary:
        return ElevatedButton(
          onPressed: isDisabled ? null : widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
          child: child,
        );
    }
  }

  Color _getForegroundColor() {
    switch (widget.variant) {
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return AppColors.primary;
      case ButtonVariant.accent:
        return AppColors.textOnAccent;
      case ButtonVariant.danger:
      case ButtonVariant.primary:
        return Colors.white;
    }
  }
}

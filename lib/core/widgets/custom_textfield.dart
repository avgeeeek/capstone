import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? initialValue;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSaved,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.autofocus = false,
    this.initialValue,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      readOnly: widget.readOnly,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      textInputAction: widget.textInputAction,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      onSaved: widget.onSaved,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: AppColors.textHint,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : widget.suffixIcon,
        counterText: '',
      ),
    );
  }
}

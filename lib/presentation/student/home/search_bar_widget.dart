import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String? hint;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.hint,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _controller = TextEditingController();
  bool _hasFocus = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _hasFocus = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hasFocus ? AppColors.primary : AppColors.borderLight,
            width: _hasFocus ? 2.5 : 1.5,
          ),
          boxShadow: _hasFocus
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: TextField(
          controller: _controller,
          onChanged: (v) {
            widget.onChanged(v);
            setState(() {});
          },
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Search stalls or dishes...',
            hintStyle: const TextStyle(
                color: AppColors.textHint, fontFamily: 'Inter'),
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppColors.textHint, size: 22),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textHint, size: 20),
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged('');
                      setState(() {});
                    },
                  )
                : null,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }
}

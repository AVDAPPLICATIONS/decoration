import 'dart:async';
import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onQueryChanged; // debounced change
  final ValueChanged<String>? onSubmitted; // keyboard submit
  final VoidCallback? onVoiceTap; // optional mic/voice action
  final String initialText;
  final bool autofocus;
  final int debounceMs;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double height;

  const CustomSearchBar({
    super.key,
    this.hintText = 'Search…',
    this.onQueryChanged,
    this.onSubmitted,
    this.onVoiceTap,
    this.initialText = '',
    this.autofocus = false,
    this.debounceMs = 300,
    this.padding = const EdgeInsets.fromLTRB(12, 12, 12, 8),
    this.borderRadius = 20,
    this.height = 56,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focus;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focus = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
      widget.onQueryChanged?.call(text);
    });
    setState(() {}); // update clear icon + visuals
  }

  void _clear() {
    _controller.clear();
    widget.onQueryChanged?.call('');
    setState(() {});
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    final borderColor =
        focused ? AppColors.primary.withOpacity(0.45) : Colors.grey.shade200;
    final borderWidth = focused ? 1.5 : 1.2;

    return Padding(
      padding: widget.padding,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFF9F9FB),
            ],
          ),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: focused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.14),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    spreadRadius: 0,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        clipBehavior: Clip.antiAlias,
        child: TextField(
          controller: _controller,
          focusNode: _focus,
          autofocus: widget.autofocus,
          textInputAction: TextInputAction.search,
          keyboardType: TextInputType.text,
          maxLines: 1,
          onChanged: _onChanged,
          onSubmitted: widget.onSubmitted,
          cursorWidth: 2.0,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              height: 1.2,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            // Prefix
            prefixIcon: Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.16),
                    AppColors.primary.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            prefixIconConstraints:
                const BoxConstraints.tightFor(width: 44, height: 44),
            // Suffix (clear + optional mic)
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_controller.text.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.18),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      onPressed: _clear,
                    ),
                  ),
                if (widget.onVoiceTap != null)
                  Container(
                    margin: const EdgeInsets.only(
                        left: 4, right: 6, top: 6, bottom: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.18),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      tooltip: 'Voice search',
                      icon: const Icon(
                        Icons.mic_none_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      onPressed: widget.onVoiceTap,
                    ),
                  ),
                const SizedBox(width: 2),
              ],
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 44),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class SearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool isLoading;
  final String? resultCountLabel;
  final TextInputAction textInputAction;

  const SearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onClear,
    this.isLoading = false,
    this.resultCountLabel,
    this.textInputAction = TextInputAction.search,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTextChanged);
      widget.controller.addListener(_handleTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = widget.controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          textInputAction: widget.textInputAction,
          textAlign: TextAlign.start,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _buildSuffix(hasText),
          ),
        ),
        if (widget.resultCountLabel != null &&
            widget.resultCountLabel!.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.resultCountLabel!,
            style: AppTextStyles.caption,
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffix(bool hasText) {
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (!hasText) {
      return null;
    }

    return IconButton(
      tooltip: AppLocalizations.of(context).clear,
      onPressed: widget.onClear,
      icon: const Icon(Icons.close),
    );
  }
}

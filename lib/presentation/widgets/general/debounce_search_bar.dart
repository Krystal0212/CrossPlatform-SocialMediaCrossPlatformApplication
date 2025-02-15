

import 'package:socialapp/utils/import.dart';

class DebouncedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChangedDebounced;
  final Duration debounceDuration;

  const DebouncedTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChangedDebounced,
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  @override
  State<DebouncedTextField> createState() => _DebouncedTextFieldState();
}

class _DebouncedTextFieldState extends State<DebouncedTextField> {
  Timer? _debounce;

  void _onTextChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      widget.onChangedDebounced(value.trim());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.trolleyGrey),
        ),
      ),
      onChanged: _onTextChanged,
    );
  }
}

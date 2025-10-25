import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomTextInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? errorText;
  final VoidCallback? onSuffixIconTap;

  const CustomTextInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.onSuffixIconTap,
  });

  @override
  State<CustomTextInput> createState() => _CustomTextInputState();
}

class _CustomTextInputState extends State<CustomTextInput> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    // Initialize obscureText based on whether it's a password field
    _obscureText = widget.isPassword;
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          style: const TextStyle(fontSize: 16, color: AppColors.darkGrey),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: AppColors.hint),

            // Filled background style
            filled: true,
            fillColor: AppColors.textfield,

            // Rounded borders
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(59.29),
              borderSide: BorderSide.none, // Hide default border
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(59.29),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(59.29),
              borderSide: const BorderSide(color: AppColors.textfield, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(59.29),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(59.29),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),

            // Optional prefix icon
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.textBody)
                : null,

            // Toggle button for password visibility or custom suffix icon
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xff1f1f1f),
                      size: 16,
                    ),
                    onPressed: _toggleVisibility,
                  )
                : widget.suffixIcon != null
                    ? (widget.onSuffixIconTap != null
                        ? IconButton(
                            icon: Icon(widget.suffixIcon,
                                color: AppColors.textBody, size: 20),
                            onPressed: widget.onSuffixIconTap,
                          )
                        : Icon(
                            widget.suffixIcon,
                            color: AppColors.textBody,
                            size: 20,
                          ))
                    : null,

            contentPadding: const EdgeInsets.symmetric(
              vertical: 18.0,
              horizontal: 20.0,
            ),
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 16.0),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

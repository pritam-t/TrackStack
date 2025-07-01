import 'package:flutter/material.dart';

PreferredSizeWidget buildFancyAppBar({
  required BuildContext context,
  required String title,
  required VoidCallback? onBack,
  required VoidCallback? onNext,
  required IconData backicon,
  required IconData nexticon,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(100), // Taller app bar
    child: Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 198, 228, 1.0),
        boxShadow: [
          const BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Custom icon with GestureDetector
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.shade200, width: 1.5),
                ),
                child: Icon(  // Changed to use the passed customIcon
                  backicon,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Title with accent underline
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    height: 3,
                    width: 40,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            // Arrow button with GestureDetector
            GestureDetector(
              onTap: onNext,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.shade200, width: 1.5),
                ),
                child: Icon(  // Changed to use the passed customIcon
                  nexticon,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
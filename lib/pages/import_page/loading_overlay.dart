import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        CircularProgressIndicator(backgroundColor: Colors.white,),
        SizedBox(height: 12),
        Text(
          'Loading...',
        ),
      ],
    ),
  );
}
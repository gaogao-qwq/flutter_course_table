import 'package:flutter/material.dart';

// TODO: Implement ImportFromEditor
class ImportFromEditor extends StatefulWidget {
  const ImportFromEditor({super.key});

  @override
  State<ImportFromEditor> createState() => _ImportFromEditorState();
}

class _ImportFromEditorState extends State<ImportFromEditor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("手动创建课表")),
      body: const Placeholder(),
    );
  }
}

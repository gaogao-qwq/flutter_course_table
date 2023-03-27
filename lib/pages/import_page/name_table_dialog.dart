import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NameTableDialog extends StatefulWidget {
  final String initName;
  final SharedPreferences prefs;

  const NameTableDialog({
    super.key,
    required this.initName,
    required this.prefs,
  });

  @override
  State<NameTableDialog> createState() => _NameTableDialogState();
}

class _NameTableDialogState extends State<NameTableDialog> {
  final _formKey = GlobalKey<FormState>();
  String? name;

  @override
  void initState() {
    name = widget.initName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Name the imported course table"),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(64),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  autofocus: true,
                  initialValue: name,
                  maxLength: 50,
                  onChanged: (value) { setState(() { name = value; }); },
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Please input course table name";
                    if (widget.prefs.containsKey(value)) return "Current course table name existed";
                    return null;
                  },
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note_alt_rounded),
                    border: UnderlineInputBorder(),
                    labelText: "Input name",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () { Navigator.pop(context, null); },
                          child: const Text("Cancel"),
                      )),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) return;
                            Navigator.pop(context, name);
                          },
                          child: const Text("Save"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) => SimpleDialog(
    backgroundColor: Colors.white,
    children: <Widget>[
      Center(
        child: Container(
          padding: const EdgeInsets.all(64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const CircularProgressIndicator(backgroundColor: Colors.grey,),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: const Text('Loading...'),
              ),
            ]
          )
        ),
      ),
    ],
  );
}
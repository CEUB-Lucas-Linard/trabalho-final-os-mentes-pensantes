import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
    final string title;

    const MyHomePage({super.key, required this.title});

    @override
    Widget build(BuildContext context){
        return Scaffold(
            body: Container(
                color: Colors.blue,
                child: Text("Hello Flutter"),
            ),
        )


    }
}
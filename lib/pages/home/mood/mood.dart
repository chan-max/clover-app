import 'package:flutter/material.dart';

class MoodPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('心情日记',style: TextStyle(fontSize: 13),),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          '',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

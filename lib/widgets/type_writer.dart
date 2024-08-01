import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class TypeWriter extends StatefulWidget {
  const TypeWriter({super.key, required this.text, required this.delay});
  final String text;
  final Duration delay;

  @override
  State<TypeWriter> createState() => _TypeWriterState();
}

class _TypeWriterState extends State<TypeWriter> {
  int _currentIndex = 0;
  void typeWritingAnimation() {
    if (_currentIndex < widget.text.length) {
      _currentIndex++;
      setState(() {});
    }

    Future.delayed(widget.delay, () {
      typeWritingAnimation();
    });
  }

  @override
  void initState() {
    Future.delayed(
      Duration(seconds: 2),
    ).whenComplete(() {
      typeWritingAnimation();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text.substring(0, _currentIndex),
      style: TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: MediaQuery.of(context).size.height * 0.06,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(92, 255, 255, 255)),
    );
  }
}

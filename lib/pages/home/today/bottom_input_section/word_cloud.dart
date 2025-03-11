import 'package:flutter/material.dart';
import 'dart:math' as math;

class WordCloud extends StatelessWidget {
  final List<String> sentences;
  final Function(String) onSentenceTap;

  WordCloud({required this.sentences, required this.onSentenceTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.0,
        runSpacing: 8.0,
        children: sentences.map((sentence) {
          return AnimatedWordItem(
            sentence: sentence,
            onTap: () => onSentenceTap(sentence),
          );
        }).toList(),
      ),
    );
  }
}

class AnimatedWordItem extends StatefulWidget {
  final String sentence;
  final VoidCallback onTap;

  const AnimatedWordItem({required this.sentence, required this.onTap});

  @override
  _AnimatedWordItemState createState() => _AnimatedWordItemState();
}

class _AnimatedWordItemState extends State<AnimatedWordItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    Future.delayed(Duration(milliseconds: (500 * math.Random().nextDouble()).toInt()), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          );
        },
        child: _SentenceItem(sentence: widget.sentence),
      ),
    );
  }
}

class _SentenceItem extends StatelessWidget {
  final String sentence;

  const _SentenceItem({required this.sentence});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        sentence,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
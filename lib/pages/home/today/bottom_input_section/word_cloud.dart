import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:uuid/uuid.dart'; // 方案2 需要

class Sentence {
  final String sentence;
  final double fontSize;

  Sentence({required this.sentence, required this.fontSize});
}

class WordCloud extends StatelessWidget {
  final List<dynamic> sentences;
  final Function(String) onSentenceTap;

  const WordCloud({required this.sentences, required this.onSentenceTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.0,
        runSpacing: 8.0,
        children: sentences.asMap().entries.map((entry) {
          int index = entry.key;
          dynamic sentence = entry.value;

          return AnimatedWordItem(
            key: ValueKey('$index-${sentence.sentence}'), // 方案1: 结合索引和文本
            sentence: sentence.sentence,
            fontSize: sentence.fontSize,
            onTap: () => onSentenceTap(sentence.sentence),
          );
        }).toList(),
      ),
    );
  }
}

class AnimatedWordItem extends StatefulWidget {
  final String sentence;
  final double fontSize;
  final VoidCallback onTap;

  const AnimatedWordItem({
    Key? key,
    required this.sentence,
    required this.fontSize,
    required this.onTap,
  }) : super(key: key);

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
    _initializeAnimations();
    _startAnimationWithDelay();
  }

  @override
  void didUpdateWidget(covariant AnimatedWordItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sentence != oldWidget.sentence) {
      _restartAnimation();
    }
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startAnimationWithDelay() {
    Future.delayed(Duration(milliseconds: (300 * math.Random().nextDouble()).toInt()), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  void _restartAnimation() {
    _controller.reset();
    _startAnimationWithDelay();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _controller.reverse().then((_) {
      _controller.forward();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: _SentenceItem(
                sentence: widget.sentence,
                fontSize: widget.fontSize,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SentenceItem extends StatelessWidget {
  final String sentence;
  final double fontSize;

  const _SentenceItem({
    required this.sentence,
    required this.fontSize,
  });

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
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

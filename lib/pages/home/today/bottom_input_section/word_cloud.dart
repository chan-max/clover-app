import 'package:flutter/material.dart';
import 'dart:math' as math;

class Sentence {
  final String sentence;
  final dynamic fontSize;

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
        spacing: 6.0, // 缩小间距
        runSpacing: 6.0, // 缩小行间距
        children: sentences.asMap().entries.map((entry) {
          int index = entry.key;
          dynamic sentence = entry.value;

          return AnimatedWordItem(
            key: ValueKey('$index-${sentence.sentence}'),
            sentence: sentence.sentence,
            fontSize: sentence.fontSize * 0.8, // 调小字体大小
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
  late Color _randomColor;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationWithDelay();
    _randomColor = _getRandomColor(); // 获取随机颜色
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

  Color _getRandomColor() {
    dynamic rand = math.Random();
    return Color.fromRGBO(
      rand.nextInt(256), // 随机红色
      rand.nextInt(256), // 随机绿色
      rand.nextInt(256), // 随机蓝色
      1.0,
    );
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
                color: _randomColor, // 设置随机颜色
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
  final Color color;

  const _SentenceItem({
    required this.sentence,
    required this.fontSize,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // 调整内边距
      decoration: BoxDecoration(
        color: color.withOpacity(0.2), // 气泡的背景色增加透明度
        borderRadius: BorderRadius.circular(25.0), // 圆角形状，模拟气泡
        border: Border.all(
          color: color.withOpacity(0.4), // 边框颜色增加透明度
          width: 1.5, // 边框宽度
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15), // 阴影颜色的透明度
            blurRadius: 6,
            offset: Offset(2, 2), // 阴影偏移量
          ),
        ],
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

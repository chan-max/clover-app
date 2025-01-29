import 'package:flutter/material.dart';
import '/common/api.dart';
import 'package:fl_chart/fl_chart.dart'; // 导入 fl_chart 包

class HeightAnalyzePage extends StatefulWidget {
  @override
  _HeightAnalyzePageState createState() => _HeightAnalyzePageState();
}

class _HeightAnalyzePageState extends State<HeightAnalyzePage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _heightRecords = [];
  bool showAvg = false; // 用于切换显示平均线

  // 模拟接口请求
  Future<void> _fetchHeightAnalysis() async {
    var response = await getMyHeightRecords(); // 模拟接口请求

    setState(() {
      // 假设接口返回的数据是一个List
      _heightRecords = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchHeightAnalysis(); // 页面加载时请求数据
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleTextStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        title: const Text('身高分析'),
        iconTheme: const IconThemeData(color: Colors.grey),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.grey,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView( // 可滚动视图
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator() // 加载时显示进度条
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 图表部分，放在最上方并用 Card 包裹
                      Card(
                        elevation: 4, // 卡片阴影效果
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // 圆角效果
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0), // 内边距
                          child: Column(
                            children: [
                              const Text(
                                '身高变化趋势:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Stack(
                                children: <Widget>[
                                  AspectRatio(
                                    aspectRatio: 1.70,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 18,
                                        left: 12,
                                        top: 24,
                                        bottom: 12,
                                      ),
                                      child:
                                          LineChart(showAvg ? avgData() : mainData()),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60,
                                    height: 34,
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          showAvg = !showAvg;
                                        });
                                      },
                                      child: Text(
                                        'avg',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32), // 分隔图表和身高记录的间距
                      const Text(
                        '身高分析结果:',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 16),
                      if (_heightRecords.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true, // 防止列表超过屏幕时发生溢出
                          physics:
                              NeverScrollableScrollPhysics(), // 禁用滚动以避免冲突
                          itemCount: _heightRecords.length,
                          itemBuilder: (context, index) {
                            final record = _heightRecords[index];
                            DateTime createTime =
                                DateTime.parse(record['createTime']);
                            String formattedTime =
                                "${createTime.year}-${createTime.month}-${createTime.day} ${createTime.hour}:${createTime.minute}:${createTime.second}";
                            return Card(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(8.0),
                                child:
                                    Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children:[
                                    Text(
                                      "身高:${record['height']} cm",
                                      style:
                                          const TextStyle(fontSize :16, fontWeight :FontWeight.bold),
                                    ),
                                    const SizedBox(height :8),
                                    Text("记录时间:$formattedTime",
                                        style:
                                            const TextStyle(fontSize :14, color :Colors.grey)),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      else
                        const Text(
                          '暂无身高记录',
                          style:
                              TextStyle(fontSize :16, color :Colors.grey),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight :FontWeight.bold, fontSize :16);
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('MAR', style :style);
        break;
      case 5:
        text = const Text('JUN', style :style);
        break;
      case 8:
        text = const Text('SEP', style :style);
        break;
      default:
        text = const Text('', style :style);
        break;
    }

    return SideTitleWidget(meta :meta, child :text);
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight :FontWeight.bold, fontSize :15);
    String text;
    switch (value.toInt()) {
      case 1:
        text = '10K';
        break;
      case 3:
        text = '30K';
        break;
      case 5:
        text = '50K';
        break;
      default:
        return Container();
    }

    return Text(text, style :style, textAlign :TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData:
          FlGridData(show:true, drawVerticalLine:true, horizontalInterval :1 , verticalInterval :1 , getDrawingHorizontalLine :(value) {return FlLine(color :const Color(0xff37434d), strokeWidth :1);}, getDrawingVerticalLine :(value) {return FlLine(color :const Color(0xff37434d), strokeWidth :1);}),
      titlesData:
          FlTitlesData(show:true,rightTitles :const AxisTitles(sideTitles :SideTitles(showTitles:false)), topTitles :const AxisTitles(sideTitles :SideTitles(showTitles:false)), bottomTitles :AxisTitles(sideTitles :SideTitles(showTitles:true,reservedSize :30 , interval :1 , getTitlesWidget :bottomTitleWidgets)), leftTitles :AxisTitles(sideTitles :SideTitles(showTitles:true, interval :1 , getTitlesWidget :leftTitleWidgets,reservedSize :42))),
      borderData:
          FlBorderData(show:true,border :Border.all(color :const Color(0xff37434d))),
      minX :0,maxX :11,minY :0,maxY :6,lineBarsData :
          [LineChartBarData(spots :
              [FlSpot(0 ,3),FlSpot(2.6 ,2),FlSpot(4.9 ,5),FlSpot(6.8 ,3.1),FlSpot(8 ,4),FlSpot(9.5 ,3),FlSpot(11 ,4)],
              isCurved:true,gradient :
              LinearGradient(colors :
                  [Colors.cyan,Colors.blue]),barWidth :5,isStrokeCapRound:true,dotData :
              FlDotData(show:false),belowBarData :
              BarAreaData(show:true,gradient :
                  LinearGradient(colors :
                      [Colors.cyan.withOpacity(0.3),Colors.blue.withOpacity(0.3)])))]
    );
}

LineChartData avgData() {
    return LineChartData(
      lineTouchData:
          LineTouchData(enabled:false),
      gridData:
          FlGridData(show:true, drawHorizontalLine:true, verticalInterval :1 , horizontalInterval :1 , getDrawingVerticalLine :(value) {return FlLine(color :const Color(0xff37434d), strokeWidth :1);}, getDrawingHorizontalLine :(value) {return FlLine(color :const Color(0xff37434d), strokeWidth :1);}),
      titlesData:
          FlTitlesData(show:true,bottomTitles :
              AxisTitles(sideTitles :
                  SideTitles(showTitles:true,reservedSize :30,getTitlesWidget :
                      bottomTitleWidgets, interval :
                      1)),leftTitles :
              AxisTitles(sideTitles :
                  SideTitles(showTitles:true,getTitlesWidget :
                      leftTitleWidgets,reservedSize :
                      42, interval :
                      1)),topTitles :
              const AxisTitles(sideTitles :
                  SideTitles(showTitles:false)),rightTitles :
              const AxisTitles(sideTitles :
                  SideTitles(showTitles:false))),
      borderData:
          FlBorderData(show:true,border :
              Border.all(color :const Color(0xff37434d))),
      minX :0,maxX :11,minY :0,maxY :6,lineBarsData :
          [LineChartBarData(spots :
              [FlSpot(0 ,3.44),FlSpot(2.6 ,3.44),FlSpot(4.9 ,3.44),FlSpot(6.8 ,3.44),FlSpot(8 ,3.44),FlSpot(9.5 ,3.44),FlSpot(11 ,3.44)],
              isCurved:true,gradient :
              LinearGradient(colors :
                  [ColorTween(begin :Colors.cyan,end :Colors.blue).lerp(0.2)!,
                  ColorTween(begin :Colors.cyan,end :Colors.blue).lerp(0.2)!]),barWidth :
              5,isStrokeCapRound:true,dotData :
              FlDotData(show:false),belowBarData :
              BarAreaData(show:true,gradient :
                  LinearGradient(colors :
                      [ColorTween(begin :Colors.cyan,end :
                          Colors.blue).lerp(0.2)!.withOpacity(0.1),
                      ColorTween(begin :Colors.cyan,end :
                          Colors.blue).lerp(0.2)!.withOpacity(0.1)])))]
    );
}
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/common/provider.dart';
import '/common/api.dart';

class FinancePage extends StatefulWidget {
  @override
  _FinancePageState createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  late DateTime _selectedDay;
  TextEditingController _amountController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  String _transactionType = 'income'; // income or expense

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // 保存财务记录
  void _saveTransaction() async {
    String amountStr = _amountController.text;
    String title = _titleController.text.isEmpty ? '未知交易' : _titleController.text;

    if (amountStr.isEmpty || double.tryParse(amountStr) == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('请输入有效的金额')));
      return;
    }

    double amount = double.parse(amountStr);

    Map<String, dynamic> transactionRecord = {
      'type': _transactionType,
      'title': title,
      'amount': amount,
      'date': _selectedDay.toIso8601String(),
    };

    await addDayRecordDetail(null, transactionRecord);

    // 更新交易记录到 provider
    Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('财务记录保存成功')),
    );
  }

  // 删除财务记录
  void _deleteRecord(String recordId) async {
    var dayRecord = Provider.of<AppDataProvider>(context, listen: false)
        .getData('dayrecord');
    var pid = dayRecord['id'];

    Map<String, dynamic> postData = {
      'pid': pid,
      'id': recordId,
    };

    try {
      await deleteDayrecordDetail(postData);
      Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('财务记录已删除')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var dayRecord = Provider.of<AppDataProvider>(context).getData('dayrecord');

    List<Map<String, dynamic>> transactionRecords = [];
    if (dayRecord['record'] != null) {
      transactionRecords = List<Map<String, dynamic>>.from(
        dayRecord['record']
                ?.where((record) => record['type'] == 'income' || record['type'] == 'expense') ??
            [],
      );
    }

    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleTextStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        title: const Text('财务管理'),
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
        actions: [
          // 小的保存按钮，放在右上方
          IconButton(
            icon: Icon(Icons.save, size: 20),
            onPressed: _saveTransaction,
            color: Colors.purpleAccent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 财务记录输入部分
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题输入框
                    TextField(
                      controller: _titleController,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '请输入交易标题',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    Divider(color: Colors.grey[300], thickness: 1),

                    SizedBox(height: 16),
                    // 金额输入框
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '请输入金额',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    Divider(color: Colors.grey[300], thickness: 1),

                    SizedBox(height: 16),
                    Text(
                      '今天是 ${DateFormat('yyyy-MM-dd').format(_selectedDay)} 的财务记录',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.purpleAccent,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('选择交易类型：',
                        style: TextStyle(color: Colors.purpleAccent)),

                    // 交易类型选择
                    Row(
                      children: [
                        ChoiceChip(
                          label: Text("收入"),
                          selected: _transactionType == 'income',
                          onSelected: (selected) {
                            setState(() {
                              _transactionType = 'income';
                            });
                          },
                          selectedColor: Colors.purple[100],
                          backgroundColor: Colors.white,
                        ),
                        SizedBox(width: 8),
                        ChoiceChip(
                          label: Text("支出"),
                          selected: _transactionType == 'expense',
                          onSelected: (selected) {
                            setState(() {
                              _transactionType = 'expense';
                            });
                          },
                          selectedColor: Colors.red[100],
                          backgroundColor: Colors.white,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveTransaction,
                      child: Text(
                        '保存财务记录',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // 财务记录列表
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: transactionRecords.isEmpty
                    ? Text('今天没有财务记录', style: TextStyle(color: Colors.grey))
                    : Column(
                        children: transactionRecords.map((record) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: record['type'] == 'income'
                                  ? Colors.green[50]
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '标题：${record['title'] ?? '无标题'}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '金额：${record['amount']} 元',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteRecord(record['id']),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

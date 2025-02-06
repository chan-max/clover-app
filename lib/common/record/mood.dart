class MoodConfig {
  // 定义心情大类及其小类
  static const List<Map<String, dynamic>> moodCategories = [
    {
      'category': '积极', // 积极心情
      'children': [
        {'type': 'happy', 'name': '快乐'},
        {'type': 'excited', 'name': '兴奋'},
        {'type': 'hopeful', 'name': '充满希望'},
        {'type': 'grateful', 'name': '感激'},
        {'type': 'relaxed', 'name': '放松'},
        {'type': 'optimistic', 'name': '乐观'},
        {'type': 'proud', 'name': '自豪'},
        {'type': 'content', 'name': '满足'},
        {'type': 'cheerful', 'name': '愉快'},
      ],
    },
    {
      'category': '消极', // 消极心情
      'children': [
        {'type': 'sad', 'name': '悲伤'},
        {'type': 'angry', 'name': '愤怒'},
        {'type': 'anxious', 'name': '焦虑'},
        {'type': 'stressed', 'name': '压力大'},
        {'type': 'lonely', 'name': '孤独'},
        {'type': 'guilty', 'name': '内疚'},
        {'type': 'embarrassed', 'name': '尴尬'},
        {'type': 'confused', 'name': '困惑'},
        {'type': 'frustrated', 'name': '沮丧'},
        {'type': 'hopeless', 'name': '绝望'},
        {'type': 'disappointed', 'name': '失望'},
        {'type': 'ashamed', 'name': '羞耻'},
        {'type': 'regretful', 'name': '后悔'},
        {'type': 'fearful', 'name': '恐惧'},
      ],
    },
    {
      'category': '正常', // 正常心情
      'children': [
        {'type': 'neutral', 'name': '平静'},
        {'type': 'bored', 'name': '无聊'},
        {'type': 'surprised', 'name': '惊讶'},
        {'type': 'indifferent', 'name': '冷漠'},
        {'type': 'curious', 'name': '好奇'},
        {'type': 'tired', 'name': '疲倦'},
        {'type': 'distracted', 'name': '分心'},
        {'type': 'apathetic', 'name': '冷淡'},
      ],
    },
  ];
}

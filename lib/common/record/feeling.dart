class FeelingConfig {
  // 定义身体感受大类及其小类
  static const List<Map<String, dynamic>> feelingCategories = [
    {
      'category': '舒适', // 舒适感受
      'children': [
        {'type': 'energized', 'name': '充满活力'},
        {'type': 'relaxed', 'name': '放松'},
        {'type': 'comfortable', 'name': '舒适'},
        {'type': 'refreshed', 'name': '精神焕发'},
        {'type': 'healthy', 'name': '健康'},
        {'type': 'content', 'name': '满足'},
        {'type': 'sleepy', 'name': '困倦'},
        {'type': 'calm', 'name': '平静'},
        {'type': 'refreshed', 'name': '神清气爽'},
      ],
    },
    
    {
      'category': '不适', // 不适感受
      'children': [
        {'type': 'tired', 'name': '疲倦'},
        {'type': 'dizzy', 'name': '头晕'},
        {'type': 'painful', 'name': '疼痛'},
        {'type': 'nauseous', 'name': '恶心'},
        {'type': 'weak', 'name': '虚弱'},
        {'type': 'cold', 'name': '寒冷'},
        {'type': 'feverish', 'name': '发热'},
        {'type': 'shaky', 'name': '发抖'},
        {'type': 'sick', 'name': '生病'},
        {'type': 'indigestion', 'name': '消化不良'},
        {'type': 'stuffy', 'name': '鼻塞'},
        {'type': 'sore', 'name': '酸痛'},
      ],
    },
    {
      'category': '紧张', // 紧张感受
      'children': [
        {'type': 'stressed', 'name': '压力大'},
        {'type': 'nervous', 'name': '紧张'},
        {'type': 'anxious', 'name': '焦虑'},
        {'type': 'restless', 'name': '坐立不安'},
        {'type': 'fidgety', 'name': '烦躁不安'},
        {'type': 'overwhelmed', 'name': '不堪重负'},
        {'type': 'frustrated', 'name': '沮丧'},
        {'type': 'burnout', 'name': '职业倦怠'},
        {'type': 'fearful', 'name': '害怕'},
        {'type': 'paranoid', 'name': '多疑'},
      ],
    },
    {
      'category': '情绪波动', // 情绪波动
      'children': [
        {'type': 'happy', 'name': '快乐'},
        {'type': 'sad', 'name': '悲伤'},
        {'type': 'angry', 'name': '愤怒'},
        {'type': 'excited', 'name': '兴奋'},
        {'type': 'hopeful', 'name': '充满希望'},
        {'type': 'disappointed', 'name': '失望'},
        {'type': 'guilty', 'name': '内疚'},
        {'type': 'embarrassed', 'name': '尴尬'},
        {'type': 'jealous', 'name': '嫉妒'},
        {'type': 'confused', 'name': '困惑'},
      ],
    },
    {
      'category': '精神状态', // 精神状态
      'children': [
        {'type': 'focused', 'name': '专注'},
        {'type': 'distracted', 'name': '分心'},
        {'type': 'creative', 'name': '有创意'},
        {'type': 'clear-minded', 'name': '头脑清晰'},
        {'type': 'foggy', 'name': '头脑不清'},
        {'type': 'indifferent', 'name': '冷漠'},
        {'type': 'curious', 'name': '好奇'},
        {'type': 'bored', 'name': '无聊'},
        {'type': 'apathetic', 'name': '冷淡'},
      ],
    },
    {
      'category': '生理反应', // 生理反应
      'children': [
        {'type': 'hungry', 'name': '饥饿'},
        {'type': 'thirsty', 'name': '口渴'},
        {'type': 'full', 'name': '饱腹'},
        {'type': 'sleepy', 'name': '困倦'},
        {'type': 'sweaty', 'name': '出汗'},
        {'type': 'bloated', 'name': '腹胀'},
        {'type': 'muscle_tension', 'name': '肌肉紧张'},
        {'type': 'heartbeat', 'name': '心跳加速'},
        {'type': 'shivering', 'name': '发抖'},
        {'type': 'breathless', 'name': '喘不上气'},
      ],
    },
    {
      'category': '正常', // 正常感受
      'children': [
        {'type': 'neutral', 'name': '平静'},
        {'type': 'balanced', 'name': '平衡'},
        {'type': 'stable', 'name': '稳定'},
        {'type': 'normal', 'name': '正常'},
        {'type': 'indifferent', 'name': '无感'},
      ],
    },
  ];
}

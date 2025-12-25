class MoodAnalyzer {
  // ... (Keep _emojiMap and analyze method the same) ...
  static final Map<String, String> _emojiMap = {
    // HAPPY
    'happy': '😊', 'joy': '😁', 'awesome': '🤩', 'great': '😄', 'good': '🙂',
    'excited': '😆', 'love': '🥰', 'proud': '🦁', 'grateful': '🙏',
    'blessed': '✨',
    'fantastic': '🥳', 'win': '🏆', 'success': '🚀', 'hope': '🌱', 'fun': '🎉',

    // SAD
    'sad': '😢', 'cry': '😭', 'bad': '😞', 'lonely': '🥀', 'hurt': '💔',
    'depressed': '🌧️', 'fail': '📉', 'grief': '🕯️', 'miss': '😿',
    'upset': '😣',

    // ANGRY
    'angry': '😡', 'hate': '🤬', 'mad': '😤', 'furious': '👿', 'annoyed': '🙄',
    'frustrated': '💢', 'stupid': '🤦', 'irritated': '😒',

    // ANXIOUS
    'scared': '😨', 'anxious': '😰', 'nervous': '😬', 'worry': '😟',
    'stress': '🤯',
    'fear': '😱', 'panic': '🚨', 'busy': '🌪️', 'overwhelmed': '😵',

    // TIRED
    'tired': '😴', 'bored': '😐', 'sleepy': '💤', 'exhausted': '😫',
    'meh': '😶',
    'lazy': '🦥', 'sick': '🤒', 'ill': '🤢',
  };

  static String analyze(String text) {
    String lowerText = text.toLowerCase();
    for (var key in _emojiMap.keys) {
      if (lowerText.contains(key)) {
        return _emojiMap[key]!;
      }
    }
    return '📝';
  }

  static String getLabel(String emoji) {
    if ([
      '😊',
      '😁',
      '🤩',
      '😄',
      '🙂',
      '😆',
      '🥰',
      '🦁',
      '🙏',
      '✨',
      '🥳',
      '🏆',
      '🚀',
      '🌱',
      '🎉'
    ].contains(emoji)) {
      return "Happy";
    }
    if (['😢', '😭', '😞', '🥀', '💔', '🌧️', '📉', '🕯️', '😿', '😣']
        .contains(emoji)) {
      return "Sad";
    }
    if (['😡', '🤬', '😤', '👿', '🙄', '💢', '🤦', '😒'].contains(emoji)) {
      return "Angry";
    }
    if (['😨', '😰', '😬', '😟', '🤯', '😱', '🚨', '🌪️', '😵']
        .contains(emoji)) {
      return "Anxious";
    }
    if (['😴', '😐', '💤', '😫', '😶', '🦥', '🤒', '🤢'].contains(emoji)) {
      return "Tired";
    }
    return "Neutral";
  }

  // --- 3. IMPROVED TRIGGERS ---
  static List<String> getPotentialTriggers(String text) {
    String t = text.toLowerCase();
    List<String> triggers = [];

    // Work & School
    if (t.contains('work') ||
        t.contains('boss') ||
        t.contains('job') ||
        t.contains('deadline') ||
        t.contains('meeting') ||
        t.contains('office')) {
      triggers.add("Work Stress");
    }
    if (t.contains('school') ||
        t.contains('exam') ||
        t.contains('test') ||
        t.contains('grade') ||
        t.contains('homework') ||
        t.contains('study') ||
        t.contains('college') ||
        t.contains('university') ||
        t.contains('class')) {
      triggers.add("School/Studies");
    }

    // Finances
    if (t.contains('money') ||
        t.contains('broke') ||
        t.contains('expensive') ||
        t.contains('bill') ||
        t.contains('rent') ||
        t.contains('buy') ||
        t.contains('cost')) {
      triggers.add("Finances");
    }

    // Health
    if (t.contains('sleep') ||
        t.contains('awake') ||
        t.contains('insomnia') ||
        t.contains('tired') ||
        t.contains('napping')) {
      triggers.add("Sleep Quality");
    }
    if (t.contains('sick') ||
        t.contains('pain') ||
        t.contains('headache') ||
        t.contains('doctor') ||
        t.contains('med') ||
        t.contains('hurt') ||
        t.contains('fever')) {
      triggers.add("Physical Health");
    }
    if (t.contains('food') ||
        t.contains('eat') ||
        t.contains('diet') ||
        t.contains('weight') ||
        t.contains('hungry') ||
        t.contains('meal')) {
      triggers.add("Health/Diet");
    }

    // Social
    if (t.contains('friend') ||
        t.contains('fight') ||
        t.contains('argument') ||
        t.contains('drama') ||
        t.contains('lie') ||
        t.contains('ignored')) {
      triggers.add("Social Conflict");
    }
    if (t.contains('partner') ||
        t.contains('love') ||
        t.contains('date') ||
        t.contains('breakup') ||
        t.contains('gf') ||
        t.contains('bf') ||
        t.contains('husband') ||
        t.contains('wife')) {
      triggers.add("Relationship");
    }
    if (t.contains('family') ||
        t.contains('mom') ||
        t.contains('dad') ||
        t.contains('parent') ||
        t.contains('brother') ||
        t.contains('sister')) {
      triggers.add("Family Issues");
    }

    // Environment
    if (t.contains('traffic') ||
        t.contains('car') ||
        t.contains('late') ||
        t.contains('bus') ||
        t.contains('drive')) {
      triggers.add("Commute");
    }
    if (t.contains('rain') ||
        t.contains('cold') ||
        t.contains('hot') ||
        t.contains('weather') ||
        t.contains('gloom')) {
      triggers.add("Weather");
    }

    return triggers.isEmpty ? ["General Stress"] : triggers;
  }

  // ... (Keep getAdvice and getColor same as before)
  static String getAdvice(String category) {
    switch (category) {
      case "Happy":
        return "You're doing great! Try to pinpoint what made you feel this way and do more of it.";
      case "Sad":
        return "It's okay to feel down. Try to get some fresh air or listen to comforting music.";
      case "Angry":
        return "Take a deep breath. Count to 10. Physical exercise can help burn off this energy.";
      case "Anxious":
        return "Ground yourself. Name 5 things you can see, 4 you can touch, 3 you hear.";
      case "Tired":
        return "Listen to your body. A 20-minute power nap might be what you need.";
      default:
        return "Keep journaling. Tracking your thoughts is the first step to understanding them.";
    }
  }

  static int getColor(String category) {
    switch (category) {
      case "Happy":
        return 0xFF4CAF50;
      case "Sad":
        return 0xFF2196F3;
      case "Angry":
        return 0xFFF44336;
      case "Anxious":
        return 0xFFFF9800;
      case "Tired":
        return 0xFF9E9E9E;
      default:
        return 0xFF607D8B;
    }
  }
}

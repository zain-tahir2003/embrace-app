class EmotionDetector {
  static const Map<String, List<String>> _emotionKeywords = {
    'Happy': [
      'happy',
      'joy',
      'excited',
      'great',
      'awesome',
      'love',
      'good',
      'wonderful',
      'smile'
    ],
    'Sad': [
      'sad',
      'cry',
      'depressed',
      'unhappy',
      'bad',
      'hurt',
      'pain',
      'lonely',
      'miss'
    ],
    'Angry': [
      'angry',
      'mad',
      'furious',
      'hate',
      'annoyed',
      'irritated',
      'rage'
    ],
    'Anxious': [
      'nervous',
      'worried',
      'scared',
      'fear',
      'anxiety',
      'stress',
      'tension'
    ],
  };

  static String detectEmotion(String text) {
    String lowerText = text.toLowerCase();

    for (var entry in _emotionKeywords.entries) {
      for (var keyword in entry.value) {
        if (lowerText.contains(keyword)) {
          return entry.key;
        }
      }
    }
    return 'Neutral';
  }
}

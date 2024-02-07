String capitalizeFirstLetter(String text) {
  return text
      .split(' ')
      .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : word)
      .join(' ');
}

String capitalizeWords({required String text}) {
  List<String> words = text.split(' ');
  for (int i = 0; i < words.length; i++) {
    if (words[i].isNotEmpty) {
      words[i] = words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
    }
  }
  return words.join(' ');
}

String pluralize({required String word, required int count}) {
  return count == 1 ? word : '${word}s';
}

String volumeInKOrM(double number) {
  if (number < 1000) {
    return '< 1K';
  } else if (number < 1000000) {
    return '${(number / 1000).toStringAsFixed(1)}K';
  } else {
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }
}
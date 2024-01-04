String capitalizeFirstLetter(String text) {
  return text
      .split(' ')
      .map((word) => word.isNotEmpty
      ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
      : word)
      .join(' ');
}

double barWidth({required int length}) {

    if(length > 20) {
      return 5;
    } else if(length > 10) {
      return 10;
    }

    return 20;
}
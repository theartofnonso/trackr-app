enum ChartUnit {
  kg("kg"),
  lbs("lbs"),
  reps(""),
  m("m"),
  h("h"),
  yd("yd"),
  mi("mi"),
  percentage("%");

  const ChartUnit(this.label);

  final String label;
}
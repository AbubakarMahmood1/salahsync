enum IbadahTaskRepeatType {
  daily('Daily'),
  weekly('Weekly'),
  specificDays('Specific days'),
  afterEveryPrayer('After every prayer'),
  oneTime('One-time');

  const IbadahTaskRepeatType(this.label);

  final String label;

  bool get requiresDaySelection {
    return this == IbadahTaskRepeatType.weekly ||
        this == IbadahTaskRepeatType.specificDays;
  }
}

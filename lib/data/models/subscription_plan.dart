enum SubscriptionPlan {
  weekly(price: 49.99),
  monthly(price: 99.99),
  yearly(price: 699.99);

  const SubscriptionPlan({required this.price});

  final double price;

  static int get yearlySavingsPercent =>
      ((1 - yearly.price / (monthly.price * 12)) * 100).floor();
}

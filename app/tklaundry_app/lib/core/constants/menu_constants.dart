class MenuConstants {
  MenuConstants._();

  static const order = 'order';
  static const delivery = 'delivery';
  static const expend = 'expend';
  static const deliveryView = 'deliveryView';
  static const salesView = 'salesView';
  static const salesChart = 'salesChart';
  static const customer = 'customer';
  static const product = 'product';
  static const code = 'code';
  static const member = 'member';
}

enum MenuId {
  order(MenuConstants.order),
  delivery(MenuConstants.delivery),
  expend(MenuConstants.expend),
  deliveryView(MenuConstants.deliveryView),
  salesView(MenuConstants.salesView),
  salesChart(MenuConstants.salesChart),
  customer(MenuConstants.customer),
  product(MenuConstants.product),
  code(MenuConstants.code),
  member(MenuConstants.member);

  const MenuId(this.id);

  final String id;

  static MenuId? fromId(String? value) {
    if (value == null) return null;
    for (final item in MenuId.values) {
      if (item.id == value) return item;
    }
    return null;
  }
}

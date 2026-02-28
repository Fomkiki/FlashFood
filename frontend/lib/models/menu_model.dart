class MenuModel {
  final int id;
  final int id_res;
  final String name_menu;
  final String? img_url;
  final double price;
  final String status_menu;
  final String? note;
  final String category;

  MenuModel({
    required this.id,
    required this.id_res,
    required this.name_menu,
    this.img_url,
    required this.price,
    required this.status_menu,
    this.note,
    required this.category,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'],
      id_res: json['id_res'],
      name_menu: json['name_menu'],
      img_url: json['img_url'],
      price: double.parse(json['price'].toString()),
      status_menu: json['status_menu'],
      note: json['note'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_res': id_res,
      'name_menu': name_menu,
      'img_url': img_url,
      'price': price,
      'status_menu': status_menu,
      'note': note,
      'category': category,
    };
  }
}

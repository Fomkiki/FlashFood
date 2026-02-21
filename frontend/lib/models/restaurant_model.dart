class Restaurant {
  final String name_res, open_time, close_time, zone, phone, address, img_url;
  final int id_users, id_res;

  Restaurant({
    required this.name_res,
    required this.open_time,
    required this.close_time,
    required this.zone,
    required this.phone,
    required this.address,
    required this.img_url,
    required this.id_users,
    required this.id_res,
  });
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name_res: json['name_res'],
      open_time: json['open_time'],
      close_time: json['close_time'],
      zone: json['zone'],
      phone: json['phone'],
      address: json['address'],
      img_url: json['img_url'],
      id_users: json['id_users'],
      id_res: json['id_res'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name_res": name_res,
      "open_time": open_time,
      "close_time": close_time,
      "zone": zone,
      "phone": phone,
      "address": address,
      "img_url": img_url,
      "id_users": id_users,
    };
  }
}

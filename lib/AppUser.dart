class AppUser {
  String? firstName;
  String? lastName;
  int? age;
  String? address;

  AppUser({this.firstName, this.lastName, this.age, this.address});

  AppUser.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    age = json['age'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstName'] = this.firstName ?? "";
    data['lastName'] = this.lastName ?? "";
    data['age'] = this.age ?? 0;
    data['address'] = this.address ?? "";
    return data;
  }
}

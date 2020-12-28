class Balance {
  int id;
  String userId;
  int amount;
  String status;
  String updated;
  String created;

  Balance(
      {this.id,
      this.userId,
      this.amount,
      this.status,
      this.updated,
      this.created});

  Balance.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    amount = json['amount'];
    status = json['status'];
    updated = json['updated'];
    created = json['created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['amount'] = this.amount;
    data['status'] = this.status;
    data['updated'] = this.updated;
    data['created'] = this.created;
    return data;
  }
}

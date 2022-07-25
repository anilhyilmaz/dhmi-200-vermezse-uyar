import 'package:dhmigov/urldbhelper.dart';

class Url {
  int? id;
  String? url;

  Url(this.id, this.url);

  Url.fromMap(Map<String,dynamic> map) {
    id = map['id'];
    url = map['url'];
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnUrl : url,
    };
  }
}

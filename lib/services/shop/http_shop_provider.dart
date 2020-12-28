import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:greenapp/models/balance.dart';
import 'package:greenapp/models/item.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:image_jpeg/image_jpeg.dart';
import 'package:path/path.dart';

import 'package:http/http.dart' as http;

final FirebaseAuth _auth = FirebaseAuth.instance;

class HttpShopProvider {
  final VoidCallback logoutCallback;

  final fullUrl = "https://alter-eco-api.herokuapp.com/api/";

  final url = "alter-eco-api.herokuapp.com";

  final postfix = "/api";

  HttpShopProvider(this.logoutCallback);

  Future<bool> createItem(List<Object> objects, Item item) async {
    var uri = Uri.https(url, postfix + '/item');

    debugPrint('Create: ' + json.encode(item));

    final dio.Dio dioClient = new dio.Dio();
    dioClient.options.headers["Authorization"] = _getCurrentToken();
    //dioClient.options.contentType = "multipart/form-data";
    debugPrint("Object amount: " + objects.length.toString());
    List<File> fileList = new List<File>();
    for (Object object in objects) {
      if (object is File && object != null) {
        fileList.add(object);
      }
    }
    debugPrint("Object amount (files): " + fileList.length.toString());
    var formData = dio.FormData();
    formData.files.add(MapEntry(
        'item',
        new dio.MultipartFile.fromString(json.encode(item),
            contentType: MediaType('application', 'json'))));
    for (File file in fileList) {
      final image = Image.file(file);
      String newFileName =
          await ImageJpeg.encodeJpeg(file.path, null, 70, 1600, 900);
      formData.files.add(MapEntry(
          "attachment",
          await dio.MultipartFile.fromFile(newFileName,
              filename: basename(file.path),
              contentType: MediaType.parse("image/jpeg"))));
    }

    debugPrint(formData.files.length.toString());
    if (formData.files.length > 1) {
      debugPrint(formData.files.last.key);

      debugPrint(formData.files.last.value.contentType.type);
      debugPrint(formData.files.last.value.contentType.subtype);
      debugPrint(formData.files.last.value.filename);
      debugPrint(formData.files.last.value.length.toString());
    }

    final response = await dioClient.postUri(uri, data: formData);

    if (response.statusCode == 200) {
      debugPrint(response.statusCode.toString());
      debugPrint(response.data.toString());
      debugPrint('Update success');
      return true;
    } else {
      debugPrint(response.statusCode.toString());
      debugPrint(response.data.toString());
      debugPrint(response.headers.map.toString());
      debugPrint(response.statusMessage);
      if (response.statusCode == 401) logoutCallback();
      throw Exception('Failed to create item ${item.toString()}');
    }
  }

  Future<bool> updateItem(List<Object> objects, Item item) async {
    var queryParameters = {
      'detach': false.toString(),
    };
    var uri = Uri.https(url, postfix + '/item', queryParameters);

    debugPrint('Update item: ' + json.encode(item));

    final dio.Dio dioClient = new dio.Dio();
    dioClient.options.headers["Authorization"] = _getCurrentToken();
    //dioClient.options.contentType = "multipart/form-data";
    debugPrint("Object amount: " + objects.length.toString());
    List<File> fileList = new List<File>();
    for (Object object in objects) {
      if (object is File && object != null) {
        fileList.add(object);
      }
    }
    debugPrint("Object amount (files): " + fileList.length.toString());
    var formData = dio.FormData();
    formData.files.add(MapEntry(
        'item',
        new dio.MultipartFile.fromString(json.encode(item),
            contentType: MediaType('application', 'json'))));
    for (File file in fileList) {
      String newFileName =
          await ImageJpeg.encodeJpeg(file.path, null, 70, 1600, 900);
      formData.files.add(MapEntry(
          "attachment",
          await dio.MultipartFile.fromFile(newFileName,
              filename: basename(file.path),
              contentType: MediaType.parse("image/jpeg"))));
    }

    final response = await dioClient.putUri(uri, data: formData);

    if (response.statusCode == 200) {
      debugPrint(response.statusCode.toString());
      debugPrint(response.data.toString());
      debugPrint('Update success');
      return true;
    } else {
      debugPrint(response.statusCode.toString());
      debugPrint(response.data.toString());
      debugPrint(response.headers.map.toString());
      debugPrint(response.statusMessage);
      if (response.statusCode == 401) logoutCallback();
      throw Exception('Failed to update item ${item.toString()}');
    }
  }

  Future<List<Item>> getItemList(
      String createdBy, String searchString, int offset, int limit) async {
    Map body = ({
      'status': createdBy,
      "limit": limit,
      "offset": offset,
      "searchString": searchString,
    });
    final headers = <String, String>{
      'Authorization': await _getCurrentToken(),
      'Content-type': 'application/json',
    };
    debugPrint(body.toString());
    http.Response response = await http.post(
      fullUrl + "/items",
      headers: headers,
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      final t = json.decode(response.body);
      List<Item> itemList = [];
      for (Map i in t) {
        debugPrint(i.toString());
        itemList.add(Item.fromJson(i));
      }
      try {
        debugPrint(EnumToString.parse(itemList.first.id));
      } catch (e) {}
      return itemList;
    } else {
      // If the server did no
      //t return a 201 CREATED response,
      // then throw an exception
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      if (response.statusCode == 401) logoutCallback();
      throw Exception('Failed to parse items');
    }
  }

  Future<List<Item>> getItemListForCurrentUser() async {
    final headers = <String, String>{
      'Authorization': await _getCurrentToken(),
      'Content-type': 'application/json',
    };
    http.Response response = await http.get(
      fullUrl + "/items",
      headers: headers,
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      final t = json.decode(response.body);
      List<Item> itemList = [];
      for (Map i in t) {
        debugPrint(i.toString());
        itemList.add(Item.fromJson(i));
      }
      try {
        debugPrint(EnumToString.parse(itemList.first.id));
      } catch (e) {}
      return itemList;
    } else {
      // If the server did no
      //t return a 201 CREATED response,
      // then throw an exception
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      if (response.statusCode == 401) logoutCallback();
      throw Exception('Failed to parse items');
    }
  }

  Future<Item> getItem(int id) async {
    http.Response response = await http.get(
      fullUrl + "/item/$id",
      headers: <String, String>{
        'Authorization': await _getCurrentToken(),
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      debugPrint("Item getted");
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      final t = json.decode(response.body);
      debugPrint(t.toString());

      Item item = Item.fromJson(jsonDecode(response.body));
      return item;
    } else {
      // If the server did no
      //t return a 201 CREATED response,
      // then throw an exception
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      if (response.statusCode == 401) logoutCallback();
      throw Exception('Failed to parse Items');
    }
  }

  Future<bool> purchaseItem(int id) async {
    http.Response response = await http.get(
      fullUrl + "/item/$id/purchase",
      headers: <String, String>{
        'Authorization': await _getCurrentToken(),
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      debugPrint("Item purchased");
      return true;
    } else {
      // If the server did no
      //t return a 201 CREATED response,
      // then throw an exception
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      if (response.statusCode == 401) logoutCallback();
      return false;
    }
  }

  Future<Balance> getBalance() async {
    http.Response response = await http.get(
      fullUrl + "/account",
      headers: <String, String>{
        'Authorization': await _getCurrentToken(),
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      debugPrint("Item getted");
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      final t = json.decode(response.body);
      debugPrint(t.toString());

      Balance balance = Balance.fromJson(jsonDecode(response.body));
      return balance;
    } else {
      // If the server did no
      //t return a 201 CREATED response,
      // then throw an exception
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      if (response.statusCode == 401) logoutCallback();
      return null;
    }
  }

  Future<NetworkImage> getAttachment(int id) async {
    final t =
        NetworkImage(fullUrl + "/attachment/$id", headers: <String, String>{
      'Authorization': await _getCurrentToken(),
    });
    return t;
  }

  Future<String> _getCurrentToken() async {
    final token = await _auth.currentUser.getIdToken(false);
    final token2 = await _auth.currentUser.getIdTokenResult();
    debugPrint('Bearer ' + token);
    return token != null ? 'Bearer ' + token : '';
  }
}

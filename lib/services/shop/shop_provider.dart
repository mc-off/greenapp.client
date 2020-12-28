import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:greenapp/models/balance.dart';
import 'package:greenapp/models/item.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/pages/tasks_tab.dart';
import 'package:greenapp/services/shop/base_shop_provider.dart';
import 'package:greenapp/services/shop/http_shop_provider.dart';
import 'package:greenapp/services/task/base_task_provider.dart';
import 'package:greenapp/services/task/http_task_provider.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class ShopProvider implements BaseShopProvider {
  HttpShopProvider _httpShopProvider;
  VoidCallback logoutCallback;

  ShopProvider(this.logoutCallback) {
    this.logoutCallback = logoutCallback;
    _setShopProvider();
  }

  Future<void> _setShopProvider() async {
    _httpShopProvider = HttpShopProvider(logoutCallback);
  }

  @override
  Future<List<Item>> getItems() {
    return _httpShopProvider.getItemList(null, null, null, 100);
  }

  @override
  Future<List<Item>> getItemsForCurrentUser() {
    return _httpShopProvider.getItemListForCurrentUser();
  }

  Future<Item> getItem(int itemId) {
    return _httpShopProvider.getItem(itemId);
  }

  Future<bool> purchaseItem(int itemId) {
    return _httpShopProvider.purchaseItem(itemId);
  }

  Future<NetworkImage> getAttachment(int id) {
    return _httpShopProvider.getAttachment(id);
  }

  Future<bool> updateItem(List<Object> objects, Item item) {
    return _httpShopProvider.updateItem(objects, item);
  }

  Future<bool> createItem(List<Object> objects, Item item) {
    return _httpShopProvider.createItem(objects, item);
  }

  Future<Balance> getBalance() {
    return _httpShopProvider.getBalance();
  }

  String getToken() {
    String token;
    _auth.currentUser.getIdToken(false).then((value) => token = value);
    return token;
  }

  String getUserId() {
    return _auth.currentUser.uid;
  }

  @override
  Future<List<NetworkImage>> getAttachments(int itemId) {
    return null;
  }
}

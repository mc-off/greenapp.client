import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:greenapp/models/balance.dart';
import 'package:greenapp/models/item.dart';
import 'package:greenapp/models/task.dart';

abstract class BaseShopProvider {
  VoidCallback logoutCallback;

  Future<List<Item>> getItems();

  Future<List<Item>> getItemsForCurrentUser();

  Future<Item> getItem(int itemId);

  Future<bool> purchaseItem(int itemId);

  Future<List<NetworkImage>> getAttachments(int itemId);

  Future<NetworkImage> getAttachment(int id);

  Future<bool> updateItem(List<Object> objects, Item item);

  Future<bool> createItem(List<Object> objects, Item item);

  Future<Balance> getBalance();
}

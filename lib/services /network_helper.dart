import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class NetworkHelper {

  NetworkHelper({this.url});

  final String url;

  Future getData() async {
    http.Response responce;
    try {
      responce = await http.get(url);
    } catch (_) {
      return;
    }
    //if success
    if (responce.statusCode == 200) {
      String data = responce.body;

      print(data);

      return jsonDecode(data);
    }
  }
}
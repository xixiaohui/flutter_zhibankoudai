import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


Map<String, dynamic> normalize(Map<String, dynamic> data) {
  if (data.containsKey("data")) {
    return Map<String, dynamic>.from(data["data"]);
  }
  return data;
}

Future<Map<String, dynamic>> addModelData(
  String modelName,
  Map<String, dynamic> data,
) async {

  
  try {

    final cleanData = normalize(data);

    final jsonBody = jsonEncode({
        "collection": modelName,
        ...cleanData,
      });
    debugPrint('请求体: $jsonBody');

    final res = await http.post(
      Uri.parse("https://www.xclaw.living/api/hunyuan/addData"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonBody,
    );

    // ✅ 先判断 HTTP 状态
    if (res.statusCode != 200) {
      throw Exception("请求失败: ${res.statusCode}");
    }

    final body = jsonDecode(res.body);

    // ✅ 业务状态判断
    if (body["success"] != true) {
      throw Exception(body["error"] ?? "新增失败");
    }

    return Map<String, dynamic>.from(body["data"] ?? {});
  } catch (e) {
    throw Exception("addModelData 错误: $e");
  }
}




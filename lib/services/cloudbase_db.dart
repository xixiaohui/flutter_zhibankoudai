import 'package:flutter/material.dart';

import 'cloudbase_client.dart';

Future<dynamic> addModelData(String modelName, Map<String, dynamic> data, {String envType = 'prod'}) async {
  /// 新增数据模型数据

  return callFunction("addData",data: data);
}




// 使用示例
// void main() async {
//   final result = await addModelData('<YOUR_TABLE_NAME>', {'title': '示例标题'});
//   debugPrint(result);
// }




Future<dynamic> callFunction(
  String functionName, {
  Map<String, dynamic>? data,
}) async {
  final path = '/v1/functions/$functionName';

  try {
    final result = await cloudbase.request(
      'POST',
      path,
      body: {
        'data': data ?? {},
      },
    );

    debugPrint('云函数调用结果: $result');

    return result;
  } catch (e) {
    debugPrint('云函数调用失败: $e');
    rethrow;
  }
}

// 使用示例
// void main() async {
//   final result = await callFunction('<YOUR_FUNCTION_NAME>');
//   debugPrint(result);
// }
import 'dart:convert';
import 'package:http/http.dart' as http;

class Expert {
  final String title;
  final String content;

  Expert({required this.title, required this.content});

  factory Expert.fromJson(Map<String, dynamic> json) {
    return Expert(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}


class ApiService {
  static const baseUrl = 'http://localhost:3000';

  static Future<List<Expert>> getExperts() async {
    final res = await http.get(Uri.parse('$baseUrl/api/experts'));

    print(res);

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
     return (data['data'] as List).map((e) => Expert.fromJson(e)).toList();
     
    } else {
      throw Exception('API错误');
    }
  }
}
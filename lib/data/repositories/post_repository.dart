import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

class PostRepository {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const int _postLimit = 15;

  Future<List<Post>> fetchPosts() async {
    try {
     final response = await http
    .get(
      Uri.parse('$_baseUrl/posts?_limit=$_postLimit'),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'FlutterApp',
      },
    )
    .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Post.fromJson(json)).toList();
      } else {
        throw HttpException(
          'Failed to load posts. Status code: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const SocketException('No internet connection.');
    } on HttpException catch (e) {
      throw HttpException(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
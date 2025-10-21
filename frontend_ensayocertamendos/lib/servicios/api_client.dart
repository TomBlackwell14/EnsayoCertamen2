// CLIENTE HTTP SIMPLE PARA API LARAVEL
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modelos/auto.dart';
import '../modelos/marca.dart';

class ApiClient {
  final String baseUrl;
  ApiClient({required this.baseUrl});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ================== AUTOS ==================
  Future<List<Auto>> getAutos() async {
    final res = await http.get(Uri.parse('$baseUrl/autos'), headers: _headers);
    if (res.statusCode != 200)
      throw Exception('HTTP ${res.statusCode}: ${res.body}');

    final body = jsonDecode(res.body);

    // SI TU LARAVEL DEVUELVE PAGINADO {data: [...]} AJUSTA ACA:
    final List list = (body is Map && body['data'] is List)
        ? body['data']
        : (body as List);

    return list.map((j) => Auto.fromJson(j)).toList();
  }

  Future<Auto> getAuto(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/autos/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200)
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    return Auto.fromJson(jsonDecode(res.body));
  }

  Future<Auto> createAuto(Auto a) async {
    final res = await http.post(
      Uri.parse('$baseUrl/autos'),
      headers: _headers,
      body: jsonEncode(a.toJson()),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    return Auto.fromJson(jsonDecode(res.body));
  }

  Future<Auto> updateAuto(Auto a) async {
    if (a.id == null) throw Exception('ID REQUERIDO PARA UPDATE');
    final res = await http.put(
      Uri.parse('$baseUrl/autos/${a.id}'),
      headers: _headers,
      body: jsonEncode(a.toJson()),
    );
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    return Auto.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteAuto(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/autos/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }

  // ================== MARCAS ==================
  Future<List<Marca>> getMarcas() async {
    final res = await http.get(Uri.parse('$baseUrl/marcas'), headers: _headers);
    if (res.statusCode != 200)
      throw Exception('HTTP ${res.statusCode}: ${res.body}');

    final body = jsonDecode(res.body);
    final List list = (body is Map && body['data'] is List)
        ? body['data']
        : (body as List);

    return list.map((j) => Marca.fromJson(j)).toList();
  }
}

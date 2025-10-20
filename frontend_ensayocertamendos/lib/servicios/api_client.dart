// lib/services/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../modelos/marca.dart';
import '../modelos/auto.dart';

// COMENTARIOS EN MAYUSCULAS Y SIN TILDES
class ApiClient {
  final String baseUrl; // EJ: http://127.0.0.1:8000/api

  ApiClient({required this.baseUrl});

  // METODO AUXILIAR PARA HEADERS SEGUROS (SIN NULLS)
  Map<String, String> _headers() {
    return <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  // METODO AUXILIAR: DECODIFICAR RESPUESTA EN LISTA
  // SOPORTA FORMATO: { data: [...] } O DIRECTAMENTE [...]
  List<Map<String, dynamic>> _extractList(dynamic body) {
    if (body == null) return <Map<String, dynamic>>[];
    if (body is Map && body['data'] is List) {
      return (body['data'] as List).whereType<Map<String, dynamic>>().toList();
    }
    if (body is List) {
      return body.whereType<Map<String, dynamic>>().toList();
    }
    // SI NO ES NI MAP CON DATA NI LISTA, DEVUELVE VACIO
    return <Map<String, dynamic>>[];
  }

  // ----- MARCAS -----
  Future<List<Marca>> getMarcas({int page = 1}) async {
    final uri = Uri.parse('$baseUrl/marcas?page=$page');

    final res = await http.get(uri, headers: _headers());

    if (res.statusCode == 200) {
      // USAMOS UTF8 PARA EVITAR PROBLEMAS CON TILDES
      final raw = utf8.decode(res.bodyBytes);
      final dynamic body = (raw.isNotEmpty) ? jsonDecode(raw) : null;

      final lista = _extractList(body);
      return lista.map((e) => Marca.fromJson(e)).toList();
    } else {
      throw Exception('ERROR HTTP ${res.statusCode}: ${res.body}');
    }
  }

  // ----- AUTOS -----
  Future<List<Auto>> getAutos({int page = 1}) async {
    final uri = Uri.parse('$baseUrl/autos?page=$page');

    final res = await http.get(uri, headers: _headers());

    if (res.statusCode == 200) {
      final raw = utf8.decode(res.bodyBytes);
      final dynamic body = (raw.isNotEmpty) ? jsonDecode(raw) : null;

      final lista = _extractList(body);
      return lista.map((e) => Auto.fromJson(e)).toList();
    } else {
      throw Exception('ERROR HTTP ${res.statusCode}: ${res.body}');
    }
  }
}

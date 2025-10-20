// lib/modelos/marca.dart
// COMENTARIOS EN MAYUSCULAS Y SIN TILDES
class Marca {
  final int? id; // PUEDE VENIR NULL
  final String? nombre; // PUEDE VENIR NULL

  Marca({this.id, this.nombre});

  factory Marca.fromJson(Map<String, dynamic> j) {
    return Marca(
      id: (j['id'] is int) ? j['id'] as int : int.tryParse('${j['id']}'),
      nombre: (j['nombre'] as String?) ?? '', // DEFAULT STRING VACIO
    );
  }
}

// lib/modelos/auto.dart
class Auto {
  final String? patentes;
  final String? modelo;
  final int? precio;
  final int? marcaId;
  final String? marcaNombre; // <-- OPCIONAL, SI EL BACKEND LA ENVIA

  Auto({
    this.patentes,
    this.modelo,
    this.precio,
    this.marcaId,
    this.marcaNombre,
  });

  factory Auto.fromJson(Map<String, dynamic> j) {
    return Auto(
      patentes: j['patentes'] as String?,
      modelo: j['modelo'] as String?,
      precio: (j['precio'] is int)
          ? j['precio'] as int
          : int.tryParse('${j['precio']}'),
      marcaId: (j['marca_id'] is int)
          ? j['marca_id'] as int
          : int.tryParse('${j['marca_id']}'),
      marcaNombre: j['marca_nombre'] as String?, // <- si el backend la manda
    );
  }
}

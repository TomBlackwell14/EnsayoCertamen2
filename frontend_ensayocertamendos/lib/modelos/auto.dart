// MODELO AUTO CON CAMPOS BASICOS
class Auto {
  final int? id;
  final String patentes;
  final String modelo;
  final int precio;
  final int marcaId;

  // OPCIONAL: NOMBRE DE MARCA SI API LO INCLUYE VIA with('marca')
  final String? marcaNombre;

  Auto({
    this.id,
    required this.patentes,
    required this.modelo,
    required this.precio,
    required this.marcaId,
    this.marcaNombre,
  });

  factory Auto.fromJson(Map<String, dynamic> j) => Auto(
    id: j['id'],
    patentes: j['patentes'],
    modelo: j['modelo'],
    precio: (j['precio'] is int)
        ? j['precio']
        : int.tryParse('${j['precio']}') ?? 0,
    marcaId: j['marca_id'],
    marcaNombre: j['marca'] is Map ? j['marca']['nombre'] : j['marca_nombre'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'patentes': patentes,
    'modelo': modelo,
    'precio': precio,
    'marca_id': marcaId,
  };
}

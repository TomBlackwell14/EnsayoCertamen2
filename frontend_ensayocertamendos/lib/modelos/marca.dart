class Marca {
  final int id;
  final String nombre;

  Marca({required this.id, required this.nombre});

  factory Marca.fromJson(Map<String, dynamic> j) =>
      Marca(id: j['id'], nombre: j['nombre']);
}

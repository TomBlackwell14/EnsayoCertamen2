import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'servicios/api_client.dart';
import 'modelos/auto.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // URL BASE SEGUN PLATAFORMA (SE PUEDE SOBRESCRIBIR CON --dart-define)
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    final baseUrl = fromEnv.isNotEmpty
        ? fromEnv
        : (kIsWeb ? 'http://127.0.0.1:8000/api' : 'http://10.0.2.2:8000/api');

    final api = ApiClient(baseUrl: baseUrl);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AutosPage(api: api),
    );
  }
}

class AutosPage extends StatelessWidget {
  final ApiClient api;
  const AutosPage({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Autos')),
      body: FutureBuilder<List<Auto>>(
        future: api.getAutos(),
        builder: (context, snap) {
          // CARGANDO
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          // ERROR
          if (snap.hasError) {
            return Center(
              child: Text(
                'ERROR: ${snap.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // DATOS
          final autos = snap.data ?? [];
          if (autos.isEmpty) {
            return const Center(child: Text('SIN AUTOS'));
          }

          return ListView.builder(
            itemCount: autos.length,
            itemBuilder: (_, i) {
              final a = autos[i];

              // EVITA NULLS: USA ?? PARA VALORES VACIOS
              final modelo = a.modelo ?? 'Modelo desconocido';
              final marca = a.marcaNombre ?? 'Marca #${a.marcaId ?? 0}';
              final patente = a.patentes ?? '-';
              final precio = a.precio ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: Text('$modelo · $marca'),
                  subtitle: Text('Patente: $patente'),
                  trailing: Text('\$$precio'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

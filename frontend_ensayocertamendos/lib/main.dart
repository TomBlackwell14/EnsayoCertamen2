// COMENTARIOS EN MAYUSCULA Y SIN TILDES (PREFERENCIA DEL USUARIO)
// APP CON TABS: AUTOS Y MARCAS. CRUD EN AUTOS.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'servicios/api_client.dart';
import 'modelos/auto.dart';
import 'modelos/marca.dart';

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
      title: 'USM Autos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003366),
        ), // AZUL USM
        useMaterial3: true,
      ),
      home: HomeTabs(api: api),
    );
  }
}

class HomeTabs extends StatefulWidget {
  final ApiClient api;
  const HomeTabs({super.key, required this.api});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USM · Autos'),
        bottom: TabBar(
          controller: controller,
          tabs: const [
            Tab(icon: Icon(Icons.directions_car), text: 'Autos'),
            Tab(icon: Icon(Icons.sell_outlined), text: 'Marcas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: [
          AutosTab(api: widget.api),
          MarcasTab(api: widget.api),
        ],
      ),
    );
  }
}

// =================== TAB AUTOS (CRUD) ===================

class AutosTab extends StatefulWidget {
  final ApiClient api;
  const AutosTab({super.key, required this.api});

  @override
  State<AutosTab> createState() => _AutosTabState();
}

class _AutosTabState extends State<AutosTab> {
  late Future<List<Auto>> _future;
  List<Marca> _marcas = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = widget.api.getAutos();
    widget.api.getMarcas().then((m) => setState(() => _marcas = m));
    setState(() {});
  }

  Future<void> _openAutoForm({Auto? auto}) async {
    final result = await showModalBottomSheet<Auto>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AutoForm(auto: auto, marcas: _marcas),
      ),
    );

    if (result != null) {
      if (auto == null) {
        await widget.api.createAuto(result);
      } else {
        await widget.api.updateAuto(result);
      }
      _reload();
    }
  }

  Future<void> _deleteAuto(Auto auto) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar auto'),
        content: Text('Confirma eliminar ${auto.modelo} (${auto.patentes})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await widget.api.deleteAuto(auto.id!);
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Auto>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('ERROR AL CARGAR AUTOS: ${snap.error}'));
          }
          final autos = snap.data ?? [];
          if (autos.isEmpty) {
            return const Center(child: Text('SIN AUTOS'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemBuilder: (ctx, i) {
              final a = autos[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: Text(
                    '${a.modelo} · ${a.marcaNombre ?? "Marca #${a.marcaId}"}',
                  ),
                  subtitle: Text('Patente: ${a.patentes}'),
                  trailing: Text('\$${a.precio}'),
                  onTap: () async {
                    final updated = await Navigator.push<Auto?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AutoDetallePage(
                          auto: a,
                          api: widget.api,
                          marcas: _marcas,
                        ),
                      ),
                    );
                    if (updated != null) _reload();
                  },
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: autos.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAutoForm(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }
}

// FORMULARIO PARA CREAR/EDITAR AUTO
class AutoForm extends StatefulWidget {
  final Auto? auto;
  final List<Marca> marcas;
  const AutoForm({super.key, this.auto, required this.marcas});

  @override
  State<AutoForm> createState() => _AutoFormState();
}

class _AutoFormState extends State<AutoForm> {
  final _key = GlobalKey<FormState>();
  late TextEditingController modelo;
  late TextEditingController patentes;
  late TextEditingController precio;
  int? marcaId;

  @override
  void initState() {
    super.initState();
    modelo = TextEditingController(text: widget.auto?.modelo ?? '');
    patentes = TextEditingController(text: widget.auto?.patentes ?? '');
    precio = TextEditingController(text: widget.auto?.precio?.toString() ?? '');
    marcaId =
        widget.auto?.marcaId ??
        (widget.marcas.isNotEmpty ? widget.marcas.first.id : null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Form(
        key: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.auto == null ? 'Nuevo Auto' : 'Editar Auto',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: modelo,
              decoration: const InputDecoration(labelText: 'Modelo'),
              validator: (v) => (v == null || v.isEmpty) ? 'REQUERIDO' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: patentes,
              decoration: const InputDecoration(
                labelText: 'Patente (6 caracteres)',
              ),
              maxLength: 6,
              validator: (v) => (v == null || v.length != 6)
                  ? 'DEBEN SER 6 CARACTERES'
                  : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: precio,
              decoration: const InputDecoration(labelText: 'Precio (entero)'),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || int.tryParse(v) == null)
                  ? 'INGRESE UN ENTERO'
                  : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: marcaId,
              items: widget.marcas
                  .map(
                    (m) => DropdownMenuItem(value: m.id, child: Text(m.nombre)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => marcaId = v),
              decoration: const InputDecoration(labelText: 'Marca'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (_key.currentState!.validate() && marcaId != null) {
                        final a = Auto(
                          id: widget.auto?.id,
                          patentes: patentes.text.trim(),
                          modelo: modelo.text.trim(),
                          precio: int.parse(precio.text.trim()),
                          marcaId: marcaId!,
                        );
                        Navigator.pop(context, a);
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// DETALLE DEL AUTO CON EDITAR/ELIMINAR
class AutoDetallePage extends StatelessWidget {
  final Auto auto;
  final ApiClient api;
  final List<Marca> marcas;
  const AutoDetallePage({
    super.key,
    required this.auto,
    required this.api,
    required this.marcas,
  });

  Future<void> _editar(BuildContext context) async {
    final updated = await showModalBottomSheet<Auto>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AutoForm(auto: auto, marcas: marcas),
      ),
    );
    if (updated != null) {
      await api.updateAuto(updated);
      // VUELVE CON SEÑAL PARA REFRESCAR
      // ignore: use_build_context_synchronously
      Navigator.pop(context, updated);
    }
  }

  Future<void> _eliminar(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar auto'),
        content: Text('Confirma eliminar ${auto.modelo} (${auto.patentes})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await api.deleteAuto(auto.id!);
      // ignore: use_build_context_synchronously
      Navigator.pop(context, auto);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${auto.modelo}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${auto.modelo}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('Patente: ${auto.patentes}'),
                Text('Precio: \$${auto.precio}'),
                Text('Marca ID: ${auto.marcaId}'),
                if (auto.marcaNombre != null)
                  Text('Marca: ${auto.marcaNombre}'),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _eliminar(context),
                        child: const Text('Eliminar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _editar(context),
                        child: const Text('Editar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =================== TAB MARCAS (SOLO LISTADO) ===================

class MarcasTab extends StatelessWidget {
  final ApiClient api;
  const MarcasTab({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Marca>>(
      future: api.getMarcas(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('ERROR AL CARGAR MARCAS: ${snap.error}'));
        }
        final marcas = snap.data ?? [];
        if (marcas.isEmpty) return const Center(child: Text('SIN MARCAS'));
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemBuilder: (_, i) => ListTile(
            leading: const Icon(Icons.sell_outlined),
            title: Text(marcas[i].nombre),
            subtitle: Text('ID: ${marcas[i].id}'),
          ),
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: marcas.length,
        );
      },
    );
  }
}

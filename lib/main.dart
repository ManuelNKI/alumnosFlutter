import 'package:flutter/material.dart';
import 'models/estudiante.dart';
import 'services/api_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD Estudiantes',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ListaEstudiantes(),
    );
  }
}

class ListaEstudiantes extends StatefulWidget {
  const ListaEstudiantes({super.key});

  @override
  _ListaEstudiantesState createState() => _ListaEstudiantesState();
}

class _ListaEstudiantesState extends State<ListaEstudiantes> {
  final ApiService api = ApiService();
  late Future<List<Estudiante>> estudiantes;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void cargarDatos() {
    setState(() {
      estudiantes = api.getEstudiantes();
    });
  }

  void _mostrarFormulario({Estudiante? estudiante}) {
    final esEditar = estudiante != null;
    final cedulaController = TextEditingController(
      text: estudiante?.cedula ?? '',
    );
    final nombreController = TextEditingController(
      text: estudiante?.nombre ?? '',
    );
    final apellidoController = TextEditingController(
      text: estudiante?.apellido ?? '',
    );
    final direccionController = TextEditingController(
      text: estudiante?.direccion ?? '',
    );
    final telefonoController = TextEditingController(
      text: estudiante?.telefono ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(esEditar ? 'Editar Estudiante' : 'Nuevo Estudiante'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cedulaController,
                decoration: InputDecoration(labelText: 'Cédula'),
                enabled: !esEditar, // No permitir editar la cédula
              ),
              TextField(
                controller: nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: apellidoController,
                decoration: InputDecoration(labelText: 'Apellido'),
              ),
              TextField(
                controller: direccionController,
                decoration: InputDecoration(labelText: 'Dirección'),
              ),
              TextField(
                controller: telefonoController,
                decoration: InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nuevoEstudiante = Estudiante(
                cedula: cedulaController.text,
                nombre: nombreController.text,
                apellido: apellidoController.text,
                direccion: direccionController.text,
                telefono: telefonoController.text,
              );

              if (esEditar) {
                await api.updateEstudiante(nuevoEstudiante);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Estudiante actualizado')),
                );
              } else {
                await api.addEstudiante(nuevoEstudiante);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Estudiante agregado')));
              }

              Navigator.pop(context);
              cargarDatos();
            },
            child: Text(esEditar ? 'Actualizar' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lista de Estudiantes PHP")),
      body: FutureBuilder<List<Estudiante>>(
        future: estudiantes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No hay estudiantes"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Estudiante est = snapshot.data![index];
              return ListTile(
                title: Text("${est.nombre} ${est.apellido}"),
                subtitle: Text(est.cedula),
                onTap: () => _mostrarFormulario(estudiante: est),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await api.deleteEstudiante(est.cedula);
                    cargarDatos();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Estudiante eliminado")),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _mostrarFormulario(),
      ),
    );
  }
}

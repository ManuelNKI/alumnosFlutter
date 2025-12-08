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

  final TextEditingController _buscarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void cargarDatos() {
    setState(() {
      if (_buscarController.text.isEmpty) {
        estudiantes = api.getEstudiantes();
      } else {
        estudiantes = api.buscarPorCedula(_buscarController.text);
      }
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
                keyboardType: TextInputType.phone,
                maxLength: 10,
              ),
              TextField(
                controller: nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                maxLength: 20,
              ),
              TextField(
                controller: apellidoController,
                decoration: InputDecoration(labelText: 'Apellido'),
                maxLength: 20,
              ),
              TextField(
                controller: direccionController,
                decoration: InputDecoration(labelText: 'Dirección'),
                maxLength: 20,
              ),
              TextField(
                controller: telefonoController,
                decoration: InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                maxLength: 10,
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

  void _confirmarEliminacion(Estudiante estudiante) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: Text(
            "¿Estás seguro de eliminar a ${estudiante.nombre} ${estudiante.apellido}?",
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo sin borrar
              },
            ),
            TextButton(
              child: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Cierra el diálogo primero

                // Ahora sí, llamamos a la API
                await api.deleteEstudiante(estudiante.cedula);

                // Actualizamos la pantalla
                cargarDatos();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Estudiante eliminado")),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lista de Estudiantes")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _buscarController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              onChanged: (value) {
                cargarDatos();
              },
              decoration: InputDecoration(
                hintText: 'Buscar por cédula...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _buscarController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _buscarController.clear();
                          cargarDatos();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Estudiante>>(
              future: estudiantes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No hay estudiantes"));
                }

                // ... dentro del FutureBuilder ...

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 80,
                  ), // Espacio para que el botón flotante no tape el último item
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Estudiante est = snapshot.data![index];

                    return Card(
                      elevation: 3, // Sombreado
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ), // Separación entre tarjetas
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () => _mostrarFormulario(
                          estudiante: est,
                        ), // Editar al tocar la tarjeta
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // 1. AVATAR (Inicial del nombre)
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  est.nombre.isNotEmpty
                                      ? est.nombre[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),

                              // 2. INFORMACIÓN CENTRAL (Columna)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Nombre completo en negrita
                                    Text(
                                      "${est.nombre} ${est.apellido}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),

                                    // Fila Cédula
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.badge_outlined,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          est.cedula,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),

                                    // Fila Teléfono
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone_outlined,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          est.telefono,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),

                                    // Fila Dirección (con manejo de texto largo)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            est.direccion,
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow
                                                .ellipsis, // Puntos suspensivos si es muy largo
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // 3. BOTÓN ELIMINAR
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  _confirmarEliminacion(est);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _mostrarFormulario(),
      ),
    );
  }
}

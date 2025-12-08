import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:androdalumnos/models/estudiante.dart';

class ApiService {
  final String urlApi =
      'http://192.168.68.108/apiMovil/api.php';
  Future<List<Estudiante>> getEstudiantes() async {
    final response = await http.get(Uri.parse(urlApi));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      // Convertimos la lista de JSONs a lista de objetos Estudiante
      return body.map((json) => Estudiante.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al cargar estudiantes');
    }
  }

  Future<String> addEstudiante(Estudiante est) async {
    final response = await http.post(
      Uri.parse(urlApi),
      body: {
        'cedula': est.cedula,
        'nombre': est.nombre,
        'apellido': est.apellido,
        'direccion': est.direccion,
        'telefono': est.telefono,
      },
    );
    return response.body; // Retorna "Insertado"
  }

  Future<String> updateEstudiante(Estudiante est) async {
    // Construimos la URL con los datos
    String query =
        "?cedula=${est.cedula}&nombre=${est.nombre}&apellido=${est.apellido}&direccion=${est.direccion}&telefono=${est.telefono}";

    final response = await http.put(Uri.parse(urlApi + query));
    return response.body; // Retorna "Actualizado"
  }

  Future<String> deleteEstudiante(String cedula) async {
    String query = "?cedula=$cedula";
    final response = await http.delete(Uri.parse(urlApi + query));
    return response.body; // Retorna "Eliminado"
  }

  Future<List<Estudiante>> buscarPorCedula(String cedula) async {
    final response = await http.get(Uri.parse('$urlApi?cedula=$cedula'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Estudiante.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al buscar estudiante');
    }
  }
}

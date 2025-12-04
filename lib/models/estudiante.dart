class Estudiante {
  String cedula;
  String nombre;
  String apellido;
  String direccion;
  String telefono;

  Estudiante({
    required this.cedula,
    required this.nombre,
    required this.apellido,
    required this.direccion,
    required this.telefono,
  });

  factory Estudiante.fromJson(Map<String, dynamic> json) {
    return Estudiante(
      cedula: json['cedula']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
    );
  }
}
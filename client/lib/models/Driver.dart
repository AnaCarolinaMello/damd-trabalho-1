import 'package:damd_trabalho_1/models/User.dart';
import 'package:damd_trabalho_1/models/enum/UserType.dart';

class Driver extends User {
  final double rating;
  final int trips;
  final String vehicle;
  final String vehicleColor;
  final String licensePlate;
  String? arrivalTime;

  Driver({
    this.rating = 0.0,
    this.trips = 0,
    this.vehicle = '',
    this.vehicleColor = '',
    this.licensePlate = '',
    this.arrivalTime = '',
    super.type = UserType.driver,
    required super.name,
    required super.email,
    required super.password,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      rating: json['rating'],
      trips: json['trips'],
      vehicle: json['vehicle'] ?? 'Fiat',
      vehicleColor: json['vehicle_color'] ?? 'Branco',
      licensePlate: json['license_plate'] ?? 'ABC1234',
      name: json['name'],
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'trips': trips,
      'vehicle': vehicle,
      'vehicleColor': vehicleColor,
      'licensePlate': licensePlate,
      'name': name,
      'email': email,
      'password': password,
    };
  }

}

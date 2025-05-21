import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:damd_trabalho_1/models/Time.dart';

class RouteService {
  static Future<TimeModel?> getRouteDuration(
    LatLng origin,
    LatLng destination,
  ) async {
    final originString = "${origin.latitude}, ${origin.longitude}";
    final destinationString =
        "${destination.latitude}, ${destination.longitude}";
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$originString&destinations=$destinationString&key=<YOUR_APIKEY>',
    );
    final response = await http.get(url);
    print('response: $response');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print(response.body.toString());
      print(
        "Tempo estimado da rota: ${json['rows'][0]['elements'][0]['duration']['text']}",
      );
      return TimeModel(
        time: json['rows'][0]['elements'][0]['duration']['text'],
        distance: json['rows'][0]['elements'][0]['distance']['text'],
      );
    } else {
      print('Erro ao obter a duração da rota: ${response.statusCode}');
    }
  }
}

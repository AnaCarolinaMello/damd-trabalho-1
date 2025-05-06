import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/views/map/components/Driver.dart';
import 'package:damd_trabalho_1/views/map/components/MapPOI.dart';
import 'package:damd_trabalho_1/views/map/components/MapAction.dart';

class Tracking extends StatefulWidget {
  const Tracking({super.key});

  @override
  State<Tracking> createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> {
  bool isDarkMode = false;

  // Dados simulados do motorista
  final Map<String, dynamic> driver = {
    'name': 'Carlos',
    'rating': 4.92,
    'arrivalTime': 8,
    'vehicle': 'Fiat Argo',
    'vehicleColor': 'Prata',
    'licensePlate': 'ABC1D23',
    'trips': 5827,
  };

  // Informações da viagem
  final String pickupPoint = 'Ponto de encontro: Shopping Center';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Acompanhe seu pedido',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Mapa (simulando com uma cor de fundo)
          Container(
            color: isDarkMode ? Tokens.neutral800 : Tokens.neutral200,
            height: double.infinity,
            width: double.infinity,
            // Simulando pontos de referência no mapa
            child: Stack(
              children: [
                // Desenho simulado de estrada
                Positioned(
                  top: 150,
                  left: MediaQuery.of(context).size.width / 2 - 2,
                  child: Container(
                    width: 4,
                    height: 400,
                    color: isDarkMode ? Tokens.neutral200 : Tokens.neutral800,
                  ),
                ),

                // Pontos de referência no mapa
                Positioned(
                  top: 220,
                  left: MediaQuery.of(context).size.width / 2 - 100,
                  child: MapPOI(
                    label: 'Restaurante',
                    icon: Icons.restaurant,
                  ),
                ),

                Positioned(
                  top: 320,
                  left: MediaQuery.of(context).size.width / 2 + 60,
                  child: MapPOI(
                    label: 'Farmácia',
                    icon: Icons.local_pharmacy,
                  ),
                ),

                // Carro (ponto de motorista)
                Positioned(
                  top: 450,
                  left: MediaQuery.of(context).size.width / 2 - 15,
                  child: Container(
                    width: Tokens.spacing36,
                    height: Tokens.spacing36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(Tokens.radius16),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: Tokens.borderSize2,
                      ),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      color: theme.colorScheme.primary,
                      size: Tokens.fontSize20,
                    ),
                  ),
                ),

                // Controles do mapa
                Positioned(
                  right: 16,
                  bottom: MediaQuery.of(context).size.height * 0.4,
                  child: MapAction(
                    icon: Icons.center_focus_strong,
                    isActive: true,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),

          // Card inferior com detalhes do motorista
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Driver(driver: driver),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';

class Driver extends StatelessWidget {
  final Map<String, dynamic> driver;

  const Driver({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Informação do ponto de encontro
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: Tokens.spacing20,
            vertical: Tokens.spacing16,
          ),
          color: theme.colorScheme.surface,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${driver["name"]} está a caminho',
                      style: TextStyle(
                        fontSize: Tokens.fontSize20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(Tokens.spacing12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(Tokens.radius4),
                ),
                child: Column(
                  children: [
                    Text(
                      driver['arrivalTime'].toString(),
                      style: const TextStyle(
                        fontSize: Tokens.fontSize20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'min',
                      style: TextStyle(
                        fontSize: Tokens.fontSize12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          color: theme.colorScheme.surface,
          padding: const EdgeInsets.all(Tokens.spacing16),
          child: Column(
            children: [
              Row(
                children: [
                  // Foto do motorista
                  Container(
                    width: Tokens.spacing64,
                    height: Tokens.spacing64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primaryContainer,
                    ),
                    child: Icon(
                      Icons.person,
                      size: Tokens.spacing40,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: Tokens.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              driver['rating'].toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Tokens.fontSize16,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: Tokens.spacing4),
                            const Icon(
                              Icons.star,
                              size: Tokens.fontSize16,
                              color: Colors.amber,
                            ),
                          ],
                        ),
                        const SizedBox(height: Tokens.spacing4),
                        Text(
                          '${driver["vehicleColor"]} ${driver["vehicle"]}',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: Tokens.fontSize14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Tokens.spacing8,
                      vertical: Tokens.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(Tokens.radius4),
                    ),
                    child: Text(
                      driver['licensePlate'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Tokens.fontSize16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Tokens.spacing16),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: Tokens.fontSize20,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: Tokens.spacing8),
                  Text(
                    driver['name'],
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: Tokens.fontSize16,
                    ),
                  ),
                  const SizedBox(width: Tokens.spacing8),
                  Text(
                    '• ${driver["trips"]} entregas',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: Tokens.fontSize14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Tokens.spacing16),
              // Campo de notas
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Tokens.spacing16,
                  vertical: Tokens.spacing12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(Tokens.radius24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Alguma observação para a entrega?',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Container(
                      width: Tokens.spacing40,
                      height: Tokens.spacing40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.surface,
                      ),
                      child: Icon(
                        Icons.phone,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: Tokens.spacing8),
                    Container(
                      width: Tokens.spacing40,
                      height: Tokens.spacing40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.surface,
                      ),
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Tokens.spacing16),
            ],
          ),
        ),
      ],
    );
  }
}

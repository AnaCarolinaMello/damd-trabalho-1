import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/Address.dart';

class AddressComponent extends StatelessWidget {
  final Address address;
  const AddressComponent({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(Tokens.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Endereço de Entrega',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Tokens.fontSize16,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: Tokens.spacing8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: Tokens.spacing8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.shortAddress,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: Tokens.fontSize14,
                      ),
                    ),
                    const SizedBox(height: Tokens.borderSize2),
                    Text(
                      address.cityState,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: Tokens.fontSize14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
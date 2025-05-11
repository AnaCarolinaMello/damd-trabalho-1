import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/components/IconButton.dart';
import 'package:damd_trabalho_1/views/map/pages/Tracking.dart';
import 'package:damd_trabalho_1/models/enum/Status.dart';

class SeeMap extends StatelessWidget {
  final Status status;
  final bool noPadding;

  const SeeMap({
    super.key,
    required this.status,
    this.noPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    if (status == Status.accepted) {
      return Column(
        children: [
          if (!noPadding) const SizedBox(height: Tokens.spacing24),
          SizedBox(
            width: double.infinity,
            child: CustomIconButton(
              icon: Icons.location_on,
              label: 'Acompanhe seu pedido',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Tracking()),
                );
              },
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
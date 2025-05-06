import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';

class Rating extends StatefulWidget {
  final Function() orderAgain;

  const Rating({super.key, required this.orderAgain});

  @override
  State<Rating> createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Tokens.spacing16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            widget.orderAgain();
          },
          icon: const Icon(Icons.replay_outlined),
          label: const Text('Pedir Novamente'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: Tokens.spacing16),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/components/Button.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/controllers/order.dart';
class Rate extends StatefulWidget {
  final Function(double) rateOrder;

  const Rate({
    super.key,
    required this.rateOrder,
  });

  @override
  State<Rate> createState() => _RateState();
}

class _RateState extends State<Rate> {
  double _rating = 0;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Tokens.spacing16),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Como foi sua experiência?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Tokens.fontSize16,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: Tokens.spacing12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => IconButton(
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                ),
                color: Colors.amber,
                iconSize: Tokens.fontSize32,
              ),
            ),
          ),
          const SizedBox(height: Tokens.spacing16),
          Button(
            text: 'Enviar Avaliação',
            loading: isLoading,
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              await widget.rateOrder(_rating);
              setState(() {
                isLoading = false;
              });
            },
          ),
        ],
      ),
    );
  }
}
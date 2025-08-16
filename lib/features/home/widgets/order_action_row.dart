import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class OrderActionRow extends StatelessWidget {
  final String? textAbove;
  final List<Widget> actions;

  const OrderActionRow({super.key, this.textAbove, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (textAbove != null)
          Text(textAbove!,
              style: robotoRegular.copyWith(
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.underline,
                  decorationColor: Theme.of(context).primaryColor)),
        if (textAbove != null) const SizedBox(height: 8),
        Row(children: actions),
      ],
    );
  }
}

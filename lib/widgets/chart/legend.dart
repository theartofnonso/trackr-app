import 'package:flutter/material.dart';

class Legend extends StatelessWidget {
  final Color color;
  final String title;
  final String suffix;
  final String subTitle;

  const Legend({
    super.key,
    required this.color,
    required this.title,
    required this.suffix,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              child: RichText(
                text: TextSpan(
                  text: title,
                  style: Theme.of(context).textTheme.bodySmall,
                  children: <TextSpan>[
                    TextSpan(
                      text: suffix,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(subTitle.toUpperCase(), style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

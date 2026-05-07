import 'package:flutter/material.dart';

class BeerPaintHint extends StatelessWidget {
  const BeerPaintHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline,
              size: 18,
              color: Colors.black54,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Svisle = piva, vodorovně = panáky',
              style: TextStyle(
                fontSize: 13,
                height: 1.25,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
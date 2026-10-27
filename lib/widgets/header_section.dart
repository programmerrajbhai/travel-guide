
import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.location_on, size: 16),
                SizedBox(width: 4),
                Text('Albany, New York', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Icon(Icons.keyboard_arrow_down, size: 16),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Assalamu Alaikum,', style: TextStyle(fontSize: 14, color: Colors.black87)),
            const Text('Syed Ahmed', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('May Allah bless your day', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)],
              ),
              child: Row(
                children: const [
                  Icon(Icons.wb_sunny, color: Colors.orange, size: 16),
                  SizedBox(width: 4),
                  Text('78°F\nSunny', style: TextStyle(fontSize: 10, height: 1.2), textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child: const Icon(Icons.notifications_none, size: 20),
                ),
                Positioned(
                  right: 0,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            )
          ],
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../models/achievement.dart';

class AchievementMenu extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementMenu({super.key, required this.achievements});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return Card(
            elevation: 2,
            color: achievement.isUnlocked ? achievement.color.withOpacity(0.2) : null,
            child: ListTile(
              leading: Icon(
                achievement.icon,
                color: achievement.isUnlocked ? achievement.color : Colors.grey,
                size: 40,
              ),
              title: Text(
                achievement.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: achievement.isUnlocked ? Colors.black : Colors.grey[600],
                ),
              ),
              subtitle: Text(
                achievement.description,
                style: TextStyle(
                  color: achievement.isUnlocked ? Colors.black87 : Colors.grey[600],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

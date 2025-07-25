import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AlertScreen extends StatelessWidget {
  final String currentUserRole; // مثال: "doctor" أو "nurse"
  const AlertScreen({super.key, required this.currentUserRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("alerts".tr())),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('notifications')
                .where('targetRole', isEqualTo: currentUserRole)
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No alerts".tr()));
          }

          final alerts = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final data = alerts[index].data() as Map<String, dynamic>;
              return _buildAlertItem(
                name: data['name'] ?? 'Unknown',
                valuesData: data['valuesData'] ?? '',
                time: _formatTime(data['timestamp']),
                risk: data['risk'] ?? 'stable',
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min";
    if (diff.inHours < 24) return "${diff.inHours} h";
    return "Yesterday";
  }

  Widget _buildAlertItem({
    required String name,
    required String valuesData,
    required String time,
    required String risk,
  }) {
    Color bgColor;
    Color textColor;

    switch (risk) {
      case "Critical Risk":
        bgColor = Colors.red;
        textColor = Colors.white;
        break;
      case "Moderate Risk":
        bgColor = Colors.orange;
        textColor = Colors.white;
        break;
      case "Stable":
        bgColor = Colors.green;
        textColor = Colors.white;
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.black;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: .5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    risk.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

              Text(
                "$valuesData ",
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                "• $time ${"ago".tr()}",
                style: const TextStyle(fontSize: 15,color: Colors.grey),
              ),

        ],
      ),
    );
  }
}

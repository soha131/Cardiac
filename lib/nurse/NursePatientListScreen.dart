import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'NurseEntryScreen.dart';
import 'package:easy_localization/easy_localization.dart';

class NursePatientListScreen extends StatelessWidget {
  const NursePatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Patients".tr(), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).bottomAppBarTheme.color ?? Theme.of(context).primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.dashboard, color: Theme.of(context).iconTheme.color),
              onPressed: () => Navigator.pushNamed(context, '/nurse_home'),
            ),
            IconButton(
              icon: Icon(Icons.people_sharp, color: Theme.of(context).iconTheme.color),
              onPressed: () => Navigator.pushNamed(context, '/PatientList'),
            ),
            IconButton(
              icon: Icon(Icons.account_circle, color: Theme.of(context).iconTheme.color),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('patient_data').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          final filteredDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['heartRate'] == null;
          }).toList();

          if (filteredDocs.isEmpty) {
            return Center(
              child: Text(
                "No incomplete patients.".tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDocs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final data = filteredDocs[index].data() as Map<String, dynamic>;
              final docId = filteredDocs[index].id;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    width: .5,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.person, color: Colors.blue),
                  ),
                  title: Text(data['name'] ?? 'Unnamed', style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text(
                    "${"Age".tr()}: ${data['age'] ?? '--'}, ${"Gender".tr()}: ${data['gender'] ?? '--'}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NurseEntryScreen(
                          patientId: docId,
                          patientData: data,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

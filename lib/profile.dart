import 'package:cardiac_app/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("user_data_not_found".tr()));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text("settings_profile".tr(), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: const NetworkImage('https://via.placeholder.com/100'),
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Text(
                        userData['name'] ?? 'No Name',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        userData['role'] ?? 'Unknown Role',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Text(
                        userData['email'] ?? '',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text("notification_preferences".tr(), style: const TextStyle(fontSize: 18)),

                SwitchListTile(
                  activeColor: Colors.blue[600],
                  title: Text("push_notifications".tr()),
                  value: true,
                  onChanged: (val) {},
                ),
                SwitchListTile(
                  activeColor: Colors.blue[600],
                  title: Text("sms_notifications".tr()),
                  value: false,
                  onChanged: (val) {},
                ),
                const SizedBox(height: 10),
                Text("language".tr(), style: const TextStyle(fontSize: 18)),
                ListTile(
                  title: Text("change_language".tr()),
                  trailing: const Icon(Icons.language),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("select_language".tr()),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text("English"),
                              onTap: () {
                                context.setLocale(const Locale('en'));
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text("العربية"),
                              onTap: () {
                                context.setLocale(const Locale('ar'));
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text("dark_mode".tr(), style: const TextStyle(fontSize: 18)),
                SwitchListTile(
                  activeColor: Colors.blue[600],
                  title: Text("dark_mode".tr()),
                  value: context.watch<ThemeProvider>().isDarkMode,
                  onChanged: (val) {
                    context.read<ThemeProvider>().toggleTheme(val);
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      padding: const EdgeInsets.symmetric(horizontal: 82, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    },
                    child: Text("log_out".tr(), style: const TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

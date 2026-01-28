import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Providers/auth_service_provider.dart';
import '../../Providers/inventory_provider.dart';
import '../../Providers/invoice_history_provider.dart';
import '../../Providers/invoice_provider.dart';
import '../../Providers/theme_mode_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && systemBrightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Toggle card
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Dark Theme'),
                    Switch(
                      value: isDarkMode,
                      onChanged: (_) {
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: (){
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: Text('Logout'),
                      content: Text('Are you sure you want to logout?'),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('No'),
                        ),
                        SizedBox(height: 10,),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await ref.read(authServiceProvider).signOut();
                            ref.read(themeModeProvider.notifier).resetTheme();
                            ref.invalidate(invoiceProvider);
                            ref.invalidate(invoiceHistoryProvider);
                            ref.invalidate(inventoryProvider);
                            ref.invalidate(totalSalesProvider);
                          },
                          child: Text('Yes'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Log out'),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.logout,size: 25,),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.construction, size: 80, color: Colors.grey),
                    SizedBox(height: 20),
                    Text(
                      'Settings under construction 🚧',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'More features coming soon — stay tuned!\nIn the meantime, feel free to toggle between light and dark themes above.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

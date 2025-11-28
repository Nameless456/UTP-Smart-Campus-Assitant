import 'package:flutter/material.dart';
import 'package:flutter_gemini/constant.dart';
import 'package:flutter_gemini/hive/settings.dart';
import 'package:flutter_gemini/hive/user_model.dart';
import 'package:flutter_gemini/providers/theme_provider.dart';
import 'package:flutter_gemini/providers/chat_provider.dart';
import 'package:flutter_gemini/providers/language_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(languageProvider.getText('profile')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            _showEditProfileDialog(context);
                          },
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<Box<UserModel>>(
                        valueListenable: Hive.box<UserModel>(
                          Constant.userBox,
                        ).listenable(),
                        builder: (context, box, _) {
                          final user = box.isEmpty ? null : box.getAt(0);
                          return Column(
                            children: [
                              Text(
                                user?.name ?? 'UTP Student',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.major ?? 'General Studies',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? 'student@utp.edu.my',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Settings Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageProvider.getText('appearance'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              themeProvider.isDarkMode
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          title: Text(languageProvider.getText('dark_mode')),
                          subtitle: Text(
                            themeProvider.isDarkMode ? 'Enabled' : 'Disabled',
                          ),
                          trailing: Switch(
                            value: themeProvider.isDarkMode,
                            onChanged: (value) async {
                              await themeProvider.toggleTheme();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    languageProvider.getText('preferences'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        Consumer<LanguageProvider>(
                          builder: (context, languageProvider, child) {
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.language,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              title: Text(languageProvider.getText('language')),
                              subtitle: Text(
                                languageProvider.isMalay
                                    ? 'Bahasa Melayu'
                                    : 'English',
                              ),
                              trailing: Switch(
                                value: languageProvider.isMalay,
                                onChanged: (value) async {
                                  await languageProvider.setLanguage(
                                    value ? 'ms' : 'en',
                                  );
                                  // Update ChatProvider context to reflect language change
                                  if (context.mounted) {
                                    Provider.of<ChatProvider>(
                                      context,
                                      listen: false,
                                    ).updateUserContext();
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    languageProvider.getText('about'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          title: const Text('App Version'),
                          subtitle: const Text('1.0.0'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.code,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          title: const Text('Powered by'),
                          subtitle: const Text('Google Gemini AI'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditProfileDialog(BuildContext context) async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final box = Hive.box<UserModel>(Constant.userBox);
    final user = box.isEmpty ? null : box.getAt(0);

    final nameController = TextEditingController(text: user?.name ?? '');
    final majorController = TextEditingController(text: user?.major ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageProvider.getText('edit_profile')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: languageProvider.getText('name'),
                hintText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: majorController,
              decoration: InputDecoration(
                labelText: languageProvider.getText('major'),
                hintText: 'e.g. Computer Science',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(languageProvider.getText('cancel')),
          ),
          FilledButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              final newMajor = majorController.text.trim();

              if (newName.isNotEmpty) {
                final newUser = UserModel(
                  uid: user?.uid ?? 'user_1',
                  name: newName,
                  image: user?.image ?? '',
                  email: user?.email ?? 'student@utp.edu.my',
                  major: newMajor,
                );

                if (box.isEmpty) {
                  await box.add(newUser);
                } else {
                  await box.putAt(0, newUser);
                }

                if (context.mounted) {
                  // Update ChatProvider context
                  Provider.of<ChatProvider>(
                    context,
                    listen: false,
                  ).updateUserContext();
                  Navigator.pop(context);
                }
              }
            },
            child: Text(languageProvider.getText('save')),
          ),
        ],
      ),
    );
  }
}

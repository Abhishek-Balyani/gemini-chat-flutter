import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // SECTION: Appearance
              _buildSectionHeader(context, 'Appearance'),
              Card(
                child: Column(
                  children: [
                    Obx(
                      () => ListTile(
                        leading: const Icon(Icons.palette_outlined),
                        title: const Text('Theme Mode'),
                        subtitle: Text(
                          controller.themeService.themeModeString.value.capitalizeFirst ?? '',
                        ),
                        trailing: DropdownButton<String>(
                          value: controller.themeService.themeModeString.value,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'dark', child: Text('Dark Mode')),
                            DropdownMenuItem(value: 'light', child: Text('Light Mode')),
                            DropdownMenuItem(value: 'system', child: Text('System Mode')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              controller.themeService.setThemeModeString(val);
                            }
                          },
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Obx(
                      () => ListTile(
                        leading: const Icon(Icons.format_size_rounded),
                        title: const Text('Font Size'),
                        subtitle: Text(
                          controller.themeService.fontSizeScale.value == 0.85
                              ? 'Small'
                              : controller.themeService.fontSizeScale.value == 1.15
                                  ? 'Large'
                                  : 'Medium (Default)',
                        ),
                        trailing: DropdownButton<double>(
                          value: controller.themeService.fontSizeScale.value,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 0.85, child: Text('Small')),
                            DropdownMenuItem(value: 1.0, child: Text('Medium')),
                            DropdownMenuItem(value: 1.15, child: Text('Large')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              controller.themeService.setFontSizeScale(val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SECTION: AI Configuration
              _buildSectionHeader(context, 'AI Model & Configuration'),
              Card(
                child: Column(
                  children: [
                    Obx(
                      () => ListTile(
                        leading: const Icon(Icons.auto_awesome_outlined),
                        title: const Text('Gemini Model'),
                        subtitle: Text(controller.selectedModel.value),
                        trailing: DropdownButton<String>(
                          value: controller.selectedModel.value,
                          underline: const SizedBox(),
                          items: AppStrings.availableModels
                              .map(
                                (m) => DropdownMenuItem(value: m, child: Text(m)),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              controller.updateSelectedModel(val);
                            }
                          },
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.key_outlined),
                      title: const Text('Gemini API Key'),
                      subtitle: const Text('Custom API Key (Optional)'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showApiKeyDialog(context),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SECTION: Data Management
              _buildSectionHeader(context, 'Data & Storage'),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.delete_forever_outlined, color: AppColors.error),
                  title: const Text(
                    'Clear All History',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Delete all saved conversations and settings'),
                  onTap: () => controller.clearAllHistory(),
                ),
              ),

              const SizedBox(height: 24),

              // SECTION: About & Legal
              _buildSectionHeader(context, 'About & Legal'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded),
                      title: const Text('About App'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => controller.showAboutDialog(),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => controller.showPrivacyPolicy(),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('Terms of Service'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => controller.showTermsOfService(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Gemini API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your personal Google Gemini API Key. If left blank, the default built-in key will be used.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.apiKeyController,
              decoration: const InputDecoration(
                hintText: 'AIzaSy...',
                labelText: 'API Key',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateApiKey(controller.apiKeyController.text);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Key'),
          ),
        ],
      ),
    );
  }
}

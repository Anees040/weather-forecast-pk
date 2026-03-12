import 'package:flutter/material.dart';
import 'package:weather_forecast_pk/core/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  final AppThemeProvider themeProvider;

  const SettingsScreen({Key? key, required this.themeProvider}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppThemeProvider get tp => widget.themeProvider;

  @override
  Widget build(BuildContext context) {
    final isDark = tp.isDark(context);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.white.withAlpha(140) : const Color(0xFF6A6A7A);
    final cardColor = isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(8);
    final bgColor = isDark ? const Color(0xFF121218) : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // Theme Mode Section
          _sectionHeader('Appearance', textColor),
          const SizedBox(height: 8),
          _buildThemeModeCard(isDark, textColor, subColor, cardColor),
          const SizedBox(height: 16),

          // Accent Color Section
          _sectionHeader('Accent Color', textColor),
          const SizedBox(height: 8),
          _buildAccentColorCard(isDark, textColor, subColor, cardColor),
          const SizedBox(height: 16),

          // Font Scale Section
          _sectionHeader('Text Size', textColor),
          const SizedBox(height: 8),
          _buildFontScaleCard(isDark, textColor, subColor, cardColor),
          const SizedBox(height: 16),

          // Animations Section
          _sectionHeader('Animations', textColor),
          const SizedBox(height: 8),
          _buildAnimationsCard(isDark, textColor, subColor, cardColor),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        color: tp.accent,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildThemeModeCard(bool isDark, Color textColor, Color subColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _themeTile(
            icon: Icons.light_mode_outlined,
            label: 'Light',
            isSelected: tp.themeMode == AppThemeMode.light,
            isDark: isDark,
            textColor: textColor,
            subColor: subColor,
            onTap: () async {
              await tp.setThemeMode(AppThemeMode.light);
              setState(() {});
            },
          ),
          Divider(color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(10)),
          _themeTile(
            icon: Icons.dark_mode_outlined,
            label: 'Dark',
            isSelected: tp.themeMode == AppThemeMode.dark,
            isDark: isDark,
            textColor: textColor,
            subColor: subColor,
            onTap: () async {
              await tp.setThemeMode(AppThemeMode.dark);
              setState(() {});
            },
          ),
          Divider(color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(10)),
          _themeTile(
            icon: Icons.settings_brightness_outlined,
            label: 'System',
            isSelected: tp.themeMode == AppThemeMode.system,
            isDark: isDark,
            textColor: textColor,
            subColor: subColor,
            onTap: () async {
              await tp.setThemeMode(AppThemeMode.system);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _themeTile({
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isDark,
    required Color textColor,
    required Color subColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? tp.accent : subColor, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? textColor : subColor,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: tp.accent, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAccentColorCard(bool isDark, Color textColor, Color subColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(AppThemeProvider.accentColors.length, (i) {
          final color = AppThemeProvider.accentColors[i];
          final isSelected = tp.accentColorIndex == i;
          return GestureDetector(
            onTap: () async {
              await tp.setAccentColor(i);
              setState(() {});
            },
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: textColor, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withAlpha(80), blurRadius: 8, spreadRadius: 2)]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: _contrastColor(color), size: 20)
                      : null,
                ),
                const SizedBox(height: 4),
                Text(
                  AppThemeProvider.accentColorNames[i],
                  style: TextStyle(
                    color: isSelected ? textColor : subColor,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Color _contrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Widget _buildFontScaleCard(bool isDark, Color textColor, Color subColor, Color cardColor) {
    final scaleLabels = {0.85: 'Small', 1.0: 'Default', 1.15: 'Large', 1.3: 'Extra Large'};
    final currentLabel = scaleLabels.entries
        .reduce((a, b) => (tp.fontScale - a.key).abs() < (tp.fontScale - b.key).abs() ? a : b)
        .value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Aa', style: TextStyle(color: subColor, fontSize: 13)),
              Text(currentLabel, style: TextStyle(color: tp.accent, fontSize: 13, fontWeight: FontWeight.w600)),
              Text('Aa', style: TextStyle(color: subColor, fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: tp.accent,
              inactiveTrackColor: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(20),
              thumbColor: tp.accent,
              overlayColor: tp.accent.withAlpha(30),
              trackHeight: 4,
            ),
            child: Slider(
              value: tp.fontScale,
              min: 0.85,
              max: 1.3,
              divisions: 3,
              onChanged: (val) async {
                await tp.setFontScale(val);
                setState(() {});
              },
            ),
          ),
          Text(
            'Preview text at current size',
            style: TextStyle(
              color: textColor,
              fontSize: 14 * tp.fontScale,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationsCard(bool isDark, Color textColor, Color subColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.animation, color: subColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Enable animations',
              style: TextStyle(color: textColor, fontSize: 15),
            ),
          ),
          Switch(
            value: tp.useAnimations,
            activeThumbColor: tp.accent,
            onChanged: (val) async {
              await tp.setUseAnimations(val);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}

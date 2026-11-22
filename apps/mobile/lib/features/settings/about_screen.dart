import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../../l10n/app_localizations.dart';
import 'app_info.dart';
import 'font_licenses.dart';
import 'widgets/settings_page.dart';
import 'widgets/settings_panel.dart';

/// Экран «О приложении»: версия, примечание о шрифтах, лицензии (стандартная
/// страница `showLicensePage`, куда добавлены OFL-тексты Oswald и JetBrains
/// Mono). Открывается через `Navigator.push` из настроек.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    registerFontLicenses(DefaultAssetBundle.of(context));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsPage(
      title: l10n.aboutTitle,
      children: [
        SettingsPanel(
          heading: l10n.appName,
          children: [
            Text(
              l10n.aboutVersion(appVersion),
              style: TmbType.dataMono.copyWith(color: TmbColor.textPrimary),
            ),
            const SizedBox(height: TmbSpace.x3),
            Text(
              l10n.aboutDescription,
              style: TmbType.bodyMd.copyWith(color: TmbColor.textPrimary),
            ),
            const SizedBox(height: TmbSpace.x3),
            Text(
              l10n.aboutNotMedical,
              style: TmbType.bodySm.copyWith(color: TmbColor.textSecondary),
            ),
          ],
        ),
        SettingsPanel(
          heading: l10n.aboutLicenses,
          children: [
            Text(
              l10n.aboutFonts,
              style: TmbType.bodySm.copyWith(color: TmbColor.textSecondary),
            ),
            const SizedBox(height: TmbSpace.x3),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: () => showLicensePage(
                  context: context,
                  applicationName: l10n.appName,
                  applicationVersion: appVersion,
                ),
                child: Text(l10n.aboutLicenses.toUpperCase()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

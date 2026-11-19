/// Design tokens — сгенерированы из Figma-файла «Tactical Mind & Body — Design System».
/// https://www.figma.com/design/Qc9XP8kvfDMtPwMLCZABkA
///
/// Источник правды — Figma. Правки вносить там, потом обновлять этот файл.
library;

import 'package:material_ui/material_ui.dart';

/// Цвет. Приложение тёмное по замыслу — светлой темы не будет.
/// Режим `Daylight` (повышенный контраст для яркого солнца) — кандидат на будущее,
/// поэтому имена токенов уже не привязаны к «тёмному».
abstract final class TmbColor {
  // Графит — поверхности
  static const void_ = Color(0xFF05070A); // фон приложения
  static const surface = Color(0xFF0B1210); // панель
  static const raised = Color(0xFF131C18); // карточка внутри панели
  static const overlay = Color(0xFF1B2622); // модалки, шторки

  // Акцент — ФИЗИЧЕСКАЯ фаза, главные действия
  static const accent100 = Color(0xFFE4FFC4);
  static const accent300 = Color(0xFFC6FF87);
  static const accent500 = Color(0xFFA6FF4D); // основной
  static const accent700 = Color(0xFF5F8F34);
  static const accent900 = Color(0xFF26401A);

  // Сигнал — КОГНИТИВНАЯ фаза
  static const signal300 = Color(0xFFFFC46B);
  static const signal500 = Color(0xFFFF8A1F); // основной
  static const signal700 = Color(0xFFB85A08);
  static const signal900 = Color(0xFF3D2005);

  // Олива — третичный, локация «Зал»
  static const olive500 = Color(0xFF8A9A5B);
  static const olive700 = Color(0xFF5A6636);

  // Статус
  static const danger = Color(0xFFFF3B3B);
  static const warning = Color(0xFFFFB000);
  static const success = Color(0xFF6BE04D);

  // Текст
  static const textPrimary = Color(0xFFD8F5D8);
  static const textSecondary = Color(0xFF7A9A7A);
  static const textMuted = Color(0xFF4A5F4A);
  static const textInverse = Color(0xFF04250A); // поверх accent500 / signal500

  // Рамки
  static const borderSubtle = Color(0xFF1E2E22);
  static const borderDefault = Color(0xFF2E4432);
  static const borderAccent = Color(0xFF5F8F34);
}

/// Отступы — сетка 4 px.
abstract final class TmbSpace {
  static const x1 = 4.0;
  static const x2 = 8.0;
  static const x3 = 12.0;
  static const x4 = 16.0; // базовый: паддинг панелей и поля экрана
  static const x5 = 20.0;
  static const x6 = 24.0;
  static const x8 = 32.0;
  static const x12 = 48.0;
}

/// Скругления. По умолчанию почти острый угол — техника, а не игрушка.
abstract final class TmbRadius {
  static const sharp = 2.0;
  static const sm = 4.0;
  static const md = 8.0;
  static const pill = 999.0;
}

/// Шрифты.
///
/// ВАЖНО: обе гарнитуры выбраны в том числе за полную поддержку КИРИЛЛИЦЫ.
/// Более «тактические» на вид Chakra Petch, Rajdhani, Barlow Condensed и
/// Saira Condensed кириллицы НЕ содержат — при них русский и украинский текст
/// молча уедет в системный фолбэк. Не подставлять их не проверив.
abstract final class TmbFont {
  /// Заголовки, звания, кнопки. Узкий гротеск, всегда КАПСОМ.
  static const display = 'Oswald';

  /// Данные, таймеры, условия задач, терминальные строки.
  static const mono = 'JetBrains Mono';
}

/// Типографическая шкала. Имена совпадают с текстовыми стилями в Figma.
abstract final class TmbType {
  static const displayHero = TextStyle(
    fontFamily: TmbFont.display,
    fontWeight: FontWeight.w700,
    fontSize: 32,
    height: 1.10,
    letterSpacing: 0.64,
  );
  static const displayLg = TextStyle(
    fontFamily: TmbFont.display,
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 1.15,
    letterSpacing: 0.48,
  );
  static const displayMd = TextStyle(
    fontFamily: TmbFont.display,
    fontWeight: FontWeight.w500,
    fontSize: 18,
    height: 1.20,
    letterSpacing: 0.54,
  );

  /// Главный таймер. Должен читаться с нескольких метров.
  static const dataTimer = TextStyle(
    fontFamily: TmbFont.mono,
    fontWeight: FontWeight.w700,
    fontSize: 56,
    height: 1.00,
    letterSpacing: 1.12,
  );
  static const dataMetric = TextStyle(
    fontFamily: TmbFont.mono,
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 1.10,
  );
  static const dataMono = TextStyle(
    fontFamily: TmbFont.mono,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.40,
    letterSpacing: 0.56,
  );

  static const bodyLg = TextStyle(
    fontFamily: TmbFont.mono,
    fontSize: 16,
    height: 1.50,
  );
  static const bodyMd = TextStyle(
    fontFamily: TmbFont.mono,
    fontSize: 14,
    height: 1.50,
  );
  static const bodySm = TextStyle(
    fontFamily: TmbFont.mono,
    fontSize: 12,
    height: 1.45,
  );

  // Метки — всегда uppercase, широкий трекинг. Регистр задавать в UI
  // (`text.toUpperCase()`), а не хранить в строках локализации.
  static const labelLg = TextStyle(
    fontFamily: TmbFont.display,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.0,
    letterSpacing: 1.28,
  );
  static const labelMd = TextStyle(
    fontFamily: TmbFont.display,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    height: 1.0,
    letterSpacing: 1.30,
  );
  static const labelSm = TextStyle(
    fontFamily: TmbFont.display,
    fontWeight: FontWeight.w500,
    fontSize: 11,
    height: 1.0,
    letterSpacing: 1.32,
  );
}

/// Фаза сессии определяет акцентный цвет всего экрана.
/// Это не украшение — переключение цвета сообщает телу, что режим сменился
/// с физического на мыслительный.
enum TmbPhase {
  physical(TmbColor.accent500, TmbColor.accent900, TmbColor.borderAccent),
  cognitive(TmbColor.signal500, TmbColor.signal900, TmbColor.signal700);

  const TmbPhase(this.accent, this.surface, this.border);

  final Color accent;
  final Color surface;
  final Color border;
}

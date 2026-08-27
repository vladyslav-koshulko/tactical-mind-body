# TACTICAL MIND & BODY — Dual-Task Training App

Автономное мобильное приложение для психофизического тренинга по методу
Dual-Task: физическая нагрузка (калистеника) + когнитивная задача в перерывах
между кругами. Работает полностью офлайн, без бэкенда.

## Структура проекта

```
tactical-mind-body/
├── www/index.html          ← всё приложение: HTML+CSS+JS в одном файле
├── android/                ← нативный Android-проект (Capacitor)
├── capacitor.config.ts     ← конфигурация Capacitor
├── package.json
└── .github/workflows/build-apk.yml   ← автосборка APK в облаке
```

## Быстрая проверка (без сборки)

Просто откройте `www/index.html` в любом браузере на телефоне или ПК —
приложение полностью рабочее (localStorage, таймеры, вся логика).

## Настройка повторений

В приложении есть экран **«Настройки»** (кнопка на главном экране):

- **Фиксированный режим** — одно и то же число повторений для всех
  упражнений в круге (например, 5).
- **Диапазон** — для каждого упражнения число повторений выбирается
  случайно в заданных границах (например, от 5 до 10).

Там же настраиваются: количество кругов (по умолчанию 5), длительность
брифинга (30 сек) и длительность когнитивной паузы (3 мин).

## Как получить .apk

### Вариант 1 — GitHub Actions (рекомендуется, не нужен Android Studio)

1. Создайте пустой репозиторий на GitHub и запушьте туда содержимое этого
   архива:
   ```bash
   git init
   git add .
   git commit -m "Tactical Mind & Body"
   git branch -M main
   git remote add origin https://github.com/<ваш_аккаунт>/tactical-mind-body.git
   git push -u origin main
   ```
2. Откройте вкладку **Actions** в репозитории — сборка запустится
   автоматически (workflow `Build Android APK`).
3. Через 3–5 минут в разделе **Artifacts** появится файл
   `tactical-mind-body-debug-apk` — это и есть готовый `.apk` для установки.

Это debug-сборка (для установки на свои устройства). Для публикации в
Google Play потребуется release-сборка с подписью — см. вариант 2.

### Вариант 2 — Android Studio (для release-сборки и публикации в Play)

1. Установите [Android Studio](https://developer.android.com/studio).
2. Откройте папку `android/` как проект.
3. Дайте Gradle синхронизироваться (Studio сама подтянет нужный SDK).
4. `Build → Generate Signed Bundle / APK` → создайте keystore → выберите
   `APK` или `Android App Bundle` (AAB нужен для Google Play).
5. Готовый файл появится в `android/app/release/`.

### Вариант 3 — командная строка (если Android SDK уже установлен локально)

```bash
npm install
npx cap sync android
cd android
./gradlew assembleDebug
```
APK появится в `android/app/build/outputs/apk/debug/app-debug.apk`.

> Собрать APK прямо в этой сессии с Claude было невозможно: песочница не
> имеет доступа к серверам Google (Android SDK, Google Maven) и
> services.gradle.org — только к npm/GitHub/PyPI. Поэтому в архив включён
> готовый проект + вариант 1 (GitHub Actions), который решает это без
> локальной установки Android Studio.

## Публикация в Google Play

Для Google Play обязательно нужен **подписанный AAB** (не APK) и аккаунт
разработчика ($25 разово). Кратко:
1. Сгенерируйте keystore: `keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias tmb`
2. Пропишите подпись в `android/app/build.gradle` (`signingConfigs`).
3. Соберите `./gradlew bundleRelease` → файл `.aab` в `app/build/outputs/bundle/release/`.
4. Загрузите `.aab` в [Play Console](https://play.google.com/console).

Иконки и splash-screen пока стандартные от Capacitor — замените
`android/app/src/main/res/mipmap-*` своими перед публикацией.

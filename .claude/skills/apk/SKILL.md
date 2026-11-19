---
name: apk
description: Собрать APK и выдать ссылку на установку на телефон. Используй, когда просят сборку, «дай APK», «собери приложение», «проверь на телефоне», или когда нужно узнать статус последней сборки в CI.
---

# Сборка APK

Пользователь ставит приложение на реальный телефон. Ему нужна **ссылка, скачиваемая
без логина в GitHub** — artifact-ссылки не подходят, их на телефоне не открыть.

## Быстрый путь — просто дать актуальную сборку

В большинстве случаев ничего собирать не надо: CI уже собрал последний `main`.

```
https://github.com/vladyslav-koshulko/tactical-mind-body/releases/latest/download/tactical-mind-body-debug.apk
```

Эта ссылка постоянна и всегда указывает на свежайшую сборку `main`.

Проверить, что там действительно свежее, и не упала ли сборка:

```bash
gh run list --repo vladyslav-koshulko/tactical-mind-body --limit 3
gh release list --repo vladyslav-koshulko/tactical-mind-body --limit 3
```

Если последний прогон красный — покажи причину (`gh run view <id> --log-failed`)
и скажи прямо, что по ссылке лежит **предыдущая** удачная сборка, а не текущий код.

## Если нужна сборка из незакоммиченных изменений

CI собирает только то, что запушено. Локальная сборка:

```bash
npm install
npx cap sync android          # обязательно: генерирует то, чего нет в репозитории
cd android && ./gradlew assembleDebug
# → android/app/build/outputs/apk/debug/app-debug.apk
```

Требует JDK 17 и Android SDK. Если их нет — не делай вид, что собрал: скажи, чего
не хватает, и предложи запушить ветку, чтобы собрал CI.

## Когда проект переедет на Flutter

Команда станет `flutter build apk --debug`, а workflow
`.github/workflows/build-apk.yml` придётся переписать целиком — шаг публикации
релиза при этом **сохранить**, иначе постоянная ссылка выше умрёт.

С v0.4 (Firebase) раздача переезжает на Firebase App Distribution — это заявленное
предпочтение пользователя.

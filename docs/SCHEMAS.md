# Схемы данных v1

Единый источник правды для Dart-моделей, валидатора и импорта. Всё, что здесь не
описано, **не является частью формата**. Решения — в [ARCHITECTURE §3 и §10](ARCHITECTURE.md),
механики — в [EXTENSIBILITY](EXTENSIBILITY.md). Места, где я выбрал сам, — в разделе
[«Принятые решения»](#9-принятые-решения), их можно оспорить.

Рабочие образцы: [`uncertainty.pack.json`](../assets/content/ru/uncertainty.pack.json),
[`exercises.base.pack.json`](../assets/content/ru/exercises.base.pack.json).

## 0. Общие соглашения

- Формат — JSON (D3), UTF-8, корень — объект. UTF-8 BOM при чтении отбрасывается.
- Колонки таблиц: **Обяз.** — поле должно быть в документе. **Null** — допустимо ли
  значение `null`. Необязательное поле можно **опустить**; `null` в необязательном
  поле, не помеченном `null: да`, равносильно отсутствию и даёт `PACK_BAD_TYPE`.
- Все строки читатель приводит к Unicode **NFC** и заменяет `\r\n`/`\r` на `\n` **до**
  валидации и хеширования.
- Все строки — **plain text** (раздел 7). Поля `id`, названия, варианты ответов и
  элементы списков — однострочные: `\n` в них запрещён.
- Время событий — целое число **миллисекунд Unix-эпохи UTC**, диапазон
  `0 … 4102444800000` (2100-01-01). Локальный пояс — отдельным полем `utcOffsetMin`.
- UUID — строчный UUID v4: `^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$`.
- Идентификаторы (паттерны, ASCII, нижний регистр):

| Что | Паттерн |
|---|---|
| `pack` | `^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)*$`, длина 3…64 |
| `domain` | `^[a-z][a-z0-9_]{0,31}(\.[a-z][a-z0-9_]{0,31}){1,4}$` (2…5 сегментов) |
| `id` задачи | `^[a-z0-9][a-z0-9_.-]{2,63}$` |
| `id` упражнения | `^ex\.[a-z][a-z0-9_]{1,47}$` |
| `locale` | `^[a-z]{2}(-[A-Z]{2})?$` |
| тег (`muscleGroups`, `inventory`) | `^[a-z][a-z0-9_]{1,31}$` |

- Числа в паках: конечные, `|x| < 1e15`, не более 6 знаков после запятой (иначе
  `PACK_NUMBER_RANGE`). Это нужно для однозначного хеша (раздел 3.5).
- Семь архетипов — закрытый список: `recall`, `choice`, `ordering`, `delayed_recall`,
  `spatial`, `stream`, `verbal` (инвариант 3). Восьмой добавить нельзя.
- Уровни — закрытый список: `recruit`, `fighter`, `operator`, `spetsnaz`.

---

## 1. Пак задач v1

Файл `assets/content/<locale>/<имя>.pack.json`. Пак пишется под один язык, не
переводится (инвариант 9).

### 1.1 Заголовок

| Поле | Тип | Обяз. | Null | Ограничения |
|---|---|---|---|---|
| `schemaVersion` | int | да | нет | `1` |
| `kind` | string | да | нет | ровно `"task_pack"` |
| `pack` | string | да | нет | паттерн `pack`; уникален среди установленных паков; по соглашению оканчивается на `.<locale>` |
| `title` | string | да | нет | 1…80 |
| `locale` | string | да | нет | паттерн `locale`; для встроенного пака равен имени каталога `assets/content/<locale>/` |
| `license` | string | да | нет | 1…64, `^[A-Za-z0-9.+-]+$`: `proprietary`, `user` или SPDX-идентификатор (`CC-BY-4.0`) |
| `packSource` | string | да | нет | `builtin` \| `imported` \| `user`. **Недоверенное поле**, см. решение 10 |
| `status` | string | да | нет | `draft` \| `reviewed` \| `published`. Только отображение («не вычитано»), на логику не влияет |
| `levels` | string[] | да | нет | 1…4 уникальных значения из списка уровней |
| `categories` | object[] | да | нет | 1…100 элементов |
| `items` | object[] | да | нет | 1…2000 элементов |

Пак-уровневого `domain` **нет**: домен — у каждой задачи (решение 11).

### 1.2 Категория (`categories[]`)

| Поле | Тип | Обяз. | Null | Ограничения |
|---|---|---|---|---|
| `domain` | string | да | нет | паттерн `domain`; уникален в паке |
| `title` | string | да | нет | 1…60; название категории для экрана «Категории» |
| `description` | string | нет | нет | 1…200 |

Иерархия задаётся самим путём `domain` (D2). Объявлять промежуточные узлы
(`cog.uncertainty`) необязательно: экран строит дерево по префиксам.

### 1.3 Задача (`items[]`) — общие поля

| Поле | Тип | Обяз. | Null | Ограничения |
|---|---|---|---|---|
| `id` | string | да | нет | паттерн `id` задачи; уникален в паке |
| `domain` | string | да | нет | паттерн `domain`; **должен совпадать** с `domain` одной из `categories` |
| `archetype` | string | да | нет | один из семи |
| `verifiable` | bool | да | нет | `false` ⇔ `archetype == "verbal"` (хранится явно, решение 9) |
| `timeSec` | int | да | нет | 5…180; для `delayed_recall`/`spatial`/`stream` — лимит каждой фазы |
| `difficulty` | number | да | нет | 0…1 включительно; оценка автора, не калиброванная (EXTENSIBILITY §9) |
| `prompt` | string | да | нет | 1…1000; уникален в паке после нормализации (trim, схлопывание пробелов, нижний регистр) |

Разрешён `\n` в `prompt`, `reveal`, `memorize`, `question`. Всё остальное — однострочное.

### 1.4 Поля по архетипам

«Обяз.» = обязательно именно для этого архетипа. Поле, определённое схемой, но не
относящееся к архетипу, игнорируется с `PACK_FIELD_NOT_ALLOWED` (warning).

| Поле | Тип | `recall` | `choice` | `ordering` | `delayed_recall` | `spatial` | `stream` | `verbal` |
|---|---|---|---|---|---|---|---|---|
| `answer` | string \| number \| int \| object | **обяз.** (string\|number) | **обяз.** (int) | — | **обяз.** (string\|number) | **обяз.** (`{row,col}`) | — | — |
| `accept` | array \| `{min,max}` | опц. | — | — | опц. | — | — | — |
| `reveal` | string | опц. | опц. | опц. | опц. | опц. | опц. | **запрещено** |
| `options` | string[] | — | **обяз.** | — | — | — | — | — |
| `shuffle` | bool | — | опц. | — | — | — | — | — |
| `items` | string[] | — | — | **обяз.** | — | — | — | — |
| `memorize` | string | — | — | — | **обяз.** | — | — | — |
| `question` | string | — | — | — | **обяз.** | — | — | — |
| `delayRounds` | int | — | — | — | опц. | — | — | — |
| `showSec` | int | — | — | — | опц. | опц. | — | — |
| `grid` | object | — | — | — | — | **обяз.** | — | — |
| `objects` | object[] | — | — | — | — | опц. | — | — |
| `stimuli` | string[] | — | — | — | — | — | **обяз.** | — |
| `targets` | string[] | — | — | — | — | — | **обяз.** | — |
| `stimulusMs` | int | — | — | — | — | — | опц. | — |
| `selfCheck` | string[] | — | — | — | — | — | — | **обяз.** |
| `cues` | object[] | — | — | — | — | — | — | опц. |
| `gen` | object | зарезервировано | | | | | | |

Все поля в таблице имеют `null: нет`. Внутри задачи поле `items` (ordering) — это
**порядок шагов**, не путать с `items` пака.

#### Определения полей

- **`answer` (recall, delayed_recall)** — строка 1…200 или число. Сравнение —
  по правилу нормализации (ниже).
- **`accept`** — допуск; без него верно только `answer`.
  - массив: 1…20 уникальных значений **того же типа, что `answer`**, каждая строка 1…200.
    `answer` **обязан входить** в массив (`PACK_ANSWER_NOT_ACCEPTED`);
  - `{ "min": number, "max": number }`: только при числовом `answer`, `min ≤ max`,
    `min ≤ answer ≤ max`. Границы включительно.
  - Любая другая форма — `PACK_ACCEPT_INVALID`.
- **Нормализация ответа (recall)**: NFC → trim → схлопнуть пробельные в один пробел →
  нижний регистр → `ё`→`е`. Если вся строка — число (`^-?[0-9   ]*[0-9]([.,][0-9]+)?$`),
  пробелы удаляются, `,`→`.`, сравнение числовое. Для диапазона ввод парсится как число;
  не число — неверно.
- **`reveal`** — 1…600; показывается *после* ответа. У `verbal` его нет принципиально:
  после непроверяемой задачи показывают чек-лист, а не «как надо» (UNCERTAINTY).
- **`options` (choice)** — 2…8 строк по 1…120, различны после нормализации.
  **`answer`** — индекс в `options`, `0 ≤ answer < options.length`, **по исходному порядку**.
  **`shuffle`** — по умолчанию `true`: порядок показа перемешивается по сиду; `false` —
  для вариантов вроде «все перечисленные».
- **`items` (ordering)** — верный порядок, 2…12 строк по 1…120, без дублей после
  нормализации. Показывается перемешанным по сиду; перестановка **обязана** отличаться
  от исходной.
- **`delayed_recall`**: `prompt` — инструкция фазы запоминания; `memorize` — 1…500, что
  показать; `question` — 1…300, что спросить позже; `delayRounds` — 1…3 (по умолчанию `1`):
  через сколько кругов задать вопрос; `showSec` — 3…60 (по умолчанию `10`): сколько
  показывать. Запись `TaskAttempt` создаётся **один раз, при ответе**.
- **`spatial` (то, что выражается данными)**: `grid` = `{ "rows": int, "cols": int }`,
  каждый 2…12; `answer` = `{ "row": int, "col": int }` (с нуля, внутри сетки);
  `objects` — 0…40 элементов `{ "label": string 1…40, "row": int, "col": int }`: что и
  где показывается на сетке в течение `showSec` (3…60, по умолчанию `10`), потом
  прячется; `prompt` — вопрос («Где была B?»). Ячейки `objects` внутри сетки и не
  совпадают. Ответ — нажатие клетки.
  **Параметры генератора (случайное размещение, повороты, шахматные позиции) —
  решается в v0.2.**
- **`stream` (то, что выражается данными)**: `stimuli` — 2…60 строк по 1…20: фиксированная
  последовательность, каждая показывается `stimulusMs` (200…5000, по умолчанию `1000`);
  `targets` — 1…10 строк, **каждая встречается в `stimuli`**; правило — «нажимать на
  стимул из `targets`» (go/no-go). `isCorrect = true` ⇔ ни одного пропуска и ни одного
  ложного нажатия. **Параметры генератора (n-back, Струп, смена правила, случайные
  последовательности, подсчёт пропусков и ложных нажатий в событиях) — решается в v0.2.**
- **`gen`** — зарезервировано под параметры генератора v0.2. В v1 присутствие даёт
  `PACK_RESERVED_FIELD` (warning), значение игнорируется и **не сохраняется**.
- **`selfCheck` (verbal)** — 2…3 вопроса «да/нет» по 1…160. Результат:
  `selfRating = floor(3 × yes / n + 0.5)`, где `n` — число вопросов, `yes` — число «да»
  (0…3).
- **`cues` (verbal)** — 0…5 подсказок `{ "atSec": [a, b], "text": string 1…200 }`.
  `a`, `b` — целые, `0 ≤ a ≤ b ≤ timeSec`. Диапазоны **упорядочены и не пересекаются**:
  `cues[i].atSec[1] < cues[i+1].atSec[0]`. Момент показа внутри `[a, b]` выбирается
  по сиду равномерно среди целых секунд, включая границы (инвариант 4). Алгоритм —
  в §9, решение 25.

### 1.5 Полный пример (по одной задаче каждого архетипа)

```json
{
  "schemaVersion": 1,
  "kind": "task_pack",
  "pack": "demo.ru",
  "title": "Демонстрационный пак",
  "locale": "ru",
  "license": "CC-BY-4.0",
  "packSource": "builtin",
  "status": "draft",
  "levels": ["recruit", "fighter"],
  "categories": [
    { "domain": "it.java", "title": "Java", "description": "Основы языка." },
    { "domain": "it.net", "title": "Сети" },
    { "domain": "math.estimation", "title": "Оценка величин" },
    { "domain": "cog.memory", "title": "Память" },
    { "domain": "cog.spatial", "title": "Пространство" },
    { "domain": "cog.attention", "title": "Внимание" },
    { "domain": "cog.speech", "title": "Речь" }
  ],
  "items": [
    {
      "id": "demo.java.001",
      "domain": "it.java",
      "archetype": "recall",
      "verifiable": true,
      "timeSec": 30,
      "difficulty": 0.2,
      "prompt": "Каким ключевым словом объявляется константа в Java? Введите слово.",
      "answer": "final",
      "accept": ["final"],
      "reveal": "final запрещает повторное присваивание."
    },
    {
      "id": "demo.java.002",
      "domain": "it.java",
      "archetype": "choice",
      "verifiable": true,
      "timeSec": 30,
      "difficulty": 0.3,
      "prompt": "Какой из типов Java не является примитивным?",
      "options": ["int", "boolean", "String", "double"],
      "answer": 2
    },
    {
      "id": "demo.net.001",
      "domain": "it.net",
      "archetype": "ordering",
      "verifiable": true,
      "timeSec": 60,
      "difficulty": 0.4,
      "prompt": "Расставьте шаги открытия страницы по HTTPS по порядку.",
      "items": ["Разрешение имени (DNS)", "Соединение TCP", "Рукопожатие TLS", "Запрос HTTP", "Ответ сервера"]
    },
    {
      "id": "demo.est.001",
      "domain": "math.estimation",
      "archetype": "recall",
      "verifiable": true,
      "timeSec": 45,
      "difficulty": 0.3,
      "prompt": "Оцените: сколько секунд в сутках? Введите число.",
      "answer": 86400,
      "accept": { "min": 80000, "max": 90000 },
      "reveal": "24 × 60 × 60 = 86 400."
    },
    {
      "id": "demo.mem.001",
      "domain": "cog.memory",
      "archetype": "delayed_recall",
      "verifiable": true,
      "timeSec": 20,
      "difficulty": 0.35,
      "prompt": "Запомните три кода. Вопрос будет после следующего круга.",
      "memorize": "К7 · Р3 · Б9",
      "question": "Какой код был средним?",
      "answer": "Р3",
      "delayRounds": 1,
      "showSec": 8
    },
    {
      "id": "demo.spa.001",
      "domain": "cog.spatial",
      "archetype": "spatial",
      "verifiable": true,
      "timeSec": 20,
      "difficulty": 0.4,
      "prompt": "Где была буква B? Нажмите на клетку.",
      "grid": { "rows": 4, "cols": 4 },
      "objects": [
        { "label": "A", "row": 0, "col": 1 },
        { "label": "B", "row": 2, "col": 3 }
      ],
      "showSec": 6,
      "answer": { "row": 2, "col": 3 }
    },
    {
      "id": "demo.str.001",
      "domain": "cog.attention",
      "archetype": "stream",
      "verifiable": true,
      "timeSec": 30,
      "difficulty": 0.3,
      "prompt": "Нажимайте каждый раз, когда видите слово КРАСНЫЙ.",
      "stimuli": ["КРАСНЫЙ", "СИНИЙ", "ЗЕЛЁНЫЙ", "КРАСНЫЙ", "СИНИЙ", "СИНИЙ", "КРАСНЫЙ", "ЖЁЛТЫЙ"],
      "targets": ["КРАСНЫЙ"],
      "stimulusMs": 900
    },
    {
      "id": "demo.ver.001",
      "domain": "cog.speech",
      "archetype": "verbal",
      "verifiable": false,
      "timeSec": 60,
      "difficulty": 0.45,
      "prompt": "Называйте вслух города без повторов. Не останавливайтесь.",
      "cues": [
        { "atSec": [15, 25], "text": "СМЕНА ПРАВИЛА: теперь только города на букву, на которую закончилось предыдущее слово." }
      ],
      "selfCheck": [
        "Заметил смену правила сразу?",
        "Ни одного повтора?",
        "Не молчал дольше трёх секунд?"
      ]
    }
  ]
}
```

---

## 2. Пак упражнений v1

Файл `*.pack.json`. Упражнение не зависит от языка интерфейса, поэтому название —
**карта локаль → строка** (инвариант 9: контент не в ARB).

### 2.1 Заголовок

| Поле | Тип | Обяз. | Null | Ограничения |
|---|---|---|---|---|
| `schemaVersion` | int | да | нет | `1` |
| `kind` | string | да | нет | ровно `"exercise_pack"` |
| `pack` | string | да | нет | паттерн `pack` |
| `title` | string | да | нет | 1…80, на языке `defaultLocale` |
| `defaultLocale` | string | да | нет | паттерн `locale`; этот ключ **обязан** быть в `name` каждого упражнения |
| `license` | string | да | нет | как у пака задач |
| `packSource` | string | да | нет | `builtin` \| `imported` \| `user` (недоверенное поле) |
| `status` | string | да | нет | `draft` \| `reviewed` \| `published` |
| `exercises` | object[] | да | нет | 1…500 элементов |

### 2.2 Упражнение (`exercises[]`)

| Поле | Тип | Обяз. | Null | Ограничения |
|---|---|---|---|---|
| `id` | string | да | нет | паттерн `id` упражнения (`ex.<slug>`); уникален в паке; **неизменяем** — на него ссылаются `ExerciseSet` и профиль |
| `name` | object | да | нет | карта `locale → string`; 1…8 ключей, каждый ключ — паттерн `locale`, значение 1…60 однострочное; обязателен ключ `defaultLocale` |
| `unit` | string | да | нет | `reps` \| `seconds` |
| `muscleGroups` | string[] | да | нет | 1…6 уникальных тегов; известные v1: `chest`, `back`, `shoulders`, `biceps`, `triceps`, `core`, `glutes`, `quads`, `hamstrings`, `calves`, `full_body` |
| `inventory` | string[] | да | нет | 0…4 уникальных тегов; `[]` — без инвентаря; известные v1: `pullup_bar`, `dumbbell`, `kettlebell`, `barbell`, `bench`, `resistance_band`, `jump_rope`, `box` |
| `locations` | string[] | да | нет | 1…3 уникальных: `HOME` \| `GYM` \| `OUTDOOR` |
| `legacyId` | int | да | **да** | `≥ 1` или `null`; числовой id из прототипа `www/index.html` (1…15); уникален в паке среди не-`null`. У новых упражнений — `null` |

Название по локали: запрошенная локаль → `defaultLocale`. Теги `muscleGroups` и
`inventory` — **открытые**: неизвестный, но правильно оформленный тег сохраняется и не
участвует в фильтрах (`EX_UNKNOWN_TAG`, warning); неправильно оформленный — `EX_BAD_TAG`.

```json
{
  "schemaVersion": 1,
  "kind": "exercise_pack",
  "pack": "exercises.demo",
  "title": "Демонстрационные упражнения",
  "defaultLocale": "ru",
  "license": "CC-BY-4.0",
  "packSource": "imported",
  "status": "draft",
  "exercises": [
    {
      "id": "ex.plank",
      "name": { "ru": "Планка", "uk": "Планка", "en": "Plank" },
      "unit": "seconds",
      "muscleGroups": ["core", "shoulders"],
      "inventory": [],
      "locations": ["HOME", "GYM", "OUTDOOR"],
      "legacyId": null
    },
    {
      "id": "ex.pullup",
      "name": { "ru": "Подтягивания" },
      "unit": "reps",
      "muscleGroups": ["back", "biceps"],
      "inventory": ["pullup_bar"],
      "locations": ["GYM", "OUTDOOR"],
      "legacyId": null
    }
  ]
}
```

---

## 3. Записи событий

Пишутся с первого релиза, **сырыми** (инвариант 2). Все `id` — UUID v4, генерируются
на клиенте. Экспорт и синхронизация — плоский документ:
`{ "schemaVersion": 1, "kind": "events_export", "sessions": [], "rounds": [], "sets": [], "attempts": [] }`
(каждый массив — записи ниже; связи по `sessionId` / `roundId`).

Ссылочные поля — `string` UUID, `null: нет`, если не сказано иное.

### 3.1 `Session`

| Поле | Тип | Обяз. | Null | Ограничения |
|---|---|---|---|---|
| `id` | string | да | нет | UUID v4 |
| `startedAt` | int | да | нет | мс эпохи UTC |
| `endedAt` | int | да | **да** | `≥ startedAt`; `null` — сессия не завершена (прервана, приложение убито) |
| `utcOffsetMin` | int | да | нет | −720…840; смещение локального пояса на момент старта (серии по локальным дням) |
| `location` | string | да | нет | `HOME` \| `GYM` \| `OUTDOOR` |
| `difficulty` | string | да | нет | уровень: `recruit` \| `fighter` \| `operator` \| `spetsnaz` |
| `template` | string | да | нет | `dual_task` \| `physical_only` \| `cognitive_only` \| `custom` (инвариант 5) |
| `appVersion` | string | да | нет | 1…32, например `0.1.0+3` |

### 3.2 `RoundLog` — один на физический круг

| Поле | Тип | Обяз. | Null | Ограничения |
|---|---|---|---|---|
| `id` | string | да | нет | UUID v4 |
| `sessionId` | string | да | нет | UUID существующей `Session` |
| `blockIndex` | int | да | нет | `≥ 0`, позиция `PhysicalBlock` в списке блоков сессии |
| `roundIndex` | int | да | нет | `≥ 0`, порядковый номер круга среди физических блоков сессии |
| `durationMs` | int | да | нет | `≥ 0` |
| `rpe` | int | да | **да** | 1 = легко, 2 = нормально, 3 = тяжело; `null` — не оценил |

### 3.3 `ExerciseSet` — один на упражнение в круге

| Поле | Тип | Обяз. | Null | Ограничения |
|---|---|---|---|---|
| `id` | string | да | нет | UUID v4 |
| `sessionId` | string | да | нет | UUID `Session` |
| `roundId` | string | да | нет | UUID `RoundLog` той же сессии |
| `setIndex` | int | да | нет | `≥ 0`, позиция упражнения в круге |
| `exerciseId` | string | да | нет | паттерн `id` упражнения |
| `unit` | string | да | нет | `reps` \| `seconds`; копия `unit` упражнения на момент записи |
| `prescribed` | int | да | нет | 1…3600; план, **зафиксированный при старте сессии** (D6), внутри сессии не меняется |
| `done` | int | да | нет | 0…3600; сколько выполнено (0 — пропущено) |
| `startedAt` | int | да | нет | мс эпохи UTC |
| `endedAt` | int | да | нет | `≥ startedAt` |

### 3.4 `TaskAttempt` — по одному на каждую когнитивную попытку

| Поле | Тип | Обяз. | Null | Ограничения |
|---|---|---|---|---|
| `id` | string | да | нет | UUID v4 |
| `sessionId` | string | да | нет | UUID `Session` |
| `blockIndex` | int | да | нет | `≥ 0`, позиция `CognitiveBlock` в списке блоков |
| `roundIndex` | int | да | нет | `≥ 0`. Число `CognitiveBlock`, **начавшихся раньше** в этой сессии (0-based). В классическом dual-task пауза после круга *k* имеет `roundIndex = k`; в `cognitive_only` — порядковый номер блока |
| `taskId` | string | да | нет | 1…64; `id` задачи пака. Для генераторного провайдера — id шаблона |
| `packId` | string | да | нет | `pack` пака (для генераторного провайдера — id провайдера) |
| `packSource` | string | да | нет | `builtin` \| `imported` \| `user`. Для `imported`/`user` события не идут в Индекс (D4) |
| `archetype` | string | да | нет | один из семи; копия на момент показа |
| `domain` | string | да | нет | паттерн `domain`; копия |
| `difficulty` | number | да | нет | 0…1; копия **на момент показа** (рейтинг потом будет пересчитан, история не должна меняться) |
| `seed` | int | да | нет | `0 … 2^53−1`; сид, по которому сгенерирована/показана задача (инвариант 4) |
| `status` | string | да | нет | `answered` \| `timeout` \| `skipped` |
| `presentedAt` | int | да | нет | мс эпохи UTC |
| `answeredAt` | int | да | **да** | `≥ presentedAt`; `null` ⇔ `status != "answered"` |
| `latencyMs` | int | да | **да** | `≥ 0`; `null` ⇔ `status != "answered"`. Измеряется монотонными часами; `answeredAt − presentedAt` допустим с погрешностью до 1000 мс |
| `isCorrect` | bool | да | **да** | `null` ⇔ задача непроверяема (`archetype == "verbal"`). У проверяемой — всегда `true`/`false`; `timeout` и `skipped` дают `false` |
| `selfRating` | int | да | **да** | 0…3, **только** у `verbal` и `status == "answered"`; иначе `null` |
| `response` | string | да | **да** | 1…200; ответ пользователя в каноническом виде, чтобы сервер перепроверил `isCorrect` (инвариант 8). `recall`/`delayed_recall` — введённая строка (после trim); `choice` — индекс варианта **по исходному порядку**; `ordering` — индексы шагов в порядке пользователя через `,`; `spatial` — `row,col`. `stream` и `verbal` — `null` (формат `stream` — v0.2). `null` при `timeout`/`skipped` |
| `encodedRoundIndex` | int | да | **да** | `≥ 0`, `≤ roundIndex`; только `delayed_recall`: `roundIndex` фазы запоминания. Иначе `null` |
| `payloadHash` | string | да | нет | 64 символа `[0-9a-f]`, см. 3.5 |

> `roundIndex`, `latencyMs`, `isCorrect`, `payloadHash` — ядро инварианта 2. Их
> отсутствие — ошибка записи, а не «пустое значение».

### 3.5 `payloadHash` — точное определение

Хеш **определения задачи** — то, что видит и решает человек. Нужен, чтобы сервер,
знающий встроенный пак, обнаружил подмену задачи.

1. Взять задачу **после** подстановки слотов (v0.2) и **до** перемешивания при показе.
   Сид хранится отдельно (`seed`), поэтому пара `(payloadHash, seed)` однозначно
   восстанавливает показанное.
2. Собрать **payload-объект** — только перечисленные ниже поля, только присутствующие
   (с применёнными значениями по умолчанию). Ключ с `null`/отсутствием не включается.

| Архетип | Поля payload |
|---|---|
| все | `archetype`, `prompt`, `timeSec` |
| `recall` | + `answer`, `accept` |
| `choice` | + `options`, `answer` |
| `ordering` | + `items` |
| `delayed_recall` | + `memorize`, `question`, `answer`, `accept`, `delayRounds`, `showSec` |
| `spatial` | + `grid`, `objects`, `answer`, `showSec` |
| `stream` | + `stimuli`, `targets`, `stimulusMs` |
| `verbal` | + `selfCheck`, `cues` |

   **Не входят:** `id`, `domain`, `difficulty`, `verifiable`, `reveal`, `shuffle`, `gen`
   и поля пака. Перекалибровка сложности и перенос в другую категорию хеш не меняют.
3. Строки — NFC, `\n` вместо `\r\n`. Порядок элементов массивов сохраняется.
4. **Канонический JSON:** без пробелов и переводов строки; ключи объектов — по
   возрастанию кодовой точки (ключи ASCII, то есть лексикографически по байтам);
   строки — UTF-8, экранируются только `"`→`\"`, `\`→`\\`, U+0008 `\b`, U+0009 `\t`,
   U+000A `\n`, U+000C `\f`, U+000D `\r` и прочие U+0000…U+001F как `\u00xx` в
   нижнем регистре; всё остальное (кириллица, `/`, U+007F) — буквально. Числа: целое
   значение — десятичное целое без `.0`, без `+`, без экспоненты (`-0` → `0`); дробное
   — кратчайшая десятичная запись, возвращающая то же число, без экспоненты и
   хвостовых нулей (`0.35`, не `3.5e-1`). `true`/`false` как есть. (Подводный камень:
   `double.toString()` в Dart печатает `5.0` — сначала проверить целочисленность.)
5. `payloadHash = hex_lowercase(SHA-256(UTF-8(канонический_JSON)))`.

**Тестовый вектор.** Задача `demo.java.002` из примера 1.5 даёт каноническую строку

```
{"answer":2,"archetype":"choice","options":["int","boolean","String","double"],"prompt":"Какой из типов Java не является примитивным?","timeSec":30}
```

и хеш `0301b322e4db5a224c9262ad495394182698d55b6a82ac005e992529b93a4833`.
Реализация, не воспроизводящая этот хеш, неверна.

Хеш **не хранится в паке** — считается при загрузке. Дедупликация при импорте (D5) —
по `id` и по `payloadHash`.

### 3.6 Примеры

```json
{
  "schemaVersion": 1,
  "kind": "events_export",
  "sessions": [
    {
      "id": "62ed4258-a855-4484-9598-d5cc938f60f0",
      "startedAt": 1795100000000,
      "endedAt": 1795101500000,
      "utcOffsetMin": 180,
      "location": "HOME",
      "difficulty": "fighter",
      "template": "dual_task",
      "appVersion": "0.1.0+1"
    }
  ],
  "rounds": [
    {
      "id": "5004e0ab-d425-48a0-bf87-766cf1c3cc8b",
      "sessionId": "62ed4258-a855-4484-9598-d5cc938f60f0",
      "blockIndex": 0,
      "roundIndex": 0,
      "durationMs": 214000,
      "rpe": 2
    }
  ],
  "sets": [
    {
      "id": "65602417-d097-441d-8132-a1fe91c4503e",
      "sessionId": "62ed4258-a855-4484-9598-d5cc938f60f0",
      "roundId": "5004e0ab-d425-48a0-bf87-766cf1c3cc8b",
      "setIndex": 0,
      "exerciseId": "ex.pushup",
      "unit": "reps",
      "prescribed": 15,
      "done": 15,
      "startedAt": 1795100010000,
      "endedAt": 1795100050000
    }
  ],
  "attempts": [
    {
      "id": "007d3bd5-9f98-44b4-87b1-b704f2514e58",
      "sessionId": "62ed4258-a855-4484-9598-d5cc938f60f0",
      "blockIndex": 1,
      "roundIndex": 0,
      "taskId": "demo.java.002",
      "packId": "demo.ru",
      "packSource": "builtin",
      "archetype": "choice",
      "domain": "it.java",
      "difficulty": 0.3,
      "seed": 1234567890,
      "status": "answered",
      "presentedAt": 1795100220000,
      "answeredAt": 1795100227400,
      "latencyMs": 7391,
      "isCorrect": true,
      "selfRating": null,
      "response": "2",
      "encodedRoundIndex": null,
      "payloadHash": "0301b322e4db5a224c9262ad495394182698d55b6a82ac005e992529b93a4833"
    },
    {
      "id": "75eed978-f78e-4716-b034-58b94b257d27",
      "sessionId": "62ed4258-a855-4484-9598-d5cc938f60f0",
      "blockIndex": 3,
      "roundIndex": 1,
      "taskId": "demo.ver.001",
      "packId": "demo.ru",
      "packSource": "builtin",
      "archetype": "verbal",
      "domain": "cog.speech",
      "difficulty": 0.45,
      "seed": 987654321,
      "status": "answered",
      "presentedAt": 1795100500000,
      "answeredAt": 1795100560000,
      "latencyMs": 60000,
      "isCorrect": null,
      "selfRating": 2,
      "response": null,
      "encodedRoundIndex": null,
      "payloadHash": "0000000000000000000000000000000000000000000000000000000000000000"
    }
  ]
}
```

(Хеш второй записи в примере — заглушка нулей; формат он удовлетворяет.)

---

## 4. Фрагменты профиля

Профиль хранится в БД пользователя, не в паках. Здесь — только части, которые
определяет этот документ.

| Поле | Тип | Обяз. | Null | Ограничения |
|---|---|---|---|---|
| `disabledCategories` | string[] | да | нет | 0…500 уникальных путей `domain`. D2: множество **отключённых**; категории, которых нет в списке, **включены** (новые из обновлений паков — тоже) |
| `defaultTargets` | object | да | нет | `{ "reps": Range, "seconds": Range }` — цель для упражнения без своей `ExerciseTarget`; заменяет глобальные `fixedReps`/`minReps`/`maxReps` прототипа |
| `exerciseTargets` | object[] | да | нет | 0…500 `ExerciseTarget`, уникальных по `exerciseId` |
| `progression` | object | да | нет | `{ "enabled": bool }`; по умолчанию `enabled: true` (рекомендация REQUIREMENTS) |

**`Range`** = `{ "min": int, "max": int }`, `1 ≤ min ≤ max ≤ 3600` (для `reps` на практике ≤ 999).
`min == max` — фиксированная цель; `min < max` — случайная в диапазоне на каждый круг
(аналог `repMode: "range"` прототипа).

**`ExerciseTarget`**:

| Поле | Тип | Обяз. | Null | Ограничения |
|---|---|---|---|---|
| `exerciseId` | string | да | нет | паттерн `id` упражнения |
| `min` | int | да | нет | `1 ≤ min ≤ max` |
| `max` | int | да | нет | `≤ 3600` |
| `lockedByUser` | bool | да | нет | `true` — правка вручную; прогрессия (v0.2) цель не меняет |

Правила `disabledCategories`:
- Путь `p` отключает категорию `d`, если `d == p` или `d` начинается с `p + "."`
  (граница по сегменту: `cog.unc` **не** отключает `cog.uncertainty`).
- Отключённый родитель отключает всех потомков.
- **Пул не бывает пустым:** изменение, после которого ни одна задача установленных
  паков не проходит фильтр, **отклоняется** (`PROF_EMPTY_POOL`). Проверяется при
  записи, не при чтении.
- Раздел («Проверяемые»/«Непроверяемые») отдельно не хранится: он производный от
  `verifiable`.

```json
{
  "schemaVersion": 1,
  "disabledCategories": ["cog.uncertainty.premortem", "it"],
  "defaultTargets": {
    "reps": { "min": 15, "max": 15 },
    "seconds": { "min": 30, "max": 30 }
  },
  "exerciseTargets": [
    { "exerciseId": "ex.pistol_squat", "min": 5, "max": 8, "lockedByUser": true }
  ],
  "progression": { "enabled": true }
}
```

Миграция настроек прототипа: `repMode: "fixed"` → `defaultTargets.reps = {fixedReps, fixedReps}`;
`repMode: "range"` → `{min: min(minReps,maxReps), max: max(minReps,maxReps)}`.

---

## 5. Версионирование

- `schemaVersion` — целое, растёт при **несовместимом** изменении. Совместимые
  добавления (новое необязательное поле, новый тег в открытом списке) версию не
  меняют.
- Читатель знает диапазон `[minSupported, maxSupported]`.
  - `schemaVersion` нет / не целое / `< 1` → `PACK_SCHEMA_VERSION`, документ отвергнут.
  - `> maxSupported` → `PACK_SCHEMA_UNSUPPORTED`; **отвергается весь документ целиком,
    частично не читается**; сообщение — «обновите приложение».
  - `< minSupported` без цепочки миграции → `PACK_SCHEMA_UNSUPPORTED`.
  - иначе — миграция до `maxSupported`, затем валидация по текущим правилам.
- **Неизвестные поля**: игнорируются, `PACK_UNKNOWN_FIELD` (warning), при импорте **не
  сохраняются** (контент недоверенный, место ограничено). Встроенные паки в CI
  проверяются со строгим режимом: warning = сбой, чтобы опечатки в именах полей не
  проходили незамеченными.
- **Миграция** — чистая функция `migrate(json, from) → json(from+1)`, цепочка
  `N → N+1 → …`. Без I/O, без случайности, без потери данных, идемпотентна на уже
  новом документе. Для каждой пары — юнит-тест «старый образец → новый образец».
- Экспорт всегда пишет текущую `schemaVersion`. Схема Drift версионируется отдельно
  (ARCHITECTURE §3) и мигрирует строки; JSON-версия — про обмен.
- Сервер принимает события версий `maxSupported` и `maxSupported − 1`.

---

## 6. Правила валидации

Результат — список `{ code, severity, path }`, `path` — JSON Pointer (RFC 6901),
например `/items/3/answer`. Текст сообщения — забота UI, **код стабилен** и не
переименовывается. Область:
**док** — отвергается весь файл; **эл.** — исключается элемент (задача, упражнение,
категория), остальное импортируется. Дубликаты: остаётся **первый**, последующие
исключаются. Для встроенных паков в CI любой `error` и любой `warning` — сбой.

### 6.1 Общие (оба вида паков)

| № | Код | Ур. | Обл. | Условие |
|---|---|---|---|---|
| 1 | `PACK_NOT_JSON` | error | док | не UTF-8, не JSON или корень не объект |
| 2 | `PACK_TOO_LARGE` | error | док | размер > лимита (проверяется **до** парсинга) |
| 3 | `PACK_TOO_DEEP` | error | док | вложенность > лимита (скан скобок вне строк **до** парсинга) |
| 4 | `PACK_SCHEMA_VERSION` | error | док | `schemaVersion` нет, не целое или `< 1` |
| 5 | `PACK_SCHEMA_UNSUPPORTED` | error | док | версия вне поддерживаемых, нет цепочки миграции |
| 6 | `PACK_BAD_KIND` | error | док | `kind` не соответствует ожидаемому виду документа |
| 7 | `PACK_MISSING_FIELD` | error | док/эл. | обязательное поле отсутствует (для данного архетипа тоже) |
| 8 | `PACK_BAD_TYPE` | error | док/эл. | JSON-тип значения не тот; `null` там, где `null: нет` |
| 9 | `PACK_UNKNOWN_FIELD` | warning | — | поле не определено схемой |
| 10 | `PACK_FIELD_NOT_ALLOWED` | warning | — | поле определено схемой, но не для этого архетипа; значение игнорируется |
| 11 | `PACK_RESERVED_FIELD` | warning | — | присутствует `gen` |
| 12 | `PACK_BAD_ID` | error | эл./док | `id`/`pack` не соответствует паттерну |
| 13 | `PACK_DUP_ID` | error | эл. | `id` повторяется в паке |
| 14 | `PACK_BAD_FORMAT` | error | док/эл. | строка не соответствует паттерну (`locale`, `license`, UUID, хеш) |
| 15 | `PACK_BAD_ENUM` | error | док/эл. | значение вне закрытого списка (`packSource`, `status`, `levels`, `unit`, …); дубль в массиве уникальных значений |
| 16 | `PACK_LOCALE_MISMATCH` | error | док | `locale` пака ≠ каталогу `assets/content/<locale>/` |
| 17 | `PACK_SOURCE_OVERRIDDEN` | warning | док | файл заявил `packSource` ≠ присвоенного читателем (решение 10) |
| 18 | `PACK_STRING_EMPTY` | error | эл./док | строка пуста после trim, где минимум 1 |
| 19 | `PACK_STRING_TOO_LONG` | error | эл./док | длина (в кодовых точках после NFC) больше лимита поля |
| 20 | `PACK_BAD_CHARS` | error | эл./док | управляющие символы U+0000…U+001F (кроме `\n` в многострочных полях), U+007F…U+009F, U+2028/2029, bidi-управление U+200E/200F, U+202A…202E, U+2066…2069 |
| 21 | `PACK_MARKUP` | error | эл./док | строка содержит HTML-подобную разметку: `<!--` или тег `</?[A-Za-z][A-Za-z0-9-]*(\s[^<>]*)?/?>` |
| 22 | `PACK_URL_IN_TEXT` | warning | — | строка содержит `://`; ссылка в любом случае не активируется |
| 23 | `PACK_NUMBER_RANGE` | error | эл. | число не конечное, `|x| ≥ 1e15` или больше 6 знаков после запятой |
| 24 | `PACK_LIMIT_ITEMS` | error | док | элементов в `items`/`exercises`/`categories` больше лимита |
| 25 | `PACK_LIMIT_ARRAY` | error | эл. | вложенный массив (`options`, `cues`, `objects`, …) длиннее лимита |

### 6.2 Пак задач

| № | Код | Ур. | Обл. | Условие |
|---|---|---|---|---|
| 26 | `PACK_BAD_DOMAIN` | error | эл. | `domain` не по паттерну |
| 27 | `PACK_DUP_CATEGORY` | error | эл. | `domain` в `categories` повторяется |
| 28 | `PACK_UNDECLARED_DOMAIN` | error | эл. | `domain` задачи не совпадает ни с одной категорией |
| 29 | `PACK_EMPTY_CATEGORY` | warning | — | у категории нет ни одной задачи |
| 30 | `PACK_BAD_ARCHETYPE` | error | эл. | `archetype` не из семи |
| 31 | `PACK_VERBAL_VERIFIABLE` | error | эл. | `verbal` и `verifiable != false` |
| 32 | `PACK_NONVERBAL_UNVERIFIABLE` | error | эл. | не-`verbal` и `verifiable != true` |
| 33 | `PACK_NO_SELFCHECK` | error | эл. | `verbal` без `selfCheck` |
| 34 | `PACK_SELFCHECK_COUNT` | error | эл. | `selfCheck` не 2…3 вопроса |
| 35 | `PACK_BAD_DIFFICULTY` | error | эл. | `difficulty` не число в `[0, 1]` |
| 36 | `PACK_BAD_TIME` | error | эл. | `timeSec` не целое в 5…180 |
| 37 | `PACK_TIME_LONG` | warning | — | `timeSec > 120` (пауза 180 с, часть уходит на чтение) |
| 38 | `PACK_DUP_PROMPT` | error | эл. | `prompt` повторяется (после нормализации) |
| 39 | `PACK_CHOICE_OPTIONS` | error | эл. | `options` не 2…8 различных вариантов |
| 40 | `PACK_CHOICE_ANSWER_RANGE` | error | эл. | `answer` не целое или вне `0 … options.length−1` |
| 41 | `PACK_ACCEPT_INVALID` | error | эл. | форма `accept` неверна (раздел 1.4) |
| 42 | `PACK_ANSWER_NOT_ACCEPTED` | error | эл. | `answer` не входит в `accept` (массив / диапазон) |
| 43 | `PACK_ORDERING_SIZE` | error | эл. | в `items` меньше 2 или больше 12 шагов |
| 44 | `PACK_ORDERING_DUP` | error | эл. | в `items` есть дубли (после нормализации) |
| 45 | `PACK_CUE_RANGE` | error | эл. | `atSec` не `[a, b]` целых с `0 ≤ a ≤ b ≤ timeSec`; `text` вне 1…200 |
| 46 | `PACK_CUE_ORDER` | error | эл. | диапазоны `cues` не упорядочены или пересекаются |
| 47 | `PACK_CUE_LATE` | warning | — | `b > timeSec − 10`: на реакцию остаётся меньше 10 с |
| 48 | `PACK_SPATIAL_BOUNDS` | error | эл. | `grid` вне 2…12 или `answer`/`objects` вне сетки |
| 49 | `PACK_SPATIAL_OVERLAP` | error | эл. | два объекта в одной клетке |
| 50 | `PACK_STREAM_TARGETS` | error | эл. | `targets` не входят в `stimuli` целиком, либо в `stimuli` нет ни одной цели |
| 51 | `PACK_PARAM_RANGE` | error | эл. | `delayRounds` ∉ 1…3, `showSec` ∉ 3…60, `stimulusMs` ∉ 200…5000 |

### 6.3 Пак упражнений

| № | Код | Ур. | Обл. | Условие |
|---|---|---|---|---|
| 52 | `EX_BAD_NAME` | error | эл. | `name` не карта, ключ не `locale`, пустое значение, нет ключа `defaultLocale` |
| 53 | `EX_DUP_NAME` | warning | — | одинаковое название на `defaultLocale` у двух упражнений |
| 54 | `EX_NO_MUSCLES` | error | эл. | `muscleGroups` пуст |
| 55 | `EX_BAD_TAG` | error | эл. | тег `muscleGroups`/`inventory` не по паттерну тега или дублируется |
| 56 | `EX_UNKNOWN_TAG` | warning | — | тег правильный, но вне известных v1 |
| 57 | `EX_BAD_LOCATION` | error | эл. | `locations` пуст, дубль или значение вне `HOME`/`GYM`/`OUTDOOR` |
| 58 | `EX_BAD_LEGACY_ID` | error | эл. | `legacyId` не целое `≥ 1` и не `null` |
| 59 | `EX_DUP_LEGACY_ID` | error | эл. | `legacyId` повторяется |

Недопустимый `unit` — `PACK_BAD_ENUM`; повтор `id` — `PACK_DUP_ID`.

### 6.4 События и профиль

| № | Код | Ур. | Условие |
|---|---|---|---|
| 60 | `EVT_BAD_UUID` | error | `id`/`sessionId`/`roundId` не UUID v4 |
| 61 | `EVT_DUP_ID` | error | `id` повторяется в своём массиве |
| 62 | `EVT_ORPHAN` | error | `sessionId`/`roundId` не найден в документе или в БД |
| 63 | `EVT_BAD_TIME` | error | время вне `0 … 4102444800000` |
| 64 | `EVT_TIME_ORDER` | error | `endedAt < startedAt` или `answeredAt < presentedAt` |
| 65 | `EVT_BAD_ENUM` | error | `location`, `difficulty`, `template`, `unit`, `packSource`, `status`, `archetype` вне списка |
| 66 | `EVT_RANGE` | error | числовое поле вне диапазона из таблицы (`rpe`, `prescribed`, `done`, `seed`, `difficulty`, индексы, `utcOffsetMin`) |
| 67 | `EVT_VERIFIABLE_MISMATCH` | error | `isCorrect` null у проверяемой или не null у `verbal`; `selfRating` не null у не-`verbal` или при `status != answered` |
| 68 | `EVT_STATUS_MISMATCH` | error | `answeredAt`/`latencyMs` null при `answered`, или не null при другом статусе; `response` не null при `timeout`/`skipped` |
| 69 | `EVT_BAD_HASH` | error | `payloadHash` не 64 символа `[0-9a-f]` |
| 70 | `EVT_LATENCY_MISMATCH` | warning | `|latencyMs − (answeredAt − presentedAt)| > 1000` |
| 71 | `EVT_ENCODED_ROUND` | error | `encodedRoundIndex` не null у не-`delayed_recall` или `> roundIndex` |
| 72 | `PROF_BAD_CATEGORY` | error | элемент `disabledCategories` не по паттерну `domain` или дубль |
| 73 | `PROF_TARGET_RANGE` | error | `Range`/`ExerciseTarget`: не `1 ≤ min ≤ max ≤ 3600`; дубль `exerciseId` |
| 74 | `PROF_UNKNOWN_EXERCISE` | warning | `exerciseId` цели нет в установленных паках упражнений |
| 75 | `PROF_EMPTY_POOL` | error | запись отклонена: пул задач стал бы пустым (при записи) |

---

## 7. Лимиты импорта (D5) — предложение

Все значения — предложение, они лежат в одной константе `ImportLimits` и меняются
без смены схемы. Лимиты проверяются **до** записи в БД, размер и глубина — до парсинга.

| Что | Лимит | Код |
|---|---|---|
| Размер файла / вставленного текста | 1 МиБ (1 048 576 байт UTF-8) | `PACK_TOO_LARGE` |
| Глубина вложенности JSON | 8 (корень = 1) | `PACK_TOO_DEEP` |
| `items` в паке задач | 2000 | `PACK_LIMIT_ITEMS` |
| `exercises` в паке | 500 | `PACK_LIMIT_ITEMS` |
| `categories` | 100 | `PACK_LIMIT_ITEMS` |
| Паки на пользователя (`imported` + `user`) | 50; суммарно 20 000 задач | при установке, не схема |
| `prompt` | 1000 | `PACK_STRING_TOO_LONG` |
| `reveal` | 600 | то же |
| `memorize` / `question` | 500 / 300 | то же |
| `answer` (строка), элемент `accept` | 200 | то же |
| `options` (≤ 8), `items` ordering (≤ 12) — элемент | 120 | то же / `PACK_LIMIT_ARRAY` |
| `selfCheck` (≤ 3) — элемент; `cues` (≤ 5) — `text` | 160; 200 | то же |
| `objects` (≤ 40) — `label`; `stimuli` (≤ 60), `targets` (≤ 10) — элемент | 40; 20 | то же |
| `title` пака / категории | 80 / 60 | то же |
| `description` категории | 200 | то же |
| Название упражнения (на локаль), локалей в `name` | 60; 8 | то же |
| `id` | 64 (упражнение — 51) | `PACK_BAD_ID` |
| События в одном импорте/синхронизации | 5000 записей в массив | `PACK_LIMIT_ITEMS` |

**Только plain text.** Каждая строка отображается как обычный текст: без разбора HTML
и Markdown, без активации ссылок и автооткрытия URL, без встраиваемых изображений
(полей для них нет). Разметка не вычищается молча, а отвергается (`PACK_MARKUP`);
управляющие и bidi-символы отвергаются (`PACK_BAD_CHARS`). Содержимое `imported`/`user`
никогда не интерпретируется как код, шаблон или путь к файлу.

Поток: размер → глубина → парсинг → схема → правила 6.x → предпросмотр
(«новых 40, дублей 3, ошибок 2») → подтверждение → запись одним пакетом с
`packSource = imported`. Дубли — по `id` и `payloadHash`. Откат пака — удалением целиком.

---

## 8. Реализация: что нужно знать автору Dart-кода

- Модели и валидатор — в `tmb_domain`, без `package:flutter/…` (инвариант 1).
- Валидатор — чистая функция `validate(Uint8List bytes, Context) → ValidationResult`;
  `Context` = `{expectedKind, directoryLocale?, supportedVersions, limits}`.
- Один набор golden-файлов: валидные паки из `assets/content/` и набор негативных
  паков по одному на код из раздела 6, чтобы каждый код был покрыт тестом.
- Тест хеша обязан воспроизвести вектор из 3.5.

---

## 9. Принятые решения

Всё ниже выбрано мной там, где требования молчали или допускали два чтения. Каждый
пункт можно оспорить.

1. **`kind` обязателен в каждом документе** (`task_pack`, `exercise_pack`,
   `events_export`). Почему: иначе тип документа приходится угадывать по набору
   ключей. Из-за этого в `uncertainty.pack.json` добавлено `"kind": "task_pack"`.
2. **Общие правила паков имеют префикс `PACK_` для обоих видов паков**, `EX_` — только
   упражнения. Почему: у обоих документов один конвейер импорта и один набор ошибок.
3. **Время — целые мс эпохи UTC** + `Session.utcOffsetMin`. Почему: однозначно,
   сортируется, не зависит от парсинга ISO; смещение нужно для серий по локальным дням.
4. **В записи событий добавлены поля сверх ARCHITECTURE §3**: `Session.template`,
   `Session.utcOffsetMin`; `RoundLog.blockIndex`; `ExerciseSet.sessionId/roundId/setIndex`;
   `TaskAttempt.blockIndex/seed/status/response/encodedRoundIndex`. Почему: сид — иначе
   инвариант 4 не воспроизводим; `blockIndex` — иначе инвариант 5 (блоки) теряется в
   истории; `response` — иначе сервер не пересчитает `isCorrect` (инвариант 8);
   `status` — иначе «пропустил» неотличим от «не оценил»; `encodedRoundIndex` — иначе у
   `delayed_recall` не виден интервал удержания.
5. **`isCorrect` у проверяемой задачи никогда не `null`**: `timeout` и `skipped` —
   `false`. Почему: простое правило «null ⇔ не проверяется машиной», разбор причин — в `status`.
6. **`rpe` — 1…3** (легко/нормально/тяжело), не шкала 1–10. Почему: так записано в
   REQUIREMENTS R5 (одно нажатие).
7. **`payloadHash` считается от определения задачи, а не от показа и не хранится в паке.**
   Без `id`, `domain`, `difficulty`, `reveal`. Почему: перекалибровка сложности (v0.3)
   и перенос в другую категорию не должны менять «ту же задачу»; хранимый хеш мог бы
   разойтись с содержимым.
8. **Числа ограничены** (≤ 6 знаков, без экспоненты). Почему: печать дробных чисел
   отличается между языками; без ограничения хеш не будет одинаковым в Dart и на сервере.
9. **`verifiable` хранится явно, хотя выводится из архетипа.** Почему: фильтры
   разделов и Индекс читают признак напрямую (EXTENSIBILITY §1: «входит в контракт»), а
   несовпадение ловится правилами 31–32.
10. **Поле `packSource` в файле недоверенное**: читатель сам присваивает `imported`
    (импорт) или `user` (редактор); `builtin` — только пакам из бандла приложения. Почему:
    иначе импортированный пак назовёт себя `builtin` и обойдёт D4.
11. **Нет `domain` на уровне пака** (пример в EXTENSIBILITY §4 устарел). Почему: в
    образце `uncertainty.pack.json` домены разные, а `categories` — единственное место
    названий (D2).
12. **`domain` — 2…5 сегментов.** Почему: у каждой категории есть корневой раздел для дерева.
13. **Ошибка задачи исключает задачу, ошибка документа — файл целиком**; встроенные
    паки в CI — сбой при любом `error` и `warning`. Почему: предпросмотр D5 («ошибок 2»)
    предполагает частичный импорт.
14. **`selfCheck` — 2…3 вопроса, `selfRating = floor(3·yes/n + 0.5)`.** Почему: UNCERTAINTY
    называет 2–3 вопроса и шкалу 0–3; формула даёт 0…3 при любом `n`.
15. **Открытые теги `muscleGroups`/`inventory`, закрытые остальные перечисления.** Почему:
    группы мышц и инвентарь будут расти (зал, v0.2), и каждое добавление не должно
    ломать старых читателей; архетипы, единицы, места — не должны.
16. **Название упражнения — карта локаль → строка + `defaultLocale`;** файл лежит в
    `assets/content/ru/`, хотя от языка не зависит. Почему: так задан путь; позже
    перенос в каталог без локали не меняет формат.
17. **Цель — `{min, max}`** (равные — фиксированная), `lockedByUser`, и
    `defaultTargets` по единицам вместо глобального `fixedReps`. Почему: прототип
    знает режимы `fixed` и `range`, одна форма покрывает оба; для планки секунды
    нельзя мерить повторениями.
18. **Тег пути включает потомков по границе сегмента, «пул не пуст» проверяется при
    записи.** Почему: при чтении пустой пул может быть следствием удалённого пака, и
    приложение не должно падать.
19. **Неизвестное поле: warning и отбрасывание; неизвестная версия — отказ целиком.**
    Почему: недоверенный ввод; частично прочитанный документ новой версии вводит в
    заблуждение.
20. **Лимиты раздела 7 — мои числа**, прикинутые под размеры существующих паков
    (17 задач ≈ 16 КиБ; 1 МиБ — запас на ~1000 таких задач, а коротких — на 2000).
21. **`spatial` и `stream` в v1 — статические формы** (фиксированная сетка / последовательность);
    всё процедурное отложено, поле `gen` зарезервировано.
22. **Для `verbal` запрещён `reveal`.** Почему: UNCERTAINTY — после непроверяемой задачи
    показываем чек-лист, не «как надо».
23. **Разметка определяется регуляркой «тег с закрывающей `>`», а не любым `<`.** Почему:
    `a < b` и `x<y` — честный текст задач по математике и коду.
24. **Лимит на пользователя: 50 паков / 20 000 задач** — защита хранилища и
    предпросмотра, не часть схемы.

25. **ГПСЧ — Mulberry32 на 32-битной арифметике (решение владельца, 2026-11-19).**
    Почему: одинаково считается на Dart VM, в вебе (там `int` — 53 бита) и в
    TypeScript-функции на сервере; 64-битные ГПСЧ дали бы расхождения.
    ```
    state  = (seed mod 2^32) XOR fnv1a32(UTF-8(taskId))        // беззнаковое 32-бит
    next() : state = (state + 0x6D2B79F5) mod 2^32
             t = imul(state XOR (state >>> 15), state OR 1)
             t = (t + imul(t XOR (t >>> 7), t OR 61)) XOR t     // всё mod 2^32
             return ((t XOR (t >>> 14)) mod 2^32) / 2^32        // [0, 1)
    ```
    Целое из `[a, b]` включительно: `a + floor(next() × (b − a + 1))`. Для `cues`
    `i`-й подсказки берётся `i`-й вызов `next()` (не меньше, не больше), чтобы
    добавление подсказки в конец не меняло моменты предыдущих. `fnv1a32`: offset
    `0x811C9DC5`, prime `0x01000193`. Реализация обязана иметь тестовые векторы
    (первые пять значений `next()` для `seed = 12345`, `taskId = "unc.rs.001"`),
    посчитанные эталонной реализацией на Python и записанные в тест.

26. **Выбор задачи из пула по сиду** (реализовано в `PackTaskProvider`, фиксируется
    здесь): `Mulberry32.forTask(seed, packId)`; индекс — первое целое из
    `[0, pool.length − 1]`; пул — задачи пака в **порядке файла** после фильтра
    категорий. Следствие: изменение пака или набора включённых категорий меняет задачу
    при том же сиде. Для дуэлей (v0.5) оба участника обязаны иметь один пак и один
    фильтр — понадобится `revision` пака (см. «Остаётся неясным»).
27. **Перемешивание `choice`/`ordering` при показе — не реализовано** (Фаза 1 его не
    требует). Когда понадобится: Fisher–Yates по `Mulberry32.forTask(seed, taskId)`,
    после выбора задачи; `response` записывается по исходному порядку (§3.4).

### Остаётся неясным

- Генераторные провайдеры без пака (арифметика): что писать в `packId`/`taskId` — сейчас
  id провайдера и id шаблона, формат шаблонов — v0.2.
- Доверие к паку из Remote Config: считать ли его `builtin` (и допускать в Индекс) —
  вероятно, только при подписи; не решено.
- Версионирование содержимого пака (`revision`) для обновлений поверх установленного.
- Формат `response` у `stream` и счётчики пропусков/ложных нажатий — v0.2.
- Названия упражнений на `uk` — нужны переводчику, в базовом паке только `ru`.

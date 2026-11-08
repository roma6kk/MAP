# Разбор вёрстки «Delivery App» — объяснение для новичка в Dart

> **Перед началом: 4 идеи, без которых ничего не понять.**
>
> 1. **В Flutter интерфейс — это не разметка (как HTML), а обычные объекты.** Кнопка — объект, текст — объект, экран — объект, содержащий другие объекты. Такое «объект внутри объекта» называется **деревом виджетов** (widget tree). Вёрстка = построение этого дерева.
> 2. **Виджет — это класс в Dart.** Каждый элемент интерфейса описан своим классом. Чтобы нарисовать что-то, Flutter вызывает у класса метод `build()`, который возвращает «из чего я состою».
> 3. **Виджеты бывают «постоянные» и «меняющиеся»:**
>    - `StatelessWidget` — не имеет своего состояния: одинаковые данные на входе → одинаковая картинка. Например, карточка товара.
>    - `StatefulWidget` — имеет изменяемое состояние (например, «какая вкладка открыта»). При изменении состояния Flutter перерисовывает экран.
> 4. **Всё в Dart можно передавать в переменные, включая функции.** Поэтому «что делать при нажатии» передаётся как параметр-функция (колбэк).

Структура проекта:

```
lib/
├── main.dart                  — точка входа: какой экран показать и как переключаться
├── theme.dart                 — «справочник»: все цвета и пути к картинкам в одном месте
└── iscreens/
    ├── home_screen.dart       — главный экран (список посылок + плавающая навигация)
    └── tracking_screen.dart   — экран трекинга (карта + тёмная «шторка» с деталями)
```

---

## 1. Мини-словарь Dart (всё, что встретится в коде)

| Что видишь           | Что это значит простыми словами                                                                                                                                                                                   |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `class Foo { ... }`         | Описание нового типа — «чертёж» объекта. Виджеты — тоже классы                                                                                                                           |
| `extends Bar`               | Наследование: «Foo — разновидность Bar»                                                                                                                                                                          |
| `@override`                 | Подсказка компилятору: «я заменяю метод родителя». Так переопределяется`build()`                                                                                             |
| `void`                      | «Функция ничего не возвращает»                                                                                                                                                                                    |
| `main()`                    | Точка входа — отсюда программа стартует                                                                                                                                                                    |
| `final x = 5;`              | Переменная, которую нельзя изменить после присваивания                                                                                                                                       |
| `const x = 5;`              | Константа, известная ещё**до запуска** программы. Flutter любит `const`: такие куски интерфейса не пересоздаются — быстрее работает   |
| `static`                    | Принадлежит классу, а не объекту:`AppColors.orange` доступен без создания объекта                                                                                                     |
| `Foo? x`                    | **Nullable**: вместо объекта может лежать «ничего» (`null`). `VoidCallback? onBack` = «колбэк могут и не передать»                                                         |
| `x?.call()`                 | Безопасный вызов: «если x не null — вызови, иначе ничего не делай»                                                                                                                           |
| `x ?? y`                    | «Возьми x, а если он null — возьми y»                                                                                                                                                                                  |
| `{required this.label}`     | **Именованный параметр**, который обязательно передать: `_GreyPill(label: 'Transit')`. Именованные параметры пишутся через `имя: значение` |
| `{super.key}`               | Короткая запись Dart 2.17+ для передачи служебного идентификатора`key` родителю. Есть почти в каждом конструкторе — просто запомните  |
| `(i) => выражение` | Лямбда — анонимная функция «на месте».`(i) => setState(() => _index = i)` = «функция, получающая i и меняющая _index»                                                          |
| `a..b = 1..c = 2`           | **Каскад**: серия действий над одним объектом. `Paint()..color = red..strokeWidth = 2` = создать краску, задать ей цвет и толщину                                |
| `условие ? a : b`    | Тернарный оператор — короткое «если-иначе». В Flutter им часто выбирают виджет:`done ? Icon(галка) : null`                                                                 |
| `_имя`                   | **Приватность**: `_Header`, `_index` видны только внутри своего файла                                                                                                                       |
| `List<Widget>`              | Список (массив) виджетов — то, что кладут в`children: [...]`                                                                                                                                              |
| `=> false`                  | Короткая запись функции из одного выражения: то же, что`{ return false; }`                                                                                                                    |

---

## 2. `theme.dart` — константы: цвета и картинки

```dart
class AppColors {
  AppColors._();                            // 1
  static const orange = Color(0xFFFF6B2B);  // 2
  static const textDark = Color(0xFF17181C);
  static const navDark = Color(0xFF17181D);
  // ... остальные цвета
}
```

1. `AppColors._()` — конструктор с приватным именем (из-за `_`). Класс с таким конструктором **нельзя создать** через `AppColors()`. Это просто «контейнер констант», а не объект — так и задумано.
2. `Color(0xFFFF6B2B)` — цвет в виде ARGB-числа: `FF` — непрозрачность, `FF6B2B` — оранжевый. `static const` = константа уровня класса: пишем `AppColors.orange` откуда угодно, объект создавать не нужно.

```dart
class AppImages {
  AppImages._();
  static const truckRed = 'assets/images/truck_red.png';
  // ... пути к остальным картинкам
}
```

Просто строки-пути к картинкам из `assets/images/` (папка подключена в `pubspec.yaml`). Пишем `Image.asset(AppImages.truckRed)` — картинка загружается.

```dart
class AppTheme {
  AppTheme._();
  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, scaffoldBackgroundColor: Colors.white, fontFamily: 'Roboto');
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(primary: AppColors.orange, surface: Colors.white),
      textTheme: base.textTheme.apply(bodyColor: AppColors.textDark, displayColor: AppColors.textDark),
    );
  }
}
```

`static ThemeData get light` — статический **геттер**: обращаемся как к переменной (`AppTheme.light`), но код выполняется при обращении. Логика: берём стандартную тему Flutter (`ThemeData`) и методом `copyWith` заменяем только нужное — основной цвет и цвет текста. `copyWith` — частейший паттерн Flutter: «скопируй объект, поменяв эти поля».

**Зачем этот файл:** цвета не разбросаны по коду магическими числами, а собраны в одном месте. Поменяли `orange` здесь — поменялось во всём приложении.

---

## 3. `main.dart` — точка входа и переключение экранов

```dart
void main() {
  runApp(const DeliveryApp());   // runApp говорит Flutter: «вот корень интерфейса, рисуй»
}
```

### 3.1. `DeliveryApp` — корневой виджет

```dart
class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Delivery App',
      theme: AppTheme.light,          // наша тема из theme.dart
      home: const DeliveryAppShell(), // первый экран
    );
  }
}
```

- `extends StatelessWidget` — «это виджет без состояния».
- `build(BuildContext context)` — единственный обязательный метод любого виджета: «возврати то, из чего ты состоишь». Flutter вызывает его сам, когда нужно нарисовать/перерисовать экран.
- `MaterialApp` — готовый «каркас приложения»: тема, заголовок, стартовый экран (`home`).

### 3.2. `DeliveryAppShell` — переключатель экранов

```dart
class DeliveryAppShell extends StatefulWidget {
  const DeliveryAppShell({super.key});

  @override
  State<DeliveryAppShell> createState() => _DeliveryAppShellState();
}

class _DeliveryAppShellState extends State<DeliveryAppShell> {
  int _index = 0;   // 0 = главный экран, 1 = трекинг

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _index,
      children: [
        HomeScreen(onTab: (i) => setState(() => _index = i)),
        TrackingScreen(onBack: () => setState(() => _index = 0)),
      ],
    );
  }
}
```

- **StatefulWidget всегда состоит из двух классов**: сам виджет (неизменяемое «описание») и `State` (изменяемое состояние). `createState()` связывает их.
- `int _index = 0` — переменная состояния. Приватная (`_`), снаружи она не нужна.
- **`IndexedStack`** — контейнер, который держит **все** дети, но показывает только одного — по номеру `index`. Аналог вкладок браузера: вкладки открыты, видна одна. Плюс: состояние каждого экрана сохраняется.
- **`setState(...)`** — команда «состояние изменилось, перерисуй меня». Без неё Flutter не узнал бы об изменении `_index`.
- `(i) => setState(() => _index = i)` — лямбда: функция, которую мы **передаём в HomeScreen**. Когда пользователь нажмёт вкладку, HomeScreen вызовет её, передав номер вкладки `i`.

Как работает навигация (важно!):

1. Главный экран получил функцию `onTab` при создании.
2. Пользователь тапнул «Shipment» в навбаре → сработал `onTab?.call(1)`.
3. Выполнилось замыкание: `setState(() => _index = 1)`.
4. Flutter перерисовал `IndexedStack` — теперь виден `TrackingScreen`.
5. На трекинге кнопка «назад» вызывает `onBack` → `_index = 0` → снова главный экран.

Здесь **нет** системного стека страниц (`Navigator`): переключение сделано вручную через состояние.

---

## 4. `home_screen.dart` — главный экран

### 4.1. Базовые «кирпичи», которые тут используются

Прежде чем читать код — что означает каждый виджет:

| Виджет                        | Простыми словами                                                                                                                                                                                 |
| ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Scaffold`                        | «Каркас экрана»: даёт фон, место под тело (`body`), панели                                                                                                             |
| `Container`                       | «Коробка с оформлением»: цвет, рамка, скругление, тень, отступы. Универсальный блок вёрстки                                          |
| `Row` / `Column`                | Раскладка детей**в строку** / **в столбик**. Аналог flexbox                                                                                                      |
| `Stack`                           | Наложение: дети рисуются друг на друге, как слои в Photoshop                                                                                                            |
| `Positioned`                      | Ребёнок внутри`Stack` с точными координатами (left/top/right/bottom)                                                                                                         |
| `Padding`                         | Отступы вокруг ребёнка                                                                                                                                                                      |
| `SizedBox(width, height)`         | Пустышка фиксированного размера. Часто используется как «пробел» между виджетами                                                         |
| `Spacer`                          | Распорка, которая съедает всё свободное место в`Row`/`Column` (как `margin-left: auto`)                                                                        |
| `Expanded`                        | «Займи всё оставшееся место» внутри`Row`/`Column`. Слева Expanded + справа фиксированный элемент = «резиновый» левый блок |
| `SafeArea`                        | Отодвигает контент от вырезов/чёлки телефона                                                                                                                             |
| `ListView`                        | Прокручиваемый список (Column + скролл)                                                                                                                                               |
| `Text`                            | Текст с параметрами стиля (`fontSize`, `fontWeight`, `color`)                                                                                                                       |
| `Icon(Icons.home)`                | Векторная иконка из набора Material                                                                                                                                                      |
| `Image.asset('путь')`         | Картинка из assets                                                                                                                                                                                    |
| `ClipRRect` / `ClipOval`        | Обрезка ребёнка по скруглённым углам / по овалу                                                                                                                          |
| `InkWell` / `GestureDetector`   | Делают ребёнка кликабельным (InkWell — с ripple-эффектом)                                                                                                                    |
| `FittedBox`                       | Автоматически уменьшает текст/ребёнка, если он не влезает                                                                                                      |
| `CustomPaint` + `CustomPainter` | «Холст»: рисуем что хотим сами (здесь — пунктирные линии)                                                                                                         |

### 4.2. Скелет экрана

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onTab});   // onTab — функция, может не прийти
  final ValueChanged<int>? onTab;              // ValueChanged<int> = «функция, принимающая int»

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(bottom: false, child: ListView(...)),   // слой 1: прокручиваемый контент
          Positioned(left: 0, right: 0, bottom: 10,
            child: FloatingNavBar(onTab: onTab)),          // слой 2: плавающий навбар
          const Positioned(... child: _HomeIndicator()),   // слой 3: полоска home-индикатора
        ],
      ),
    );
  }
}
```

Идея: `Stack` кладёт три «слоя» друг на друга — контент прокручивается, а навбар висит поверх него внизу экрана. Внутри `ListView` — весь контент по вертикали; между блоками вставлены `SizedBox(height: 16)` — это «пустые пробелы-отступы».

Классы с `_` в начале (`_Header`, `_SearchBar`...) — **внутренние детали экрана**: снаружи их никто не использует, поэтому они приватны для файла.

### 4.3. `_Header` — шапка

```dart
Row(children: [
  Icon(Icons.local_shipping_outlined),            // иконка грузовика
  SizedBox(width: 10),                            // пробел
  Column(                                         // два текста столбиком
    crossAxisAlignment: CrossAxisAlignment.start, // выравнивание по левому краю
    children: [ Text('Delivery to'), Text('1/12 Diriyah, Riyadh') ],
  ),
  Spacer(),                                       // съедает всё место посередине
  Stack(clipBehavior: Clip.none, children: [      // иконка уведомлений с точкой-бейджем
    Icon(Icons.notifications_none_rounded),
    Positioned(right: 1, top: 0,
      child: Container(width: 7, height: 7,
        decoration: BoxDecoration(color: AppColors.orange, shape: BoxShape.circle))),
  ]),
])
```

Точка над иконкой — это маленький оранжевый `Container`, положенный **поверх** иконки через `Stack` + `Positioned`. `clipBehavior: Clip.none` разрешает ребёнку выступать за границы стека.

Здесь видны поля-данные и конструктор с параметрами:

```dart
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});  // обязательный именованный параметр
  final String title;                           // данные, которые хранит виджет
  ...
}
```

### 4.4. `_SearchBar` — поисковая строка

`Row`: слева **`Expanded`** → «резиновая» капсула (`Container` со скруглением 26, рамкой и тенью), справа — круглый тёмный `Container` 52×52. Приём: `Expanded` забирает всё свободное место, а сосед берёт ровно свой размер. Оформление задаётся через `decoration: BoxDecoration(...)` — так делаются цвета, скругления, рамки, тени.

### 4.5. `_QuickActions` — зона с картинками

```dart
SizedBox(height: 112, child: Stack(clipBehavior: Clip.none, children: [
  const Positioned(left: 32, top: 22, child: _QuickLabel('New\nDelivery')),
  Positioned(left: 82, top: 0, child: Image.asset(AppImages.truckRed, width: 108)),
  ...
]))
```

Картинки и подписи разложены по точным координатам внутри `Stack` — «дизайнерская» зона, где важны пиксели. `\n` внутри строки — перенос текста на новую строку.

### 4.6. `_CurrentShipmentCard` — карточка текущей посылки

Обёртка: `ClipRRect` (обрезает по скруглённым углам) → `Stack`:

- нижний слой — белая карточка (`Container` с рамкой и скруглением), внутри `Column`:
  - строка товара: миниатюра `_ProductThumb` (42×42), `Expanded` с ID и названием, серая «пилюля» `_GreyPill('Transit')`;
  - `_ShipmentProgress` — прогресс-доставка;
  - `Row` из двух колонок с датами и городами.
- верхний слой — `Positioned(right: -14, ...)` картинка коробки, **заезжающая за правый край**. Отрицательное значение — выступ за границу; чтобы торчащий край обрезался ровно по скруглению, снаружи стоит `ClipRRect`.

> **Частый вопрос: почему `ClipRRect` только здесь, если все карточки скруглены?**
> Скругление карточек делает не `ClipRRect`, а `borderRadius` в `BoxDecoration` — он есть у всех карточек (`_RecentCard` — 18, навбар — 30 и т.д.) и рисует фон/рамку по скруглённому прямоугольнику. Но `BoxDecoration` **не обрезает детей**: если ребёнок вылезает за границу, он рисуется поверх. В `_CurrentShipmentCard` такой ребёнок есть — картинка коробки с `right: -14`. `Stack` по умолчанию режет детей по прямому прямоугольнику (`Clip.hardEdge`), поэтому снаружи добавлен `ClipRRect(20)`, который обрезает содержимое точно по скруглённому контуру. В остальных карточках дети за границы не выходят (обрезать нечего), а их картинкам скругление даётся отдельно: `ClipOval` у аватара `_RecentCard`, `ClipRRect` внутри `_ProductThumb`, `CircleAvatar` у курьера.
>
> Правило: `BoxDecoration.borderRadius` — «нарисуй фон/рамку скруглёнными», `ClipRRect` — «обрежь содержимое по скруглённому прямоугольнику».

`_GreyPill` — типичный маленький переиспользуемый виджет:

```dart
class _GreyPill extends StatelessWidget {
  const _GreyPill({required this.label});   // что показать — передают снаружи
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.pillGreyBg,
        borderRadius: BorderRadius.circular(20),   // половина высоты = «пилюля»
      ),
      child: Text(label, ...),
    );
  }
}
```

### 4.7. Прогресс-бар и `CustomPainter` — рисуем пунктир сами

Прогресс — это `Row`, чередующий точки и пунктирные сегменты:

```dart
Row(children: const [
  _ProgressNode(done: true), _DottedSegment(done: true),
  _ProgressNode(done: true), _DottedSegment(done: true),
  _TruckNode(),                                    // текущая позиция — грузовик
  _DottedSegment(done: false),
  _ProgressNode(done: false),
])
```

Пунктир — не готовый виджет, его рисуют вручную через **`CustomPainter`** («холст» с краской):

```dart
class _DottedLinePainter extends CustomPainter {
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {   // сюда Flutter даёт холст и доступную площадь
    final paint = Paint()
      ..color = color            // каскад: задали цвет
      ..strokeWidth = 1.6;       // и толщину линии
    const dotRadius = 1.0, gap = 4.0;
    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {     // идём слева направо и рисуем точки-кружочки
      canvas.drawCircle(Offset(x + dotRadius, y), dotRadius, paint);
      x += dotRadius * 2 + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false; // «перерисовывать не нужно»
}
```

В `_ProgressNode` — условная вёрстка тернарником:

```dart
child: done
    ? const Icon(Icons.check_rounded, size: 7, color: Colors.white)  // если пройдено — галка
    : null,                                                          // иначе — ничего
```

Над баром подпись «4h Away» висит через `Positioned(top: -12)` — **отрицательный** отстав, т.е. текст выступает за верх стека.

Ширина трека не фиксирована: `_ShipmentProgress` растягивается на всю доступную ширину (`width: double.infinity`), а справа и трек, и ряд подписей с датами отступают на одну и ту же константу `_artworkReserve` (108). Благодаря этому первая точка стоит ровно по левому паддингу карточки, подпись «Estimated …» — точно под грузовиком, а последняя (пустая) точка заканчивается перед иллюстрацией коробки, а не уезжает под неё.

### 4.8. `_RecentCard` — карточки недавних посылок

Один класс — три карточки в списке (Mac Mini, Speaker, Drone). Виджет получает данные снаружи:

```dart
_RecentCard(image: AppImages.macMini, id: 'ID: H314315796',
            name: 'Mac Mini M4 Pro', status: 'On Process'),
```

Внутри: `Row` [ `ClipOval`-аватар картинки 44×44, `Expanded` колонка (ID + название), `_GreyPill(status)` ]. Это главная идея композиции: **описал виджет один раз — используй сколько угодно раз с разными данными**.

### 4.9. `FloatingNavBar` — тёмная плавающая навигация

`Container` высотой 66 со скруглением 30 и тенью, внутри `Row` из **`Expanded`-элементов** (все вкладки делят ширину поровну):

- `_NavActiveItem` — активная вкладка: белая плитка с иконкой и подписью;
- `_NavItem` — обычная вкладка, обёрнута в `InkWell` (кликабельность + ripple):

```dart
InkWell(
  onTap: onTap,                          // то, что делать при нажатии — приходит снаружи
  borderRadius: BorderRadius.circular(20),
  child: Column(children: [ Icon(...), Text(label) ]),
)
```

- `_NavPlus` — оранжевая круглая кнопка «+» на `GestureDetector` (клик без ripple-эффекта).

Замыкание цепочки: навигация вызывает `onTab?.call(1)` → это та самая функция из `main.dart` → `_index = 1` → показывается экран трекинга.

---

## 5. `tracking_screen.dart` — экран трекинга

### 5.1. Скелет: `Column` с одним `Expanded`

```dart
Scaffold → SafeArea → Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
  _Header(onBack: onBack),
  SizedBox(height: 12),
  const Expanded(child: _MapArea()),   // карта занимает ВСЁ свободное место по высоте
  const _DetailsSheet(),               // шторка — высота ровно по содержимому
])
```

Распределение высоты: всё, что не занято шапкой и шторкой, съедает `Expanded` — там живёт карта. `CrossAxisAlignment.stretch` растягивает детей на всю ширину.

### 5.2. `_Header` — кнопка «назад» + заголовок

Приём «кнопка — заголовок — кнопка»:

```dart
Row(children: [
  GestureDetector(onTap: onBack, child: Container(  // круглая стрелка «назад»
    width: 38, height: 38,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [...]),
    child: Icon(Icons.arrow_back_rounded),
  )),
  const Expanded(child: Text('Location Tracking', textAlign: TextAlign.center)),
  const SizedBox(width: 38, child: Icon(Icons.more_vert_rounded)),  // «меню» (заглушка)
])
```

`Expanded` по центру держит заголовок ровно посередине, даже если боковые элементы разной ширины. Стрелка вызывает `onBack` — ту функцию из `main.dart`, которая возвращает на главный экран.

### 5.3. `_MapArea` — карта

```dart
Image.asset(AppImages.mapBase, fit: BoxFit.fill, alignment: Alignment.topCenter);
```

Карта здесь — просто картинка-заглушка из assets, растянутая на весь `Expanded` (`BoxFit.fill` — «растяни, заполнив всю область»).

### 5.4. `_DetailsSheet` — тёмная «шторка» с деталями

`Container` с тёмным фоном и скруглением **только сверху** (`BorderRadius.vertical(top: Radius.circular(28))`). Внутри `Column(mainAxisSize: MainAxisSize.min)` — «займи минимум высоты, по контенту», а не весь экран. Содержимое сверху вниз:

1. **«Ручка» шторки** — серый прямоугольник 44×4 по центру.
2. **Booking Id / Status** — `Row` из двух `Expanded`-колонок; статус — `_StatusPill`, тёмная «пилюля» с текстом «Transit». В правой ячейке `Align(alignment: Alignment.topRight)` прижимает к правому краю колонку `Column(crossAxisAlignment: CrossAxisAlignment.start)`: подпись «Status:» и «пилюля» получают **общий левый край** (в референсе «Transit» стоит ровно под «Status:»), а сама «пилюля» остаётся прижатой к правому отступу шторки — её положение не меняется.
3. **`_Checkpoints`** — горизонтальный степпер доставки:

```dart
SizedBox(height: 30, child: Row(children: const [
  _Checkpoint(current: true), Expanded(child: _DashLine()),
  _Checkpoint(),              Expanded(child: _DashLine()),
  _Checkpoint(),              Expanded(child: _DashLine()),
  _Checkpoint(),
]))
```

Активный чекпоинт — белый круг с тёмной галкой, остальные — тёмно-серые круги (выбор через тернарник: `current ? белый : серый`). Между чекпоинтами — пунктир, который опять рисует `CustomPainter` (`_DashLinePainter`): в цикле `while` рисуются короткие отрезки `canvas.drawLine(...)`.

4. **Блок данных** — `Stack`: справа `Positioned`-картинка коробки, основной контент сдвинут `Padding(right: 96)`, чтобы не налезал на неё. Данные — три строки по два поля; каждая строка — `Row` из двух `Expanded`-колонок с виджетом `_Col`:

```dart
Row(children: [
  Expanded(child: _Col(label: 'From', value: 'Diriyah, Riyadh')),
  SizedBox(width: 12),
  Expanded(child: _Col(label: 'To', value: 'Jawhra, Jeddah')),
])
```

В `_Col` важный приём — **`FittedBox(fit: BoxFit.scaleDown)`**: если текст не влезает в свою колонку, он автоматически уменьшится, не сломав вёрстку. Параметр `alignEnd` включает выравнивание по правому краю (тоже тернарником: `alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start`).

5. **Курьер** — `Row` [ `CircleAvatar` с фото (круглая картинка), `Expanded` с именем и должностью, две круглые кнопки `_RoundAction`: оранжевая «позвонить» и белая «чат» ]. Имя задано с `maxLines: 1, overflow: TextOverflow.ellipsis` — если длинное, обрежется многоточием.
6. `_SheetHomeIndicator` — белая полоска home-индикатора внизу шторки.

---

## 6. Как это читать целиком (сюжет приложения)

1. `main()` запускает `DeliveryApp` → `MaterialApp` с темой и `DeliveryAppShell`.
2. `DeliveryAppShell` — StatefulWidget, хранит `_index` и через `IndexedStack` показывает один из двух экранов.
3. На **главном экране** (`HomeScreen`): `Stack` из прокручиваемого `ListView` (шапка → поиск → картинки → карточка текущей посылки с прогресс-баром → три карточки недавних) и плавающего тёмного навбара. Навбар — `Row` из кликабельных вкладок (`InkWell`) и кнопки «+».
4. Тап по «Shipment» → `onTab?.call(1)` → `setState` в `main.dart` → `IndexedStack` показывает `TrackingScreen`.
5. **Экран трекинга**: сверху заголовок с кнопкой «назад», посередине карта (`Expanded`), снизу тёмная шторка с ID посылки, степпером-чекпоинтами, таблицей «откуда/куда/клиент/цена» и карточкой курьера.
6. Кнопка «назад» → `onBack` → `_index = 0` → снова главный экран.

## 7. Языковые особенности Dart в проекте (шпаргалка для защиты)

| Фича                                                | Пример из кода                        | Объяснение                                                                                                                                  |
| ------------------------------------------------------- | ------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| Классы-виджеты                             | `class HomeScreen extends StatelessWidget`      | Вся «вёрстка» — классы, переопределяющие`build()`                                                                |
| Двухчастный StatefulWidget                   | `DeliveryAppShell` + `_DeliveryAppShellState` | Описание отдельно, изменяемое состояние отдельно                                                           |
| `setState`                                            | `setState(() => _index = 1)`                    | «Состояние изменилось — перерисуй»                                                                                     |
| Именованные параметры +`required` | `_GreyPill({required this.label})`              | Понятные вызовы:`_GreyPill(label: 'Transit')`                                                                                         |
| Nullable-типы                                       | `final VoidCallback? onBack;`                   | Колбэк может не прийти                                                                                                             |
| Null-aware вызов                                   | `onTab?.call(1)`                                | Вызови, только если не null                                                                                                         |
| Приватность`_`                             | `_Header`, `_index`, `AppColors._()`        | Видимость только внутри файла; приватный конструктор запрещает создавать объект |
| `static const`                                        | `AppColors.orange`                              | Константы уровня класса, известны до запуска                                                                    |
| Геттер                                            | `static ThemeData get light`                    | Читается как поле, вычисляется при обращении                                                                    |
| `const`-виджеты                                | `children: const [...]`                         | Кэширование поддеревьев — быстрее перерисовка                                                                |
| Лямбды/замыкания                         | `(i) => setState(() => _index = i)`             | Функции как параметры: колбэки «вниз», события «вверх»                                                  |
| Тернарный оператор                     | `done ? Icon(галка) : null`                | Условный виджет (или «нет виджета»)                                                                                      |
| Каскад`..`                                      | `Paint()..color = ... ..strokeWidth = ...`      | Несколько присваиваний одному объекту подряд                                                                  |
| Типы-функции                                 | `ValueChanged<int>`, `VoidCallback`           | Типизация колбэков: «функция, принимающая int» / «без аргументов»                                 |
| `covariant`                                           | `shouldRepaint(covariant CustomPainter old)`    | Позволяет сузить тип параметра при переопределении                                                       |

## 8. Паттерны вёрстки Flutter, использованные в лабе

1. **Композиция**: экран = `Scaffold`, блоки = `Row/Column/Stack`, стиль = `Container + BoxDecoration`, отступы = `Padding`/`SizedBox`.
2. **Гибкая раскладка**: `Expanded`/`Spacer` — растянуть, `FittedBox` — уместить текст.
3. **Наложения**: `Stack` + `Positioned` — плавающий навбар, бейдж, картинка за краем (отрицательные координаты + `ClipRRect`).
4. **Скролл**: `ListView` + `SafeArea`.
5. **Кастомная графика**: пунктир через `CustomPainter`.
6. **Навигация без `Navigator`**: `StatefulWidget` + `IndexedStack` + колбэки.
7. **Константы в `theme.dart`**: цвета и ассеты в одном месте, тема через `ThemeData.copyWith`.

*Порядок рассказа на защите: `main.dart` → `theme.dart` → `home_screen.dart` (сверху вниз по списку) → `tracking_screen.dart` (сверху вниз по колонке).*

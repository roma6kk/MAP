# Лабораторная работа № 6 — Navigation. Method Channel

Вариант 1. Продолжение лабораторных 4–5 («Delivery App»).

## 1. Что сделано

| Требование задания                                                                                                                          | Где реализовано                                                                                                                                                  |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Логика переходов через`Navigator`                                                                                                      | `lib/main.dart` (`onGenerateRoute`), `lib/app_routes.dart`                                                                                                               |
| Не менее 3 переходов с передачей данных с первой страницы на страницу деталей                | Главный экран → детали (`pushNamed` с `arguments: Shipment`): карточка текущей посылки, две карточки недавних |
| Не менее 3 методов навигации                                                                                                          | `pushNamed`, `pushReplacementNamed`, `pushNamedAndRemoveUntil`, `pop` с результатом                                                                        |
| Передача данных через`pop`                                                                                                              | Экран деталей → «Изменить статус» →`Navigator.pop(context, status)` → главный экран обновляет карточку           |
| `PageView` на одном из экранов                                                                                                             | Экран деталей: карусель из трёх изображений с индикатором                                                                     |
| Platform Method Channel (вариант 1: датчик освещённости)                                                                            | `lib/screens/device_screen.dart`, `lib/platform/native_channels.dart`, `android/.../MainActivity.kt`                                                                     |
| Канал, передающий данные для запуска встроенного приложения (вариант 1: почта с темой) | Канал`lab06/apps`: Android `ACTION_SENDTO` + `EXTRA_SUBJECT`, iOS `mailto:?subject=`                                                                              |
| Два канала для получения заряда батареи, показать разницу                                                   | Канал`lab06/battery`: Android `BatteryManager`, iOS `UIDevice.batteryLevel` (разница выводится на экране)                                   |
| Получение фото с камеры и отображение на экране                                                                      | Пакет`image_picker` на экране «Device Features»                                                                                                               |
| Смена иконки приложения                                                                                                                 | Пакет`flutter_launcher_icons`, исходник `assets/icon/app_icon.png`                                                                                            |

### Структура

```
lib/
├── main.dart                         — MaterialApp, onGenerateRoute
├── app_routes.dart                   — имена маршрутов
├── theme.dart                        — цвета и пути к картинкам
├── models/
│   └── shipment.dart                 — модель посылки, передаётся между экранами
├── platform/
│   └── native_channels.dart          — Dart-обёртка над MethodChannel
└── screens/
    ├── home_screen.dart              — главный экран (стал StatefulWidget)
    ├── shipment_details_screen.dart  — детали: PageView, pop с результатом, pushReplacement
    ├── tracking_screen.dart          — трекинг: получает bookingId, pop назад, pushAndRemoveUntil
    └── device_screen.dart            — датчик, батарея, почта, камера
android/app/src/main/kotlin/com/example/lab_06/MainActivity.kt — каналы Android
ios/Runner/AppDelegate.swift                                  — каналы iOS
assets/icon/app_icon.png                                      — исходник иконки
```

## 2. Навигация

Используется `MaterialApp(initialRoute: '/', onGenerateRoute: ...)`. Маршруты задаются строками из `AppRoutes`, аргументы передаются через `arguments`.

| Метод                        | Где вызывается                                                           | Что демонстрирует                                                                           |
| --------------------------------- | ------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `pushNamed`                     | Главный экран → детали, → трекинг, → устройство | Добавление маршрута поверх стека и передача данных              |
| `pushNamed<String>` + `await` | Главный экран ← детали                                             | Получение результата, переданного через`pop`                           |
| `pop(result)`                   | Детали → «Изменить статус» (выбор в bottom sheet)        | Передача результата назад на главный экран                             |
| `pushReplacementNamed`          | Детали → «Открыть трекинг (replace)»                           | Замена текущего экрана, назад из трекинга ведёт на главный |
| `pushNamedAndRemoveUntil`       | Трекинг → меню «На главный экран»                         | Очистка стека до главного экрана                                                |
| `pop()`                         | Кнопка «назад» на трекинге                                     | Возврат без данных                                                                          |

Передача данных на детали: главный экран отправляет объект `Shipment` (id, название, статус, картинка). Экран деталей показывает именно эти данные. Трекинг получает `bookingId` строкой.

Ограничение: `pushNamedAndRemoveUntil` создаёт главный экран заново, поэтому изменённый статус сбрасывается к исходному. Это следствие стека, а не ошибка.

## 3. Platform Method Channel

| Канал        | Метод          | Android                                                                   | iOS                                                                                                    |
| ----------------- | ------------------- | ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `lab06/sensors` | `getLightLevel`   | `SensorManager`, `Sensor.TYPE_LIGHT`, возвращает люксы | `UNSUPPORTED`: публичного API для датчика освещённости в iOS нет |
| `lab06/battery` | `getBatteryLevel` | `BatteryManager.BATTERY_PROPERTY_CAPACITY`                              | `UIDevice.current.batteryLevel` с включённым `isBatteryMonitoringEnabled`               |
| `lab06/apps`    | `openMail`        | `Intent.ACTION_SENDTO` с `mailto:` и `EXTRA_SUBJECT`              | `UIApplication.open` с `mailto:?subject=`                                                         |

Разница для батареи:

- Android отдаёт уровень сразу через `BatteryManager.getIntProperty`, работает в симуляторе и на устройстве.
- iOS требует включить мониторинг батареи, отдаёт долю 0.0–1.0 (код переводит в проценты), в симуляторе значение недоступно (`-1`).

Для датчика освещённости iOS не поддерживается, поэтому на iOS канал возвращает ошибку `UNSUPPORTED` с объяснением, и экран показывает этот текст.

Для вызова в Dart используется `invokeMethod` и `invokeMapMethod`. Значения возвращаются в виде `double`, `int`, `String`, `bool`, `Map`. Ошибки приходят как `PlatformException`, их перехватывает экран. Для датчика стоит таймаут 3 секунды, чтобы не ждать вечно на устройстве без показаний.

## 4. Камера и иконка

- Камера: `ImagePicker().pickImage(source: ImageSource.camera)`. Разрешения: в `Info.plist` добавлены `NSCameraUsageDescription` и `NSPhotoLibraryUsageDescription`. На Android отдельное разрешение не нужно, камера открывается системным интентом.
- Иконка: `flutter_launcher_icons` берёт `assets/icon/app_icon.png` (1024×1024) и создаёт иконки для Android и iOS. Конфиг находится в `pubspec.yaml`, в блоке `flutter_launcher_icons`.

## 5. Как запустить и сдать

1. Установить зависимости:

```bash
flutter pub get
```

2. Сгенерировать иконки (после изменения `app_icon.png`):

```bash
dart run flutter_launcher_icons
```

3. Запустить приложение на Android-устройстве или эмуляторе:

```bash
flutter run
```

4. Проверить тесты:

```bash
flutter test
```

Если golden-скриншоты не совпали из-за новых элементов, их можно перегенерировать:

```bash
flutter test --update-goldens
```

5. Для сдачи: проверить работу каждого пункта по разделу 1, показать переходы, pop с результатом, `PageView`, значение датчика освещённости (Android), почту с темой, заряд батареи, фото с камеры и новую иконку.

## 6. Ответы на вопросы

1. **Основные методы Navigator.** `push`, `pushNamed`, `pop`, `pushReplacement` (`pushReplacementNamed`), `pushAndRemoveUntil` (`pushNamedAndRemoveUntil`), `popUntil`, `maybePop`, `canPop`.
2. **push, pushReplacement, pushAndRemoveUntil.** `push` кладёт новый маршрут поверх текущего. `pushReplacement` заменяет текущий маршрут новым. `pushAndRemoveUntil` добавляет новый маршрут и удаляет все маршруты, пока предикат не вернёт `true`.
3. **Передача данных и возврат результата.** Данные передаются через конструктор целевого экрана или через `arguments` при `pushNamed`. Результат возвращается через `Navigator.pop(context, value)`. Вызывающий код получает его через `await Navigator.push...`.
4. **Виды route.** `MaterialPageRoute` (переход в стиле Android), `CupertinoPageRoute` (стиль iOS), `PageRouteBuilder` (своя анимация), `ModalRoute` (диалоги, bottom sheet). Все они наследуют `Route`.
5. **Именованные маршруты и onGenerateRoute.** Именованный маршрут задаётся строкой и регистрируется в `routes` или в `onGenerateRoute`. Анонимный маршрут создаётся в коде через `MaterialPageRoute(builder: ...)`. `onGenerateRoute` вызывается для любого имени, которого нет в `routes`, и возвращает `Route` с нужным экраном и аргументами. В проекте используется именно он.
6. **Platform Method Channel.** Это канал связи Dart с нативным кодом (Kotlin/Swift). Нужен, чтобы получить данные и функции, недоступные в Flutter: датчики, батарея, запуск других приложений.
7. **MethodChannel, EventChannel, BasicMessageChannel.** `MethodChannel` выполняет разовый вызов метода с ответом. `EventChannel` передаёт поток событий от нативной стороны (например, показания датчика). `BasicMessageChannel` обменивается сообщениями без имени метода, с выбранным кодеком.
8. **Типы данных.** `null`, `bool`, `int`, `double`, `String`, `Uint8List` и другие типизированные списки, `List`, `Map` со строковыми ключами. Остальные типы нужно кодировать самостоятельно.
9. **Валидация вызова.** Нативная сторона проверяет `call.method` и отвечает `notImplemented` на неизвестные методы. Аргументы берутся через `call.argument<T>` с проверкой типа. Ошибки возвращаются через `result.error`. На стороне Dart отсутствие канала даёт `MissingPluginException`.
10. **Android и iOS.** На Android канал регистрируется в `configureFlutterEngine` у `FlutterActivity`, код пишется на Kotlin. На iOS канал регистрируется в `AppDelegate` через `FlutterPluginRegistry`, код на Swift. Различаются API: `SensorManager` и `BatteryManager` на Android, `UIDevice` и `UIApplication` на iOS. Датчика освещённости в публичном API iOS нет.
11. **PageView и ListView.** `PageView` показывает страницы, каждая занимает весь видимый экран, прокрутка фиксируется на страницах. `ListView` прокручивает элементы непрерывно, без фиксации и без требования полного экрана на каждый элемент.

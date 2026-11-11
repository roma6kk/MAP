# Лабораторная 9 — Provider

Основа — приложение доставки из лабы 8 (Hive). Пакет: `provider: ^6.1.5+1`.

## Что сделано

### Провайдеры (`lib/providers/`)

| Класс            | Что хранит                                                              | Как подключён                                           |
| --------------------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| `SessionProvider`   | текущий пользователь, список пользователей | `ChangeNotifierProvider`                                          |
| `ShipmentsProvider` | посылки (CRUD поверх Hive-бокса)                               | `ChangeNotifierProvider`                                          |
| `FavoritesProvider` | избранное текущего пользователя                     | `ChangeNotifierProxyProvider<SessionProvider, FavoritesProvider>` |
| `SecurityProvider`  | флаг «идёт операция» и лог экрана Security           | `ChangeNotifierProvider`                                          |
| `HiveService`       | доступ к боксам (не меняется)                             | `Provider<HiveService>.value`                                     |

Все пять объявлены в `MultiProvider` в [main.dart](lib/main.dart) над `MaterialApp`, поэтому доступны на всех маршрутах.

### Что заменено

- `SecurityScreen`: 4 вызова `setState` (`_busy`, `_log`) → `SecurityProvider`; экран стал `StatelessWidget` и использует `context.watch`.
- Синглтон `Session` с `ValueNotifier` + `ValueListenableBuilder` → `SessionProvider` (файл `services/session.dart` удалён).
- `ListenableBuilder` над `box.listenable()` на главном экране, в избранном и в деталях → `Consumer` / `context.select` по `ShipmentsProvider` и `FavoritesProvider`. Изменения данных идут только через методы провайдеров, после записи в Hive вызывается `notifyListeners()`.
- `setState` в `lib/` не осталось ни одного.

### Где что используется (п. 4)

- **ChangeNotifierProvider** — `main.dart` (Session, Shipments, Security).
- **MultiProvider** — `main.dart`.
- **Consumer** — `home_screen.dart` (`_ShipmentList`, `Consumer<ShipmentsProvider>`), `favorites_screen.dart` (`Consumer2<FavoritesProvider, ShipmentsProvider>`).
- **context.watch** — `security_screen.dart`.
- **context.select** — `home_screen.dart` (`canEdit` для FAB, пользователь в шапке, счётчик избранного), `shipment_card.dart` (флаг избранного своей карточки), `shipment_detail_screen.dart`, `favorites_screen.dart`, `shipment_form_screen.dart`.
- **context.read** (только в обработчиках, вне `build`) — `toggle()` в карточке и деталях, `switchUser()` в выборе пользователя, `save()` в форме, `delete()`/`removeShipment()` в деталях, `demoWrongKey()`/`compactAll()` в Security, а также в `create:` у `SecurityProvider`.

### Передача данных между несвязанными виджетами (п. 5)

`FavoritesBadgeButton` (счётчик в шапке, ветка `_Header`) и `ShipmentCard` (ветка `_ShipmentList`) — соседние ветки внутри `Column`, друг о друге не знают и ничего друг другу через конструкторы не передают. Нажатие на сердечко в карточке вызывает `context.read<FavoritesProvider>().toggle(id)`, провайдер вызывает `notifyListeners()`, и бейдж в шапке, подписанный через `context.select((FavoritesProvider f) => f.count)`, показывает новое число. Аналогично: смена пользователя в шапке (`SessionProvider`) прячет FAB, меняет избранное (через `ChangeNotifierProxyProvider`) и заголовок экрана Favorites.

Проверено тестами в [test/provider_test.dart](test/provider_test.dart) (`flutter test`).

### Локальное состояние, оставленное в State (п. 3)

`ShipmentFormScreen` остаётся `StatefulWidget`: в `State` лежат `GlobalKey<FormState>`, семь `TextEditingController` и выбранные в выпадающих списках картинка и статус. `setState` для них не нужен: поле перерисовывает свой контроллер само, а значения выпадающих списков хранит `DropdownButtonFormField` и читает только `_save()`.

Почему не Provider:

- это эфемерное состояние (по классификации Flutter, [Ephemeral vs app state](https://docs.flutter.dev/data-and-backend/state-mgmt/ephemeral-vs-app)): нужно одному экрану, другим виджетам не нужно, после закрытия экрана не нужно;
- контроллеры привязаны к жизненному циклу `State`: создаются вместе с экраном и освобождаются в `dispose()`. В глобальном провайдере они переживали бы экран и смешивали бы черновики разных форм;
- в провайдер уходит только результат — готовая `Shipment` через `ShipmentsProvider.save()`.

Состояние Security (`_busy`, `_log`) тоже можно было бы оставить локальным, но оно вынесено в `SecurityProvider`: лог сохраняется при повторном открытии экрана, а операция, начатая до выхода с экрана, не вызывает `setState` у уже удалённого `State`.

---

## Ответы на вопросы

**1. Что такое Provider и какую проблему он решает?**
Provider — пакет, который кладёт объект с данными в дерево виджетов, и любой виджет ниже может его взять. С Provider перерисовываются только те виджеты, которые подписаны на данные.

**2. На каком механизме Flutter основан provider и почему это важно знать?**
На `InheritedWidget`. Это объясняет правила: данные видны только виджетам ниже провайдера, подписаться можно только в `build`, а при изменении перерисовываются только подписанные виджеты.

**3. Чем Provider отличается от InheritedWidget?**
`InheritedWidget` неизменяемый, и для него нужно много шаблонного кода (`StatefulWidget` сверху, `updateShouldNotify`, метод `of`). Provider делает это за нас: сам создаёт и удаляет (`dispose`) объект, даёт `watch`/`read`/`select`, `Consumer`, `MultiProvider` и понятные ошибки.

**4. Разница между `watch`, `read` и `select`?**

- `watch` — взять данные и перерисовываться при любом их изменении
- `read` — просто взять объект без подписки.
- `select` — подписаться только на одно поле,

**5. Почему `read` нельзя вызывать в `build`?**
`read` не подписывает виджет. Если данные изменятся, виджет не перерисуется и покажет старое значение. Ошибки при этом не будет, интерфейс просто перестанет обновляться. В `build` нужен `watch` или `select`.

**6. Чем `Consumer` отличается от `watch`?**
`watch` перерисовывает весь виджет, в котором вызван. `Consumer` перерисовывает только то, что внутри его `builder`, а неизменяемую часть можно передать в параметр `child`, чтобы она не строилась заново. `Consumer` удобен, когда обновлять нужно маленькую часть большого экрана. `watch` удобен, когда от данных зависит весь небольшой виджет.

**7. Что такое ChangeNotifier и зачем его наследовать?**
`ChangeNotifier` — класс, который умеет сообщать слушателям об изменениях методом `notifyListeners()`. `ChangeNotifierProvider` работает только с ним, потому что подписывается на эти уведомления и сам вызывает `dispose()`, когда провайдер удаляется.

**8. Как обновить данные в ChangeNotifier?**
Изменить поле внутри метода класса и вызвать `notifyListeners()`. Метод вызывают через `context.read<T>().method()`. После этого перерисуются все виджеты, подписанные через `watch` и `Consumer`, а через `select` — только если выбранное поле изменилось.

**9. Что будет без `notifyListeners()`?**
Данные изменятся, но экран об этом не узнает и будет показывать старое значение, пока что-то другое не вызовет перерисовку.

**10. Почему нельзя создавать ChangeNotifier в `build`?**
`build` вызывается много раз. Каждый раз будет создаваться новый объект: старые данные потеряются, а старые объекты не будут удалены (утечка памяти). Правильно — создавать в `ChangeNotifierProvider(create: (_) => Model())`: `create` вызывается один раз.

**11. Зачем MultiProvider?**
Чтобы записать несколько провайдеров списком, а не вкладывать их друг в друга лесенкой. Работает так же, как ручная вложенность, просто код читается легче.

**12. Как передать данные между несвязанными виджетами?**
Провайдер ставится выше обоих виджетов (если они на разных экранах — выше `MaterialApp`). Первый виджет меняет данные через `read`, второй подписан через `watch`/`select` и перерисовывается. В проекте так связаны сердечко в карточке и счётчик избранного в шапке.

**13. Что будет при обращении к провайдеру из виджета выше него?**
Провайдер ищется только вверх по дереву, поэтому он не найдётся и будет исключение `ProviderNotFoundException`.

**14. Что такое ProxyProvider и ChangeNotifierProxyProvider?**
Это провайдеры, которые зависят от других провайдеров и обновляются, когда те меняются. `ProxyProvider` — для обычных объектов, может каждый раз создавать новый. `ChangeNotifierProxyProvider` — для `ChangeNotifier`: объект создаётся один раз, а при изменениях обновляется существующий. В проекте `FavoritesProvider` зависит от `SessionProvider`: при смене пользователя показывается избранное нового пользователя.

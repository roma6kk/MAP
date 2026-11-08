# Лабораторная №7 — SQFlite, File System

Сущность `Developer` (из лабораторной 2, тематика «Разработчик»): id, name, specialty, role, salary, cupsOfCoffee.

## Реализовано
- Список (`ListView.builder` с `itemExtent: 84`) и экран деталей — `lib/screens/developer_list_screen.dart`, `developer_details_screen.dart`.
- CRUD в SQFlite — `lib/db/developer_db.dart`; одна страница добавления/изменения — `developer_edit_screen.dart`; удаление свайпом или с экрана деталей.
- Поиск (по имени, специальности, роли) и сортировка по нескольким полям: тап по чипу — добавить поле / сменить направление, долгий тап — убрать; номер на чипе — приоритет.
- Файловая система (`path_provider`): в каждую директорию пишется свой `Developer` в JSON, затем читается и показывается — `lib/services/storage_dirs.dart`, `files_screen.dart`. Для неподдерживаемых директорий выводится ошибка с перечнем платформ.
- Изоляты: запись 200 000 записей через `Isolate.spawn` + `SendPort`, чтение через `compute`, сравнение с main isolate (спиннер замирает) — `isolate_screen.dart`.
- Расположение файлов из задания 6 — экран «Файлы из лабы 6» (фото image_picker во временной директории, assets внутри пакета, иконка).

## Ответы на вопросы
1. **Поддерживаются всеми платформами:** Temporary, Application Support, Application Documents, Application Cache.
2. **Только Android:** External Storage, External Cache Directories, External Storage Directories. (Application Library — только iOS/macOS; Downloads также поддерживается на Android.)
3. **Библиотеки:** `sqflite`, `path`, `path_provider`, `dart:io`, `dart:isolate`, `dart:convert`, `flutter/foundation` (compute).
4. **SQLite:** встроенная локальная реляционная БД без сервера, SQL, транзакции, быстрая, офлайн. Минусы: нет сложной типизации, слабая поддержка параллельной записи, миграции вручную, не подходит для больших объёмов и сетевого доступа, SQL-строки без проверки компилятором.
5. **Файловая система:** `dart:io` (File, Directory), `path_provider` (пути к директориям), `path`. Без path_provider можно, если знать пути (например через platform channel или `Directory.systemTemp`), но стандартные директории платформ без него не получить.
6. **Изоляты:** `dart:isolate` (встроен в Dart), `compute` из `flutter/foundation`, `Isolate.run`.
7. **Зачем:** параллельное выполнение без общей памяти. Тяжёлая операция в main isolate блокирует цикл событий — UI замирает, анимации не обновляются, возможен ANR.
8. **compute vs Isolate.spawn:** `compute` — простая обёртка: запускает функцию в новом изоляте и возвращает один результат (Future); `Isolate.spawn` — ручное управление: порты, несколько сообщений, долгоживущий изолят. compute — для разовых задач, spawn — для потоков данных и постоянных воркеров.
9. **Передача:** примитивы, строки, List/Map/Set из них, SendPort, TransferableTypedData, экземпляры простых классов (копируются). Нельзя: объекты с нативными ресурсами (сокеты, файлы, Database), замыкания, захватывающие неотправляемое, UI-объекты, ReceivePort.
10. **Ошибки по платформам:** перед обращением проверяется `Platform.isX` и список поддерживаемых платформ директории; `UnsupportedError`, `MissingPlatformDirectoryException`, `null` и `FileSystemException` ловятся, в сообщении указываются поддерживаемые и неподдерживаемые платформы.

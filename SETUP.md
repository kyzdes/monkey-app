# 🚀 Инструкция по настройке проекта

Этот документ содержит подробные инструкции по настройке и запуску проекта Monkey Tamagotchi.

## 📋 Требования

- **macOS**: Monterey (12.0) или новее
- **Xcode**: 14.0 или новее
- **iOS**: Целевая версия iOS 15.0+
- **Apple Developer Account**: Для запуска на реальном устройстве

## 🔧 Настройка Xcode проекта

Так как проект был создан программно, вам нужно создать Xcode проект вручную:

### Шаг 1: Создание проекта в Xcode

1. Откройте Xcode
2. Выберите **File → New → Project**
3. Выберите **iOS → App**
4. Настройте проект:
   - **Product Name**: MonkeyTamagotchi
   - **Team**: Выберите вашу команду разработчика
   - **Organization Identifier**: com.yourname.monkeytamagotchi
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: Core Data ✅ (отметить)
   - **Include Tests**: по желанию

5. Сохраните проект в папку `MonkeyTamagotchi`

### Шаг 2: Добавление файлов

1. Удалите автоматически созданные файлы:
   - `ContentView.swift` (мы создали свой)
   - `MonkeyTamagotchiApp.swift` (мы создали свой)

2. В Finder перетащите все папки из репозитория в проект:
   - `App/`
   - `Models/`
   - `Views/`
   - `Services/`
   - `Utilities/`

3. При добавлении убедитесь, что:
   - ✅ "Copy items if needed" включен
   - ✅ "Create groups" выбран
   - ✅ Target "MonkeyTamagotchi" отмечен

### Шаг 3: Настройка Info.plist

1. В навигаторе проекта найдите `Info.plist`
2. Замените его содержимое на файл `Info.plist` из репозитория
3. Или добавьте вручную ключи:
   - `NSMotionUsageDescription`: "Мы используем шагомер для режима Tama Walk"
   - `NSCameraUsageDescription`: "Камера используется для AR режима и фотосессий с питомцем"

### Шаг 4: Настройка CoreData

1. Откройте файл `.xcdatamodeld`
2. Добавьте Entity "MonkeyEntity" с атрибутами:
   - `id` - UUID
   - `data` - Binary Data

Или замените автоматически созданный файл на файл из репозитория:
`MonkeyTamagotchi.xcdatamodeld/MonkeyTamagotchi.xcdatamodel/contents`

### Шаг 5: Настройка Capabilities

В настройках проекта включите:

1. **Push Notifications** (для уведомлений)
   - Target → Signing & Capabilities
   - Нажмите "+ Capability"
   - Выберите "Push Notifications"

2. **Background Modes** (опционально, для фоновых обновлений)
   - Добавьте "Background fetch"
   - Добавьте "Remote notifications"

### Шаг 6: Настройка Assets

Создайте Asset Catalog для цветов:

1. В `Assets.xcassets` добавьте Color Set:
   - `Background`
   - `Primary`
   - `Secondary`
   - `Accent`

Или используйте системные цвета по умолчанию.

## 🏃‍♂️ Запуск проекта

### На симуляторе

1. Выберите симулятор iPhone в списке устройств (например, iPhone 14 Pro)
2. Нажмите ⌘R или кнопку **Run**
3. Подождите сборки
4. Приложение запустится на симуляторе

### На реальном устройстве

1. Подключите iPhone через кабель
2. В настройках проекта:
   - **Signing & Capabilities**
   - Выберите вашу **Team**
   - Bundle Identifier должен быть уникальным
3. Доверьтесь разработчику на iPhone:
   - **Настройки → Основные → VPN и управление устройством**
   - Доверьтесь вашему сертификату
4. Запустите проект

## 🐛 Устранение проблем

### Ошибка: "No such module 'CoreData'"

**Решение**: Убедитесь, что при создании проекта была отмечена галочка "Use Core Data"

### Ошибка: "Cannot find type 'MonkeyEntity' in scope"

**Решение**:
1. Откройте файл `.xcdatamodeld`
2. Убедитесь, что Entity создана
3. В Inspector установите Codegen: "Class Definition"
4. Пересоберите проект (⌘⇧K → ⌘B)

### Предупреждения о @Published в struct

**Решение**: Игнорируйте или измените `Monkey` на class (уже реализовано)

### Ошибка компиляции в PersistenceController

**Решение**: Убедитесь, что CoreData модель настроена правильно

### Отсутствующие звуковые файлы

Приложение будет работать без звуков. Для добавления звуков:

1. Создайте папку `Sounds` в `Resources`
2. Добавьте .mp3 файлы для звуков:
   - `feed.mp3`
   - `play.mp3`
   - `clean.mp3`
   - `sleep.mp3`
   - `levelup.mp3`
   - `achievement.mp3`
   - и т.д.

## 📱 Тестирование

### Основные сценарии тестирования

1. **Создание персонажа**
   - Запустите приложение
   - Выберите тип обезьяны
   - Введите имя
   - Проверьте, что персонаж создан

2. **Базовые действия**
   - Покормите обезьяну
   - Поиграйте
   - Помойте
   - Уложите спать

3. **Сохранение данных**
   - Выполните действия
   - Закройте приложение
   - Откройте снова
   - Проверьте, что данные сохранились

4. **Мини-игры**
   - Откройте раздел "Игры"
   - Запустите каждую мини-игру
   - Проверьте работоспособность

5. **Магазин**
   - Откройте магазин
   - Купите предмет
   - Используйте предмет

## 🎨 Кастомизация

### Изменение цветов

Отредактируйте `Utilities/Constants.swift`:

```swift
enum Colors {
    static let primaryGreen = Color(hex: "YOUR_HEX_COLOR")
    // ...
}
```

### Изменение баланса игры

Отредактируйте `Utilities/Constants.swift`:

```swift
enum Balance {
    static let hungerIncreasePerMinute: Double = 0.5
    // Измените значения по вкусу
}
```

### Добавление новых предметов

Отредактируйте `Models/Item.swift`:

```swift
extension Item {
    static let commonItems: [Item] = [
        // Добавьте новые предметы здесь
    ]
}
```

## 📚 Дополнительные ресурсы

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Core Data Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/)
- [Combine Framework](https://developer.apple.com/documentation/combine)

## 💡 Советы

1. **Используйте Canvas** в Xcode для предпросмотра UI в реальном времени
2. **Debug View Hierarchy** для отладки layout проблем
3. **Instruments** для профилирования производительности
4. **Memory Graph** для поиска утечек памяти

## 🆘 Поддержка

Если у вас возникли проблемы:

1. Проверьте [Issues](https://github.com/yourusername/monkey-tamagotchi/issues)
2. Создайте новый Issue с подробным описанием
3. Приложите логи и скриншоты

---

**Удачи в разработке! 🐵🍌**

# Чеклист для релиза в App Store

## ✅ Выполненные критические задачи

1. ✅ Удалены debug-логи из production кода (обернуты в `kDebugMode`)
2. ✅ Локализованы описания разрешений в Info.plist (en, ru, uk)
3. ✅ Исправлен тест widget_test.dart
4. ✅ Убраны неиспользуемые Background Modes из Info.plist

1. **Описание приложения** (EN, RU, UA):✅
   - Краткое описание (до 170 символов)
   - Полное описание (до 4000 символов)
   - Ключевые слова (до 100 символов)

4. **Privacy Policy URL** (обязательно):✅
   - Создайте страницу Privacy Policy
   - Разместите на вашем сайте или используйте сервис (например, GitHub Pages)
   - Добавьте ссылку в App Store Connect

5. **Terms of Service URL** (рекомендуется):✅
   - Создайте страницу Terms of Service
   - Разместите на вашем сайте


3. **Иконка приложения:** ✅
   - 1024x1024 px, без альфа-канала
   - Уже есть в проекте: `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png`


## 📋 Оставшиеся задачи

### 5. Настройка Bundle Identifier и Signing

**Текущий Bundle Identifier:** `com.deardates.deardatesFlutter`

**Инструкции:**

1. **Откройте проект в Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Проверьте Bundle Identifier:**
   - Выберите проект `Runner` в навигаторе
   - Выберите target `Runner`
   - Перейдите на вкладку "Signing & Capabilities"
   - Убедитесь, что Bundle Identifier уникален (например: `com.yourname.deardates` или `com.deardates.app`)
   - ⚠️ **Важно:** Bundle Identifier должен быть уникальным и соответствовать вашему Apple Developer Account

3. **Настройте Signing:**
   - Выберите вашу команду разработчика (Team)
   - Выберите "Automatically manage signing" (рекомендуется)
   - Xcode автоматически создаст Provisioning Profile

4. **Проверьте версию:**
   - Убедитесь, что версия в `pubspec.yaml` (1.0.0+1) соответствует версии в Xcode
   - В Xcode: General → Version: `1.0.0`, Build: `1`

### 6. App Store Connect метаданные

**Необходимо подготовить:**



2. **Скриншоты:**
   - iPhone 6.7" (iPhone 14 Pro Max, 15 Pro Max) - минимум 1, максимум 10
   - iPhone 6.5" (iPhone 11 Pro Max, XS Max) - минимум 1, максимум 10
   - iPhone 5.5" (iPhone 8 Plus) - опционально
   - iPad Pro 12.9" - опционально (если поддерживается)



6. **Поддержка:**
   - Email для поддержки пользователей
   - Или URL страницы поддержки

### 7. Сборка для App Store

1. **Очистите проект:**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Соберите Release версию:**
   ```bash
   flutter build ios --release
   ```

3. **Архивируйте в Xcode:**
   - Откройте `ios/Runner.xcworkspace` в Xcode
   - Выберите "Any iOS Device" в схеме
   - Product → Archive
   - Дождитесь завершения архивации

4. **Загрузите в App Store Connect:**
   - В окне Organizer выберите архив
   - Нажмите "Distribute App"
   - Выберите "App Store Connect"
   - Следуйте инструкциям

### 8. Тестирование перед релизом

- [ ] Протестировать на реальном iPhone
- [ ] Проверить работу уведомлений
- [ ] Проверить работу с фото (выбор из галереи и камера)
- [ ] Проверить все функции приложения
- [ ] Проверить локализацию (EN, RU, UA)
- [ ] Проверить работу в темной теме
- [ ] Проверить работу календаря
- [ ] Проверить производительность

### 9. Дополнительные рекомендации

1. **TestFlight:**
   - Загрузите билд в TestFlight для внутреннего тестирования
   - Пригласите тестировщиков
   - Соберите обратную связь

2. **Версионирование:**
   - Используйте семантическое версионирование (MAJOR.MINOR.PATCH)
   - Текущая версия: 1.0.0+1

3. **Мониторинг:**
   - Рассмотрите добавление Firebase Crashlytics или Sentry для отслеживания ошибок
   - Используйте App Store Connect Analytics

## 📝 Примечания

- Все критические задачи выполнены
- Проект готов к сборке Release версии
- Не забудьте создать Privacy Policy перед отправкой на ревью


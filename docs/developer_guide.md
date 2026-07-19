# راهنمای توسعه اپلیکیشن «تأیید بارکد انبار»

## مقدمه

این سند راهنمای کامل برای راه‌اندازی، توسعه و تست اپلیکیشن «تأیید بارکد انبار» است. اپلیکیشن با Flutter و Clean Architecture پیاده‌سازی شده است.

## پیش‌نیازها

- **Flutter SDK:** نسخه 3.24.5 یا بالاتر
- **Android SDK:** API 34 (Android 14)، Build Tools 34.0.0، minSdk 26
- **Java:** نسخه 17 یا 21
- **Dart:** نسخه 3.5 یا بالاتر

## راه‌اندازی محیط توسعه

```bash
# نصب وابستگی‌ها
flutter pub get

# اجرای کد جنریشن
dart run build_runner build --delete-conflicting-outputs

# اجرای اپ
flutter run
```

## ساختار پروژه

```
lib/
├── main.dart                    # نقطه ورود
├── core/                        # هسته مشترک
│   ├── constants/               # رنگ‌ها، ابعاد، رشته‌ها
│   ├── theme/                   # تم روشن و تاریک
│   ├── utils/                   # ابزارهای کمکی
│   ├── errors/                  # کلاس‌های خطا
│   └── router/                  # مسیریاب
├── features/                    # ماژول‌های Feature-First
│   ├── auth/                    # احراز هویت
│   ├── scanner/                 # اسکن بارکد
│   ├── barcode/                 # مدیریت بارکدها
│   ├── reports/                 # گزارش‌گیری
│   ├── import_export/           # Import/Export
│   ├── settings/                # تنظیمات
│   └── home/                    # صفحه اصلی
└── shared/                      # ویجت‌های مشترک
```

### لایه‌بندی Clean Architecture

هر feature شامل سه لایه است:
1. **Domain** — Entities، Repository Interfaces، Use Cases (خالص Dart)
2. **Data** — Repository Impl، Data Sources، Models/DTOs
3. **Presentation** — Pages، Widgets، Providers (Riverpod)

## کاربری نمایشی

| نقش | نام کاربری | رمز عبور |
|-----|-----------|----------|
| مدیر | `admin` | `admin123` |
| اپراتور | `operator` | `operator123` |

## فازهای پیاده‌سازی

| فاز | عنوان | وضعیت |
|-----|-------|-------|
| ۱ | راه‌اندازی پروژه و ساختار پایه | ✅ کامل |
| ۲ | لایه Data — SQLite و Bloom Filter | ⏳ بعدی |
| ۳ | لایه Domain — Use Cases | ⏳ |
| ۴ | صفحات احراز هویت و اصلی | ✅ اولیه |
| ۵ | اسکنر بارکد و نتیجه | ⏳ |
| ۶ | Import/Export و گزارش‌ها | ⏳ |
| ۷ | تنظیمات و حالت تاریک | ✅ اولیه |
| ۸ | تست، مستندسازی و APK | ⏳ |

## قواعد کدنویسی

- فایل‌ها: snake_case
- کلاس‌ها: PascalCase
- متغیرها: camelCase
- کامنت‌ها: فارسی برای توضیحات

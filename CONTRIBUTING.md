# 🤝 دليل المساهمة

شكراً لاهتمامك بالمساهمة في Hermes!

---

## 📋 قبل البدء

1. اقرأ هذا الدليل بالكامل
2. اطلع على [LICENSE](LICENSE) - GPLv3
3. راجع [SECURITY.md](SECURITY.md) لإرشادات الأمان

---

## 🚀 كيف المساهمة

### 1. الإبلاغ عن الأخطاء

أنشئ Issue جديد مع:
- `bug` label
- وصف مفصل للمشكلة
- خطوات لإعادة الإنتاج
- لقطات شاشة (إن أمكن)

### 2. طلب الميزات

أنشئ Issue جديد مع:
- `feature` label
- وصف الميزة المطلوبة
- لماذا هذه الميزة مفيدة
- بدائل مقترحة (إن وجدت)

### 3. إرسال Pull Request

#### الخطوات

1. **Fork** المشروع
2. **Clone** نسختك المحلية:
```bash
git clone https://github.com/YOUR_USERNAME/hermes-pro-transfer.git
```

3. **Branch** فرع جديد:
```bash
git checkout -b feature/your-feature-name
```

4. **Commit** التغييرات مع رسائل واضحة:
```bash
git commit -m "إضافة: وصف التغيير"
```

5. **Push** إلى GitHub:
```bash
git push origin feature/your-feature-name
```

6. **إنشاء Pull Request** على GitHub

---

## 📏 معايير الكود

### التنسيق

- استخدم `flutter analyze` قبل Commit
- اتبع تنسيق Dart القياسي
- استخدم `dartfmt` للتنسيق التلقائي

### الترتيب

```dart
// 1. الحزم ( packages )
import 'package:flutter/material.dart';

// 2. الحزم المحلية
import '../models/file.dart';

// 3. الملفات النسبية
import 'file.dart';
```

### التسمية

- `camelCase` للمتغيرات والدوال
- `PascalCase` لل Classes و Enums
- `snake_case` للملفات

### التعليقات

- تعليق Dartdoc لل Classes والدوال العامة
- // للتعليقات السردية

---

## 🧪 اختبار

- اختبر تغييراتك على أجهزة حقيقية
- اختبر على Android 8.0+ (API 26+)
- اختبر الوضعين: Light و Dark

---

## 📝 قوالب الرسائل

### Commit Messages

```
<type>: <description>

[optional body]

[optional footer]
```

#### Types

| Type | الوصف |
|------|-------|
| `🆕` | ميزة جديدة |
| `🎨` | تحسين واجهة |
| `🔧` | تحسين كود |
| `🐛` | إصلاح خطأ |
| `📝` | وثائق |
| `⚙️` | إعدادات |
| `♻️` | إعادة تشكيل |

---

## ❌ ما لا نسمح به

- 🚫 إزعاج أو مضايقة
- 🚫 محتوى غير لائق
- 🚫 سرقة هوية
- 🚫 انتهاك الخصوصية
- 🚫 استخدام للأغراض الخبيثة

---

## 💬 التواصل

- GitHub Discussions للأسئلة العامة
- Issues للأخطاء والميزات
- لا ترسل بريد إلكتروني غير مطلوب

---

## 📜 الترخيص

بإرسالك Pull Request، أنت توافق على ترخيص مساهمتك تحت [GPLv3](LICENSE).

---

شكراً لك على مساعدتك في جعل Hermes أفضل! 🌟
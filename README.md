# E3rab — إعراب

منصة Flutter عربية محلية أولًا لتعلّم النحو والإعراب:

> افهم القاعدة، شاهدها في مثال، أعربها خطوة بخطوة، ثم طبّقها بنفسك.

## الحالة الحالية

- تجربة الضيف تعمل محليًا على Android وiOS والويب وWindows وmacOS وLinux.
- حسابات البريد وكلمة المرور تستخدم Firebase Authentication على المنصات المهيأة فقط.
- ملفات المستخدم والمزامنة محفوظة تحت `e3rab_users/{uid}` ومجموعاتها المسموح بها.
- فتح التطبيق لا يرفع المحتوى إلى Firebase. أداة البذر محمية بعلم Debug صريح وclaim موثوق.
- المحتوى التعليمي محلي، بإصدارات ثابتة والتحقق من المخطط قبل عرضه.
- الحزم ذات `learnerEnabled: false` لا تدخل الدروس أو البحث أو التدريب.
- محتوى النحو والتحليل غير المعتمد يظل `aiAssistedDraft` ولا يُقدَّم كمرجع بشري معتمد.

## الميزات

- تسجيل حساب، تسجيل دخول، استعادة كلمة المرور، جلسة مستعادة، ووضع ضيف كامل.
- ملف تعلم ودور ومرحلة وصف وهدف يومي.
- دروس عربية RTL وتمارين وتغذية راجعة وتقدم وإتقان ومراجعة متباعدة.
- بحث عربي، مرجع نحوي، محفوظات، ملاحظات خاصة، ووضع معلم.
- معمل إعراب موجّه لا يعرض إلا العينات المعتمدة للمستخدم النهائي.
- تخزين محلي ومزامنة ودمج آمن لتقدم الضيف مع المحافظة على تعارضات الملاحظات.
- إعادة ضبط التقدم، حذف الحساب وبياناته، ووثائق خصوصية واحتفاظ.
- واجهة متكيفة Compact/Medium/Expanded مع دعم لوحة المفاتيح والنص الكبير.

## المعمارية

التدفق الأساسي لكل ميزة:

```text
Screen → Cubit → Repository → Data Source
```

المشروع يحافظ على feature-first وCubit/Bloc وGetIt وnamed routes و`easy_localization`، ولا تصل الشاشات إلى Firebase أو الملفات أو التخزين مباشرة.

## المحتوى

```text
assets/content/
├── e3rab_content_catalog_v1.json
├── e3rab_curriculum_matrix_egypt_2025_2026_v1.json
├── e3rab_vertical_slice_v1.json
├── e3rab_egypt_secondary2_term1_batch1_v1.json
└── e3rab_parsing_bank_v1.json
```

الـvertical slice المنشور محليًا يحتوي ثلاثة دروس وثلاثين تمرينًا. دفعة الصف الثاني الثانوي تضيف درسًا وعشرة تمارين لكنها محجوبة عن الطلاب حتى المراجعة البشرية.

## Firebase

بيانات التعلم الخاصة:

```text
e3rab_users/{uid}
├── lesson_progress/{lessonId}
├── exercise_attempts/{attemptId}
├── skill_mastery/{skillId}
├── review_items/{reviewItemId}
├── bookmarks/{bookmarkId}
└── notes/{noteId}
```

المحتوى المبذور إداريًا منفصل تحت `e3rab_content_packs/{packId}`. راجع [توثيق البذر](docs/firebase_content_seeding.md) وقواعد [Firestore](firestore.rules).

## التشغيل

```bash
flutter pub get
flutter run
```

تشغيل أداة بذر المحتوى في بيئة تطوير مصرح بها فقط:

```bash
flutter run --dart-define=E3RAB_ENABLE_CONTENT_SEED=true
```

يلزم أيضًا Firebase مهيأ، مستخدم مسجل، وcustom claim باسم `contentAdmin: true`.

## التحقق

```bash
dart format .
flutter analyze
flutter test
flutter build web
```

اختبارات قواعد Firestore تعمل على مشروع المحاكي `demo-e3rab` فقط. لا تشغّل اختبارات أمن مدمرة على بيانات إنتاجية.

## قيود الإصدار

- اسم حزمة Dart التاريخي `new_strucuture` ومعرفات المنصات الحالية لم تتغير؛ تغييرها يحتاج قرار ترحيل Firebase وتوقيع المتاجر.
- اعتماد المحتوى النحوي وتغطية المنهج المصري بالكامل يتطلبان مراجعين بشريين ومصادر رسمية مؤرخة لكل دفعة.
- مفاتيح service accounts لا توضع في المستودع.

التوثيق المرحلي موجود في مجلد [docs](docs/).

import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'uz': {
      // App Info
      'appName': 'Gold Imperia',
      'appTagline': 'Hashamatli zargarlik to\'plami',
      
      // Auth
      'welcomeBack': 'Xush kelibsiz',
      'enterPhoneNumber': 'Telefon raqamingizni kiriting',
      'phoneNumberHint': 'Telefon raqam',
      'continueButton': 'Davom etish',
      'verifyOTP': 'Tasdiqlash kodi',
      'enterOTPCode': 'Telefon raqamingizga yuborilgan 6 raqamli kodni kiriting',
      'resendCode': 'Kodni qayta yuborish',
      'verifyButton': 'Tasdiqlash',
      'invalidPhone': 'Telefon raqam noto\'g\'ri kiritilgan',
      'invalidOTP': 'Kod noto\'g\'ri',
      
      // Home
      'home': 'Bosh sahifa',
      'categories': 'Kategoriyalar',
      'featured': 'Maxsus takliflar',
      'newArrivals': 'Yangi mahsulotlar',
      'bestSellers': 'Eng ko\'p sotilganlar',
      'viewAll': 'Barchasini ko\'rish',
      'searchHint': 'Qidirish...',
      'searchText': 'Qidiruv',
      
      // Categories
      'rings': 'Uzuklar',
      'necklaces': 'Marjonlar',
      'earrings': 'Sirg\'alar',
      'bracelets': 'Bilaguzuklar',
      'pendants': 'Osma taqinchoqlar',
      'sets': 'To\'plamlar',
      'all': 'Barchasi',
      
      // Profile
      'profile': 'Profil',
      'myOrders': 'Mening buyurtmalarim',
      'myPurchases': 'Mening haridlarim',
      'favorites': 'Sevimlilar',
      'settings': 'Sozlamalar',
      'language': 'Til',
      'notifications': 'Bildirishnomalar',
      'help': 'Yordam',
      'about': 'Ilova haqida',
      'logout': 'Chiqish',
      'editProfile': 'Profilni tahrirlash',
      'stores': 'Do\'konlar',
      
      // Item Detail
      'addToCart': 'Savatga qo\'shish',
      'buyNow': 'Hozir sotib olish',
      'installment': 'Bo\'lib to\'lash',
      'description': 'Tavsif',
      'specifications': 'Xususiyatlar',
      'reviews': 'Sharhlar',
      'relatedItems': 'O\'xshash mahsulotlar',
      'material': 'Material',
      'weight': 'Og\'irligi',
      'price': 'Narxi',
      'inStock': 'Omborda bor',
      'outOfStock': 'Omborda yo\'q',
      
      // Common
      'loading': 'Yuklanmoqda...',
      'error': 'Xatolik yuz berdi',
      'retry': 'Qayta urinish',
      'cancel': 'Bekor qilish',
      'save': 'Saqlash',
      'edit': 'Tahrirlash',
      'delete': 'O\'chirish',
      'confirm': 'Tasdiqlash',
      'yes': 'Ha',
      'no': 'Yo\'q',
      'ok': 'OK',
      'currency': 'so\'m',
      'apply': 'Qo\'llash',
      'sort': 'Saralash',
      'filter': 'Filtr',
      'noResults': 'Hech narsa topilmadi',
      'productsFound': 'ta mahsulot topildi',
    },
    'ru': {
      // App Info
      'appName': 'Gold Imperia',
      'appTagline': 'Роскошная коллекция ювелирных изделий',
      
      // Auth
      'welcomeBack': 'Добро пожаловать',
      'enterPhoneNumber': 'Введите номер телефона',
      'phoneNumberHint': 'Номер телефона',
      'continueButton': 'Продолжить',
      'verifyOTP': 'Код подтверждения',
      'enterOTPCode': 'Введите 6-значный код, отправленный на ваш телефон',
      'resendCode': 'Отправить код повторно',
      'verifyButton': 'Подтвердить',
      'invalidPhone': 'Неверный номер телефона',
      'invalidOTP': 'Неверный код',
      
      // Home
      'home': 'Главная',
      'categories': 'Категории',
      'featured': 'Специальные предложения',
      'newArrivals': 'Новинки',
      'bestSellers': 'Бестселлеры',
      'viewAll': 'Смотреть все',
      'searchHint': 'Поиск...',
      'searchText': 'Поиск',
      
      // Categories
      'rings': 'Кольца',
      'necklaces': 'Ожерелья',
      'earrings': 'Серьги',
      'bracelets': 'Браслеты',
      'pendants': 'Подвески',
      'sets': 'Наборы',
      'all': 'Все',
      
      // Profile
      'profile': 'Профиль',
      'myOrders': 'Мои заказы',
      'myPurchases': 'Мои покупки',
      'favorites': 'Избранное',
      'settings': 'Настройки',
      'language': 'Язык',
      'notifications': 'Уведомления',
      'help': 'Помощь',
      'about': 'О приложении',
      'logout': 'Выйти',
      'editProfile': 'Редактировать профиль',
      'stores': 'Магазины',
      
      // Item Detail
      'addToCart': 'В корзину',
      'buyNow': 'Купить сейчас',
      'installment': 'Рассрочка',
      'description': 'Описание',
      'specifications': 'Характеристики',
      'reviews': 'Отзывы',
      'relatedItems': 'Похожие товары',
      'material': 'Материал',
      'weight': 'Вес',
      'price': 'Цена',
      'inStock': 'В наличии',
      'outOfStock': 'Нет в наличии',
      
      // Common
      'loading': 'Загрузка...',
      'error': 'Произошла ошибка',
      'retry': 'Повторить',
      'cancel': 'Отмена',
      'save': 'Сохранить',
      'edit': 'Редактировать',
      'delete': 'Удалить',
      'confirm': 'Подтвердить',
      'yes': 'Да',
      'no': 'Нет',
      'ok': 'ОК',
      'currency': 'сум',
      'apply': 'Применить',
      'sort': 'Сортировка',
      'filter': 'Фильтр',
      'noResults': 'Ничего не найдено',
      'productsFound': 'товаров найдено',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Helper getters
  String get appName => translate('appName');
  String get appTagline => translate('appTagline');
  String get home => translate('home');
  String get categories => translate('categories');
  String get featured => translate('featured');
  String get newArrivals => translate('newArrivals');
  String get bestSellers => translate('bestSellers');
  String get viewAll => translate('viewAll');
  String get search => translate('search');
  String get profile => translate('profile');
  String get myPurchases => translate('myPurchases');
  String get stores => translate('stores');
  String get favorites => translate('favorites');
  String get settings => translate('settings');
  String get language => translate('language');
  String get notifications => translate('notifications');
  String get help => translate('help');
  String get about => translate('about');
  String get logout => translate('logout');
  String get cancel => translate('cancel');
  String get ok => translate('ok');
  String get currency => translate('currency');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['uz', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

import 'dart:convert';
import 'dart:io';

const translations = <String, Map<String, String>>{
  'ja': {
    // Japanese
    'appName': 'PocketMind',
    'appNameEn': 'PocketMind',
    'bottomNavHome': 'ホーム',
    'bottomNavDiscover': '発見',
    'bottomNavAssistant': 'エージェント',
    'bottomNavMine': 'マイページ',
    'cancel': 'キャンセル',
    'confirm': '確認',
    'delete': '削除',
    'retry': '再試行',
    'save': '保存',
    'share': '共有',
    'loading': '読み込み中...',
    'generating': '生成中...',
    'processing': '処理中...',
    'noContent': 'コンテンツがありません',
    'noModule': 'モジュールがありません',
    'themeSettings': 'テーマ設定',
    'notification': '通知',
    'aboutUs': 'について',
    'clearCache': 'キャッシュをクリア',
    'lightMode': 'ライトモード',
    'darkMode': 'ダークモード',
    'followSystem': 'システムに従う',
  },
  'ko': {
    // Korean
    'appName': 'PocketMind',
    'appNameEn': 'PocketMind',
    'bottomNavHome': '홈',
    'bottomNavDiscover': '탐색',
    'bottomNavAssistant': '에이전트',
    'bottomNavMine': '마이',
    'cancel': '취소',
    'confirm': '확인',
    'delete': '삭제',
    'retry': '재시도',
    'save': '저장',
    'share': '공유',
    'loading': '로딩 중...',
    'generating': '생성 중...',
    'processing': '처리 중...',
    'noContent': '콘텐츠 없음',
    'noModule': '모듈 없음',
    'themeSettings': '테마 설정',
    'notification': '알림',
    'aboutUs': '정보',
    'clearCache': '캐시 지우기',
    'lightMode': '라이트 모드',
    'darkMode': '다크 모드',
    'followSystem': '시스템 따르기',
  },
  'es': {
    // Spanish
    'appName': 'PocketMind',
    'appNameEn': 'PocketMind',
    'bottomNavHome': 'Inicio',
    'bottomNavDiscover': 'Explorar',
    'bottomNavAssistant': 'Agente',
    'bottomNavMine': 'Mi',
    'cancel': 'Cancelar',
    'confirm': 'Aceptar',
    'delete': 'Eliminar',
    'retry': 'Reintentar',
    'save': 'Guardar',
    'share': 'Compartir',
    'loading': 'Cargando...',
    'generating': 'Generando...',
    'processing': 'Procesando...',
    'noContent': 'Sin contenido',
    'noModule': 'Sin módulos',
    'themeSettings': 'Tema',
    'notification': 'Notificaciones',
    'aboutUs': 'Acerca de',
    'clearCache': 'Limpiar caché',
    'lightMode': 'Modo claro',
    'darkMode': 'Modo oscuro',
    'followSystem': 'Sistema',
  },
  'fr': {
    // French
    'appName': 'PocketMind',
    'appNameEn': 'PocketMind',
    'bottomNavHome': 'Accueil',
    'bottomNavDiscover': 'Découvrir',
    'bottomNavAssistant': 'Agent',
    'bottomNavMine': 'Moi',
    'cancel': 'Annuler',
    'confirm': 'Confirmer',
    'delete': 'Supprimer',
    'retry': 'Réessayer',
    'save': 'Sauvegarder',
    'share': 'Partager',
    'loading': 'Chargement...',
    'generating': 'Génération...',
    'processing': 'Traitement...',
    'noContent': 'Aucun contenu',
    'noModule': 'Aucun module',
    'themeSettings': 'Thème',
    'notification': 'Notifications',
    'aboutUs': 'À propos',
    'clearCache': 'Vider le cache',
    'lightMode': 'Mode clair',
    'darkMode': 'Mode sombre',
    'followSystem': 'Système',
  },
  'de': {
    // German
    'appName': 'PocketMind',
    'appNameEn': 'PocketMind',
    'bottomNavHome': 'Start',
    'bottomNavDiscover': 'Entdecken',
    'bottomNavAssistant': 'Agent',
    'bottomNavMine': 'Ich',
    'cancel': 'Abbrechen',
    'confirm': 'Bestätigen',
    'delete': 'Löschen',
    'retry': 'Wiederholen',
    'save': 'Speichern',
    'share': 'Teilen',
    'loading': 'Laden...',
    'generating': 'Generieren...',
    'processing': 'Verarbeiten...',
    'noContent': 'Kein Inhalt',
    'noModule': 'Keine Module',
    'themeSettings': 'Design',
    'notification': 'Benachrichtigungen',
    'aboutUs': 'Über uns',
    'clearCache': 'Cache leeren',
    'lightMode': 'Hell',
    'darkMode': 'Dunkel',
    'followSystem': 'System',
  },
  'pt': {
    // Portuguese
    'appName': 'PocketMind',
    'appNameEn': 'PocketMind',
    'bottomNavHome': 'Início',
    'bottomNavDiscover': 'Explorar',
    'bottomNavAssistant': 'Agente',
    'bottomNavMine': 'Meu',
    'cancel': 'Cancelar',
    'confirm': 'Confirmar',
    'delete': 'Excluir',
    'retry': 'Tentar novamente',
    'save': 'Salvar',
    'share': 'Compartilhar',
    'loading': 'Carregando...',
    'generating': 'Gerando...',
    'processing': 'Processando...',
    'noContent': 'Sem conteúdo',
    'noModule': 'Sem módulos',
    'themeSettings': 'Tema',
    'notification': 'Notificações',
    'aboutUs': 'Sobre',
    'clearCache': 'Limpar cache',
    'lightMode': 'Modo claro',
    'darkMode': 'Modo escuro',
    'followSystem': 'Sistema',
  },
  'ru': {
    // Russian
    'appName': 'PocketMind',
    'appNameEn': 'PocketMind',
    'bottomNavHome': 'Главная',
    'bottomNavDiscover': 'Поиск',
    'bottomNavAssistant': 'Агент',
    'bottomNavMine': 'Мой',
    'cancel': 'Отмена',
    'confirm': 'ОК',
    'delete': 'Удалить',
    'retry': 'Повторить',
    'save': 'Сохранить',
    'share': 'Поделиться',
    'loading': 'Загрузка...',
    'generating': 'Генерация...',
    'processing': 'Обработка...',
    'noContent': 'Нет контента',
    'noModule': 'Нет модулей',
    'themeSettings': 'Тема',
    'notification': 'Уведомления',
    'aboutUs': 'О нас',
    'clearCache': 'Очистить кэш',
    'lightMode': 'Светлая',
    'darkMode': 'Тёмная',
    'followSystem': 'Системная',
  },
  'ar': {
    // Arabic
    'appName': 'PocketMind',
    'appNameEn': 'PocketMind',
    'bottomNavHome': 'الرئيسية',
    'bottomNavDiscover': 'استكشاف',
    'bottomNavAssistant': 'الوكيل',
    'bottomNavMine': 'حسابي',
    'cancel': 'إلغاء',
    'confirm': 'تأكيد',
    'delete': 'حذف',
    'retry': 'إعادة',
    'save': 'حفظ',
    'share': 'مشاركة',
    'loading': 'جار التحميل...',
    'generating': 'جار الإنشاء...',
    'processing': 'جار المعالجة...',
    'noContent': 'لا يوجد محتوى',
    'noModule': 'لا توجد وحدات',
    'themeSettings': 'المظهر',
    'notification': 'الإشعارات',
    'aboutUs': 'حول',
    'clearCache': 'مسح التخزين',
    'lightMode': 'فاتح',
    'darkMode': 'داكن',
    'followSystem': 'النظام',
  },
  'hi': {
    // Hindi
    'appName': 'PocketMind',
    'appNameEn': 'PocketMind',
    'bottomNavHome': 'होम',
    'bottomNavDiscover': 'खोजें',
    'bottomNavAssistant': 'एजेंट',
    'bottomNavMine': 'मेरा',
    'cancel': 'रद्द करें',
    'confirm': 'पुष्टि करें',
    'delete': 'हटाएं',
    'retry': 'पुनः प्रयास',
    'save': 'सहेजें',
    'share': 'साझा करें',
    'loading': 'लोड हो रहा है...',
    'generating': 'जनरेट हो रहा है...',
    'processing': 'प्रोसेस हो रहा है...',
    'noContent': 'कोई सामग्री नहीं',
    'noModule': 'कोई मॉड्यूल नहीं',
    'themeSettings': 'थीम',
    'notification': 'सूचनाएं',
    'aboutUs': 'हमारे बारे में',
    'clearCache': 'कैश साफ़ करें',
    'lightMode': 'लाइट मोड',
    'darkMode': 'डार्क मोड',
    'followSystem': 'सिस्टम',
  },
  'th': {
    // Thai
    'appName': 'PocketMind',
    'appNameEn': 'PocketMind',
    'bottomNavHome': 'หน้าแรก',
    'bottomNavDiscover': 'ค้นพบ',
    'bottomNavAssistant': 'ผู้ช่วย',
    'bottomNavMine': 'ของฉัน',
    'cancel': 'ยกเลิก',
    'confirm': 'ยืนยัน',
    'delete': 'ลบ',
    'retry': 'ลองใหม่',
    'save': 'บันทึก',
    'share': 'แชร์',
    'loading': 'กำลังโหลด...',
    'generating': 'กำลังสร้าง...',
    'processing': 'กำลังดำเนินการ...',
    'noContent': 'ไม่มีเนื้อหา',
    'noModule': 'ไม่มีโมดูล',
    'themeSettings': 'ธีม',
    'notification': 'การแจ้งเตือน',
    'aboutUs': 'เกี่ยวกับเรา',
    'clearCache': 'ล้างแคช',
    'lightMode': 'โหมดสว่าง',
    'darkMode': 'โหมดมืด',
    'followSystem': 'ตามระบบ',
  },
};

void main() {
  final enFile = File('lib/l10n/app_en.arb');
  if (!enFile.existsSync()) {
    stderr.writeln('ERROR: lib/l10n/app_en.arb not found. Run from project root.');
    exit(1);
  }

  final enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;

  final localeKeys = translations.keys;
  for (final locale in localeKeys) {
    final target = <String, dynamic>{};
    target['@@locale'] = locale;

    final mapping = translations[locale]!;
    for (final entry in enJson.entries) {
      final key = entry.key;
      if (key == '@@locale') {
        // Skip — we already set @@locale above to the target locale
        continue;
      }
      if (key.startsWith('@')) {
        // Copy placeholder metadata as-is
        target[key] = entry.value;
      } else {
        // Use translation if available, otherwise use English + marker
        if (mapping.containsKey(key)) {
          target[key] = mapping[key];
        } else {
          target[key] = '[${locale.toUpperCase()}] ${entry.value}';
        }
      }
    }

    final outFile = File('lib/l10n/app_$locale.arb');
    outFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(target),
    );
    print('Generated: app_$locale.arb');
  }

  print('\nDone! Generated ${localeKeys.length} ARB files.');
}

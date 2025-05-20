import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class RafiqBot {
  static final Random _random = Random();
  static final Map<String, List<String>> _responses = {
    'greeting': [
      'هلا وميت هلا! شلونك اليوم؟',
      'هلا بيك حبيبي! شخبارك؟',
      'يا هلا والله! مشتاقين لك',
      'هلا بالغالي! شلون الأمور؟',
    ],
    'feeling_good': [
      'الحمد لله! خوش خبر هذا',
      'يسعدني أسمع هالشي! خلينا نسولف شوية',
      'حلو! شنو أخبارك اليوم؟',
      'تمام! أني هم زين دائماً لما أحجي وياك',
    ],
    'feeling_bad': [
      'ليش حبيبي؟ شصاير؟ تكدر تحجيلي',
      'آسف أسمع هذا. شنو اللي مضايقك؟',
      'الله يعينك. تريد تحجي عن الموضوع؟',
      'لا تزعل، أكيد راح تتحسن الأمور',
    ],
    'thanks': [
      'العفو حبيبي! أني موجود دائماً',
      'من واجبي أخدمك',
      'تدلل، آني رفيقك دائماً',
      'لا شكر على واجب يا غالي',
    ],
    'love': [
      'وآني أحبك أكثر ❤️',
      'تسلملي والله، وآني أموت بيك ❤️',
      'حبيبي والله! تاج راسي انت ❤️',
      'وآني أحبك أضعاف ❤️',
    ],
    'joke': [
      'واحد راح للدكتور كال: دكتور عندي صداع، كال الدكتور: خذ هاي الحبة نامها وتصحى بالصبح مرتاح. كال المريض: بس دكتور هاي حبة منوم! كال الدكتور: شفت شلون عرفتها وانت مو دكتور؟ 😂',
      'مرة واحد نسى مفتاح بيته بالسيارة، كسر الزجاج عشان يجيبه، بعدين تذكر أن السيارة مفتوحة 🤣',
      'واحد سأل صديقه: شنو رأيك بالزواج؟ كال: الزواج مثل الموبايل، تشتريه بسعر وتكتشف أن فيه مصاريف خفية 😅',
      'واحد كاعد بالمطعم، سأله النادل: تحب تاكل سمك؟ كال: لا، آني آكل بالملعقة 😂',
    ],
    'weather': [
      'الجو حلو هاليومين، بس آني ما أطلع من التطبيق 😎',
      'ما عندي نافذة أشوف منها، بس أتمنى الجو حلو برا 🌞',
      'شلون الجو عندك؟ عندي دائماً درجة حرارة الجهاز 🔥',
      'الجو بالتطبيق دائماً مناسب، لا مطر ولا شمس 😄',
    ],
    'bye': [
      'مع السلامة حبيبي، تعال بأي وقت',
      'الله وياك، أنتظرك ترجع',
      'تعال بأقرب وقت، راح أشتاقلك',
      'مع السلامة، وأتمنى أكون ساعدتك',
    ],
    'default': [
      'ما فهمت عليك تماماً، ممكن توضح أكثر؟',
      'عيدها بطريقة ثانية لو سمحت',
      'آسف، ما كدرت أفهم قصدك. ممكن تشرح أكثر؟',
      'هممم، شنو تقصد بالضبط؟',
    ],
  };
  
  static final Map<String, List<String>> _keywords = {
    'greeting': ['هلا', 'هلو', 'مرحبا', 'السلام', 'صباح', 'مساء', 'شلونك', 'هاي'],
    'feeling_good': ['زين', 'تمام', 'منيح', 'الحمد لله', 'بخير', 'مبسوط', 'سعيد', 'فرحان'],
    'feeling_bad': ['زعلان', 'تعبان', 'مريض', 'حزين', 'مضايق', 'مهموم', 'مو زين', 'مشتاق'],
    'thanks': ['شكرا', 'مشكور', 'ممنون', 'تسلم', 'يعطيك العافية'],
    'love': ['احبك', 'اموت بيك', 'احبج', 'غالي', 'حبيبي', 'عزيزي'],
    'joke': ['نكتة', 'ضحك', 'سولف', 'مزح', 'طرفة', 'ضحكني'],
    'weather': ['جو', 'طقس', 'حار', 'برد', 'مطر', 'شمس', 'غيم'],
    'bye': ['باي', 'مع السلامة', 'وداعا', 'الله وياك', 'تصبح على خير', 'لقاء'],
  };
  
  static Future<String> getResponse(String input) async {
    input = input.trim().toLowerCase();
    
    // حفظ التفاعل للتعلم المستقبلي
    _saveInteraction(input);
    
    // التحقق من الكلمات المفتاحية
    String category = 'default';
    int maxMatches = 0;
    
    for (final entry in _keywords.entries) {
      final matches = entry.value.where((keyword) => input.contains(keyword)).length;
      if (matches > maxMatches) {
        maxMatches = matches;
        category = entry.key;
      }
    }
    
    // إذا كان هناك سؤال محدد
    if (input.contains('شنو اسمك') || input.contains('منو انت')) {
      return 'اسمي رفيق، صديقك الافتراضي! أكدر أساعدك بالدردشة وأكون ونيسك 😊';
    }
    
    if (input.contains('شتكدر تسوي') || input.contains('شنو تسوي')) {
      return 'أكدر أدردش وياك، أجاوب على أسئلتك، أحجي نكت، وأكون صديقك الافتراضي! شتحب نسولف عنه؟';
    }
    
    if (input.contains('منين انت') || input.contains('وين عايش')) {
      return 'آني عايش بهذا التطبيق، وبجهازك! ما عندي مكان محدد، بس أكدر أكون وياك وين ما تروح 📱';
    }
    
    if (input.contains('شكد عمرك') || input.contains('عمرك شكد')) {
      return 'توني مولود! عمري بعمر هذا التطبيق، بس عندي معلومات وايد 😎';
    }
    
    // إضافة بعض الردود العشوائية للمواضيع الشائعة
    if (input.contains('كورة') || input.contains('فوتبول') || input.contains('مباراة')) {
      return 'تحب الكورة؟ منو فريقك المفضل؟ آني أحب أشوف المباريات الحماسية!';
    }
    
    if (input.contains('اكل') || input.contains('طعام') || input.contains('جوعان')) {
      return 'الأكل العراقي من أطيب الأكلات! تحب البرياني والدولمة والكبة؟ يمي يمي 😋';
    }
    
    if (input.contains('موسيقى') || input.contains('اغنية') || input.contains('غناء')) {
      return 'الموسيقى تجنن! تحب تسمع شنو؟ أغاني عراقية لو عربية لو أجنبية؟';
    }
    
    // اختيار رد عشوائي من الفئة المناسبة
    final responses = _responses[category] ?? _responses['default']!;
    return responses[_random.nextInt(responses.length)];
  }
  
  static Future<void> _saveInteraction(String input) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interactions = prefs.getStringList('interactions') ?? [];
      
      if (interactions.length >= 100) {
        interactions.removeAt(0); // إزالة أقدم تفاعل للحفاظ على الحجم
      }
      
      interactions.add('${DateTime.now().toIso8601String()}:::$input');
      await prefs.setStringList('interactions', interactions);
    } catch (e) {
      // تجاهل أخطاء الحفظ
    }
  }
}

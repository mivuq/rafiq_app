import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rafiq_bot.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FlutterTts flutterTts = FlutterTts();
  bool isTyping = false;
  bool isSpeechEnabled = false;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupTts();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    
    // إضافة رسالة ترحيبية
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        messages.add({
          'sender': 'rafiq',
          'text': 'هلا بيك! أني رفيق، صديقك الافتراضي. شلونك اليوم؟',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'isAnimated': true,
        });
      });
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    flutterTts.stop();
    super.dispose();
  }
  
  Future<void> _setupTts() async {
    await flutterTts.setLanguage("ar");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isSpeechEnabled = prefs.getBool('isSpeechEnabled') ?? false;
    });
  }
  
  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMessages = prefs.getStringList('messages') ?? [];
    
    if (savedMessages.isNotEmpty) {
      setState(() {
        messages.addAll(savedMessages.map((msg) {
          final Map<String, dynamic> msgMap = Map<String, dynamic>.from(
            Map<String, dynamic>.from(
              Map.fromEntries(
                msg.split('|||').map((e) {
                  final parts = e.split(':::');
                  if (parts.length == 2) {
                    if (parts[0] == 'timestamp') {
                      return MapEntry(parts[0], int.parse(parts[1]));
                    } else if (parts[0] == 'isAnimated') {
                      return MapEntry(parts[0], parts[1] == 'true');
                    }
                    return MapEntry(parts[0], parts[1]);
                  }
                  return MapEntry('', '');
                }).where((e) => e.key.isNotEmpty),
              ),
            ),
          );
          msgMap['isAnimated'] = false; // لا نريد تحريك الرسائل المحفوظة
          return msgMap;
        }));
      });
    }
  }
  
  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesToSave = messages.map((msg) {
      return [
        'sender:::${msg['sender']}',
        'text:::${msg['text']}',
        'timestamp:::${msg['timestamp']}',
        'isAnimated:::${msg['isAnimated']}',
      ].join('|||');
    }).toList();
    
    await prefs.setStringList('messages', messagesToSave);
  }
  
  void _toggleSpeech() async {
    setState(() {
      isSpeechEnabled = !isSpeechEnabled;
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSpeechEnabled', isSpeechEnabled);
    
    if (isSpeechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تفعيل النطق الصوتي')),
      );
    } else {
      await flutterTts.stop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إيقاف النطق الصوتي')),
      );
    }
  }
  
  void _clearChat() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('مسح المحادثة'),
        content: Text('هل أنت متأكد من رغبتك في مسح جميع الرسائل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                messages.clear();
                messages.add({
                  'sender': 'rafiq',
                  'text': 'تم مسح المحادثة. شلونك اليوم؟',
                  'timestamp': DateTime.now().millisecondsSinceEpoch,
                  'isAnimated': true,
                });
              });
              _saveMessages();
              Navigator.pop(context);
            },
            child: Text('مسح'),
          ),
        ],
      ),
    );
  }
  
  void sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    
    final userMessage = {
      'sender': 'user',
      'text': message.trim(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'isAnimated': false,
    };
    
    setState(() {
      messages.add(userMessage);
      isTyping = true;
    });
    
    controller.clear();
    _scrollToBottom();
    
    // محاكاة تأخير الرد للواقعية
    await Future.delayed(Duration(milliseconds: 500));
    
    final response = await RafiqBot.getResponse(message);
    
    final botMessage = {
      'sender': 'rafiq',
      'text': response,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'isAnimated': true,
    };
    
    setState(() {
      messages.add(botMessage);
      isTyping = false;
    });
    
    _scrollToBottom();
    _saveMessages();
    
    if (isSpeechEnabled) {
      await flutterTts.speak(response);
    }
  }
  
  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Icon(
                Icons.smart_toy_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 10),
            Text('رفيق'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isSpeechEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: _toggleSpeech,
            tooltip: isSpeechEnabled ? 'إيقاف النطق' : 'تفعيل النطق',
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.setThemeMode(
                isDarkMode ? ThemeMode.light : ThemeMode.dark,
              );
            },
            tooltip: isDarkMode ? 'الوضع الفاتح' : 'الوضع المظلم',
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('مسح المحادثة'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'amoled',
                child: Row(
                  children: [
                    Icon(Icons.contrast),
                    SizedBox(width: 8),
                    Text(themeProvider.useAmoledDark ? 'إيقاف وضع AMOLED' : 'تفعيل وضع AMOLED'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'clear') {
                _clearChat();
              } else if (value == 'amoled') {
                themeProvider.toggleAmoledDark();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.network(
                          'https://assets9.lottiefiles.com/packages/lf20_kp5gmhbh.json',
                          width: 200,
                          height: 200,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'ابدأ محادثة مع رفيق!',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: messages.length + (isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        // عنصر "جاري الكتابة..."
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.only(top: 8, right: 50),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('جاري الكتابة'),
                                SizedBox(width: 8),
                                SizedBox(
                                  width: 30,
                                  child: AnimatedTextKit(
                                    animatedTexts: [
                                      TypewriterAnimatedText(
                                        '...',
                                        speed: Duration(milliseconds: 300),
                                      ),
                                    ],
                                    repeatForever: true,
                                    displayFullTextOnTap: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      final msg = messages[index];
                      final isUser = msg['sender'] == 'user';
                      final showTime = index == 0 || 
                          DateTime.fromMillisecondsSinceEpoch(msg['timestamp']).day != 
                          DateTime.fromMillisecondsSinceEpoch(messages[index - 1]['timestamp']).day;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showTime)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _formatDate(DateTime.fromMillisecondsSinceEpoch(msg['timestamp'])),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              child: Container(
                                margin: EdgeInsets.only(
                                  bottom: 8,
                                  left: isUser ? 50 : 0,
                                  right: isUser ? 0 : 50,
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    msg['isAnimated'] && !isUser
                                        ? AnimatedTextKit(
                                            animatedTexts: [
                                              TypewriterAnimatedText(
                                                msg['text'],
                                                speed: Duration(milliseconds: 50),
                                                textStyle: TextStyle(
                                                  color: isUser
                                                      ? Colors.white
                                                      : Theme.of(context).textTheme.bodyLarge?.color,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                            totalRepeatCount: 1,
                                            displayFullTextOnTap: true,
                                          )
                                        : Text(
                                            msg['text'],
                                            style: TextStyle(
                                              color: isUser
                                                  ? Colors.white
                                                  : Theme.of(context).textTheme.bodyLarge?.color,
                                              fontSize: 16,
                                            ),
                                          ),
                                    SizedBox(height: 4),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        _formatTime(DateTime.fromMillisecondsSinceEpoch(msg['timestamp'])),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isUser
                                              ? Colors.white.withOpacity(0.7)
                                              : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: controller,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة...',
                        hintStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (text) => sendMessage(text),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () => sendMessage(controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (messageDate == today) {
      return 'اليوم';
    } else if (messageDate == yesterday) {
      return 'أمس';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initSettings =
      InitializationSettings(android: androidInitSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Android 13+ izin isteme
  final bool? granted = await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

  print("Bildirim izni verildi mi: $granted");
}

final TimeController timeController = Get.put(TimeController());

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await _showBigPictureNotification();
    return Future.value(true);
  });
}

Future<void> _showBigPictureNotification() async {
  //const String largeIconPath = 'app_icon'; // drawable'daki icon (Android için)
  //const String bigPicturePath = 'notification_bg'; // drawable'daki büyük resim

  // 1. Text dosyasını oku ve satırları al
  final String textData = await rootBundle.loadString('assets/texts.txt');
  final List<String> textLines =
      textData.split('\n').where((line) => line.trim().isNotEmpty).toList();
  final randomText = textLines[Random().nextInt(textLines.length)];

  // 2. Görseli seç
  final imageNames = [
    '1.jpg',
    '2.jpg',
    '3.jpg',
  ];
  final randomImage = imageNames[Random().nextInt(imageNames.length)];
  final String imageAssetPath = 'assets/imgs/$randomImage';

  // 3. Byte olarak oku ve geçici dosyaya yaz
  final ByteData bytes = await rootBundle.load(imageAssetPath);
  final Uint8List list = bytes.buffer.asUint8List();

  final tempDir = await getTemporaryDirectory();
  final File tempFile = File('${tempDir.path}/$randomImage');
  await tempFile.writeAsBytes(list);



  final BigPictureStyleInformation bigPictureStyle = BigPictureStyleInformation(
    FilePathAndroidBitmap(tempFile.path),
    contentTitle: 'DİK DUR!',
    summaryText: randomText,
    htmlFormatContentTitle: true,
  );

  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'big_picture_channel',
    'Büyük Resimli Bildirimler',
    channelDescription: 'Resim içeren hatırlatıcı bildirimleri',
    importance: Importance.high,
    priority: Priority.high,
    styleInformation: bigPictureStyle,
    autoCancel: true, // Kullanıcı tıklayarak kapatamasın
    
  );

  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    'DİK DUR!',
    randomText,
    platformChannelSpecifics,
  );
}
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeNotifications();
  // WorkManager başlatma
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  // Bildirim plugin başlatma
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) {
    
  },
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 16, 46, 80),
        body: Center(
          child: Column(
            children: [
              Container(
                color: Colors.orange[400],
                width: size.width,
                height: size.height * 0.05,
                child: Center(
                  child: Text(
                    'Dik durmalısın',
                    style: GoogleFonts.montserrat(color: Color.fromARGB(255, 16, 46, 80), fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Container(height: size.height*0.25,),
              Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Saat',
                          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 22),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.02),
                    timeSelector(),
                    SizedBox(height: size.height * 0.02),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                            'Buradan süre seçerek, sana ne sıklıkta hatırlatıcı bildirim göndereceğimi seçebilirsin.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                    ),
                    SizedBox(height: size.height * 0.05),
                    TextButton(onPressed:() {
                    //print(timeController.currentValue*60),
                    //_showBigPictureNotification();
                    
                     try {
                          Workmanager().registerPeriodicTask(
                            "big_picture_task",
                            "bigPictureNotification",
                            frequency: Duration(minutes: 15),
                            constraints: Constraints(
                              networkType: NetworkType.connected,
                            ),
                          );
                          Fluttertoast.showToast(
                          msg: "Bildirimler başarıyla ayarlandı!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                        );
                        } catch (e) {
                           Fluttertoast.showToast(
                            msg: "Hata: $e",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                          );
                        }
                      },
                      child: Container(
                      width: size.width * 0.3,
                      height: size.height * 0.05,
                      decoration: BoxDecoration(
                        color: Colors.orange[500],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text("Kaydet", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w800),)))),
                      TextButton(onPressed:() => {
                    //print(timeController.currentValue*60),
                    //_showBigPictureNotification(),
                    stopReminder(),
                    }, child: Container(
                      width: size.width * 0.3,
                      height: size.height * 0.05,
                      decoration: BoxDecoration(
                        color: Colors.orange[500],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text("Durdur", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w800),))))
                  ],
                ),

            ],
          ),
        ),
      ),
      
    );
  }
  Widget timeSelector() {
  return Column(
      children: <Widget>[
         Obx(() => NumberPicker(
          value: timeController.currentValue,
          minValue: 1,
          maxValue: 24,
          onChanged: (value) => timeController.setTime(value),
          textStyle: GoogleFonts.montserrat(color: Colors.orange[800], fontWeight: FontWeight.w600, fontSize: 22),
          selectedTextStyle: GoogleFonts.montserrat(color: Colors.orange[400], fontWeight: FontWeight.w600, fontSize: 22),
        )),
      ],
    );
  }

  void stopReminder() {
  Workmanager().cancelByUniqueName("big_picture_task");
}
}
class TimeController extends GetxController {
  var pickervalue = 1.obs;
  int get currentValue => pickervalue.value;
  void setTime(int value) {
    pickervalue.value = value;
  }
}


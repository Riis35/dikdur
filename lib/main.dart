import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'globals.dart' as globals;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:get/get.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final TimeController timeController = Get.put(TimeController());

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await _showBigPictureNotification();
    return Future.value(true);
  });
}

Future<void> _showBigPictureNotification() async {
  const String largeIconPath = 'app_icon'; // drawable'daki icon (Android için)
  const String bigPicturePath = 'notification_bg'; // drawable'daki büyük resim

  final BigPictureStyleInformation bigPictureStyle = BigPictureStyleInformation(
    DrawableResourceAndroidBitmap(bigPicturePath),
    largeIcon: DrawableResourceAndroidBitmap(largeIconPath),
    contentTitle: 'DİK DUR!',
    summaryText: 'BELİN YAMUK KALACAK KARDEŞ DİK DUR!',
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
    autoCancel: false, // Kullanıcı tıklayarak kapatamasın
  );

  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Hatırlatma',
    'Zamanınız doldu!',
    platformChannelSpecifics,
  );
}
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
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
    initializationSettings
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
                    TextButton(onPressed:() => {
                      Workmanager().registerPeriodicTask(
                    "big_picture_task",
                    "bigPictureNotification",
                    frequency: Duration(minutes: globals.Globals().dateTime),
                    constraints: Constraints(
                      networkType: NetworkType.connected,
                    ),
                  )
                    }, child: Container(
                      width: size.width * 0.3,
                      height: size.height * 0.05,
                      decoration: BoxDecoration(
                        color: Colors.orange[500],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text("Kaydet", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w800),)))),
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
        NumberPicker(
          value: timeController.currentValue,
          minValue: 1,
          maxValue: 24,
          onChanged: (value) => timeController.setTime(value),
        ),
      ],
    );
  }
}
class TimeController extends GetxController {
  var pickervalue = 1.obs;
  int get currentValue => pickervalue.value;
  void setTime(int value) {
    pickervalue.value = value;
  }
}


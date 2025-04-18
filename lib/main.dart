import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'globals.dart' as globals;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:get/get.dart';

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
    autoCancel: true, // Kullanıcı tıklayarak kapatamasın
    
  );

  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    'DİK DUR!',
    'SAĞLIK İÇİN DİK DUR!',
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
    // Boş bırakıyoruz
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
                    TextButton(onPressed:() => {
                    //print(timeController.currentValue*60),
                    _showBigPictureNotification(),
                    /*
                      Workmanager().registerPeriodicTask(
                    "big_picture_task",
                    "bigPictureNotification",
                    frequency: Duration(minutes: 15),
                    constraints: Constraints(
                      networkType: NetworkType.connected,
                    ),
                  )*/
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
}
class TimeController extends GetxController {
  var pickervalue = 1.obs;
  int get currentValue => pickervalue.value;
  void setTime(int value) {
    pickervalue.value = value;
  }
}


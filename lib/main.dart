import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';

const String baseURL = 'http://gofitp3l.000webhostapp.com/';
const Color primaryColor = Color(0xFFF2542D);
const Color secondaryColor = Color(0xFF127475);
late SharedPreferences prefs;

void main() async =>
    {prefs = await SharedPreferences.getInstance(), runApp(const GoFitApp())};

class GoFitApp extends StatefulWidget {
  const GoFitApp({super.key});

  @override
  State<GoFitApp> createState() => _GoFitAppState();
}

class _GoFitAppState extends State<GoFitApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        MonthYearPickerLocalizations.delegate, // Add this line
      ],
      supportedLocales: [
        Locale('en'), // Add your desired locales here
      ],
      home: GoFit(),
    );
  }
}

class GoFit extends StatefulWidget {
  const GoFit({super.key});

  @override
  State<GoFit> createState() => _GoFitState();
}

class _GoFitState extends State<GoFit> {
  Future<String> fetchData() async {
    final response = await http.get(Uri.parse('${baseURL}user/informasi'));
    // Simulating an asynchronous data fetching operation
    return response.body;
  }

  int _selectedIndex = 0;
  static late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      FutureBuilder<String>(
        future: fetchData(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<dynamic> dailySchedules =
                jsonDecode(snapshot.data!)['JADWAL_HARIAN'];
            List<dynamic> promos = jsonDecode(snapshot.data!)['PROMO'];
            List<dynamic> classes = jsonDecode(snapshot.data!)['KELAS'];
            return ListView(
                children: <Widget>[const Text('Daily Schedule')] +
                    [
                      CarouselSlider(
                          options: CarouselOptions(height: 65.0),
                          items: dailySchedules
                              .map((dailySchedule) => Card(
                                  color: primaryColor,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Column(children: [
                                      Text(dailySchedule['NAMA_KELAS'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(dailySchedule[
                                                  'TANGGAL_JADWAL_HARIAN']
                                              .substring(0, 10) +
                                          '\n' +
                                          [
                                            '06.00',
                                            '06.30',
                                            '07.00',
                                            '07.30',
                                            '08.00',
                                            '08.30',
                                            '09.00',
                                            '09.30',
                                            '10.00',
                                            '17.00',
                                            '17.30',
                                            '18.00',
                                            '18.30',
                                            '19.00',
                                            '19.30',
                                            '20.00',
                                            '20.30',
                                            '21.00',
                                          ][int.parse(
                                              dailySchedule['SESI_JADWAL'])])
                                    ]),
                                  )))
                              .toList())
                    ] +
                    <Widget>[const Text('Class')] +
                    [
                      CarouselSlider(
                          options: CarouselOptions(height: 46.0),
                          items: classes
                              .map((kelas) => Card(
                                  color: primaryColor,
                                  child: SizedBox(
                                      width: double.infinity,
                                      child: Column(children: [
                                        Text(kelas['NAMA_KELAS'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text('Rp${kelas['TARIF_KELAS']},00'),
                                      ]))))
                              .toList())
                    ] +
                    <Widget>[const Text('Promo')] +
                    [
                      CarouselSlider(
                          options: CarouselOptions(height: 274.0),
                          items: promos
                              .map((promo) => Card(
                                  color: primaryColor,
                                  child: SizedBox(
                                      width: double.infinity,
                                      child: Column(children: [
                                        Text(promo['KALIMAT_PROMO'])
                                      ]))))
                              .toList())
                    ]);
          }
        },
      ),
      const Activity(),
      const Account()
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Activity',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
            backgroundColor: primaryColor,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}

class BookGymCard extends StatefulWidget {
  const BookGymCard({
    Key? key,
  }) : super(key: key);

  @override
  State<BookGymCard> createState() => _BookGymCardState();
}

class _BookGymCardState extends State<BookGymCard> {
  String selectedTimeSlot = '';
  List<String> timeSlots = [
    '07.00-09.00',
    '09.00-11.00',
    '11.00-13.00',
    '13.00-15.00',
    '15.00-17.00',
    '17.00-19.00',
    '19.00-21.00',
  ];
  List<String> dateSlots = [
    DateTime.now().toIso8601String().substring(0, 10),
    DateTime.now()
        .add(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10),
    DateTime.now()
        .add(const Duration(days: 2))
        .toIso8601String()
        .substring(0, 10),
    DateTime.now()
        .add(const Duration(days: 3))
        .toIso8601String()
        .substring(0, 10),
    DateTime.now()
        .add(const Duration(days: 4))
        .toIso8601String()
        .substring(0, 10),
    DateTime.now()
        .add(const Duration(days: 5))
        .toIso8601String()
        .substring(0, 10),
    DateTime.now()
        .add(const Duration(days: 6))
        .toIso8601String()
        .substring(0, 10),
  ];
  String selectedDateSlot = '';
  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      title: const Text('Select date and session:'),
      subtitle: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Column(
                children: dateSlots
                    .map((dateSlot) => RadioListTile(
                          title: Text(dateSlot),
                          contentPadding: EdgeInsets.zero,
                          value: dateSlot,
                          groupValue: selectedDateSlot,
                          onChanged: (value) {
                            setState(() {
                              selectedDateSlot = value as String;
                            });
                          },
                        ))
                    .toList(),
              )),
              Expanded(
                  child: Column(
                children: timeSlots
                    .map((timeSlot) => RadioListTile(
                          title: Text(timeSlot),
                          value: timeSlot,
                          groupValue: selectedTimeSlot,
                          onChanged: (value) {
                            setState(() {
                              selectedTimeSlot = value as String;
                            });
                          },
                        ))
                    .toList(),
              )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: (selectedDateSlot.isEmpty ||
                            selectedTimeSlot.isEmpty)
                        ? null
                        : () {
                            showDialog(
                                context: context,
                                builder: (BuildContext bookContext) {
                                  return AlertDialog(
                                    title: const Text('Book'),
                                    content: Text(
                                        'Are you sure you want to book gym for $selectedDateSlot at $selectedTimeSlot?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(bookContext).pop();
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(bookContext).pop();
                                          http
                                              .post(
                                                  Uri.parse(
                                                      '${baseURL}bookinggym/create'),
                                                  body: jsonEncode({
                                                    'ID_USER': jsonDecode(
                                                            jsonDecode(
                                                                prefs.getString(
                                                                    'user')!))[
                                                        'ID_USER'],
                                                    'ID_MEMBER': jsonDecode(
                                                            jsonDecode(
                                                                prefs.getString(
                                                                    'user')!))[
                                                        'ID_MEMBER'],
                                                    'TANGGAL_BOOKING_GYM':
                                                        selectedDateSlot,
                                                    'SESI_BOOKING_GYM': selectedTimeSlot ==
                                                            '07.00-09.00'
                                                        ? 0
                                                        : selectedTimeSlot ==
                                                                '09.00-11.00'
                                                            ? 1
                                                            : selectedTimeSlot ==
                                                                    '11.00-13.00'
                                                                ? 2
                                                                : selectedTimeSlot ==
                                                                        '13.00-15.00'
                                                                    ? 3
                                                                    : selectedTimeSlot ==
                                                                            '15.00-17.00'
                                                                        ? 4
                                                                        : selectedTimeSlot ==
                                                                                '17.00-19.00'
                                                                            ? 5
                                                                            : selectedTimeSlot == '19.00-21.00'
                                                                                ? 6
                                                                                : null,
                                                    'TOKEN': jsonDecode(
                                                            jsonDecode(
                                                                prefs.getString(
                                                                    'user')!))[
                                                        'TOKEN']
                                                  }))
                                              .then((response) {
                                            if (response.statusCode == 201) {
                                              const snackBar = SnackBar(
                                                  content:
                                                      Text('Booking Success!'),
                                                  backgroundColor:
                                                      Colors.green);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackBar);
                                              setState(() {});
                                            } else if (response.statusCode ==
                                                400) {
                                              const snackBar = SnackBar(
                                                  content: Text(
                                                      'Booking Failed! You can only book a gym once per day...'),
                                                  backgroundColor: Colors.red);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackBar);
                                            } else {
                                              const snackBar = SnackBar(
                                                  content:
                                                      Text('Booking Failed!'),
                                                  backgroundColor: Colors.red);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackBar);
                                            }
                                          });
                                        },
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  );
                                });
                          },
                    child: const Text('Book')),
              ),
            ],
          )
        ],
      ),
    ));
  }
}

class Activity extends StatefulWidget {
  const Activity({super.key});

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  List<dynamic> memberListOfSchedule = [];
  Future<String> fetchDataInstructor() async {
    final response =
        await http.post(Uri.parse('${baseURL}instruktur/retrievejadwal'),
            body: jsonEncode({
              'ID_USER':
                  jsonDecode(jsonDecode(prefs.getString('user')!))['ID_USER'],
              'TOKEN': jsonDecode(jsonDecode(prefs.getString('user')!))['TOKEN']
            }));
    // Simulating an asynchronous data fetching operation
    return response.body;
  }

  Future<String> fetchDataMember() async {
    final response =
        await http.post(Uri.parse('${baseURL}member/retrievebooking'),
            body: jsonEncode({
              'ID_USER':
                  jsonDecode(jsonDecode(prefs.getString('user')!))['ID_USER'],
              'TOKEN': jsonDecode(jsonDecode(prefs.getString('user')!))['TOKEN']
            }));
    // Simulating an asynchronous data fetching operation
    return response.body;
  }

  Future<String> fetchDataEmployee() async {
    final response =
        await http.get(Uri.parse('${baseURL}pegawai/retrievekelashariini'));
    // Simulating an asynchronous data fetching operation
    return response.body;
  }

  Future<String> fetchDataClassBooking() async {
    final response =
        await http.post(Uri.parse('${baseURL}bookingkelas/listkelas'),
            body: jsonEncode({
              'ID_USER':
                  jsonDecode(jsonDecode(prefs.getString('user')!))['ID_USER'],
              'TOKEN': jsonDecode(jsonDecode(prefs.getString('user')!))['TOKEN']
            }));
    // Simulating an asynchronous data fetching operation
    return response.body;
  }

  @override
  Widget build(BuildContext context) {
    return prefs.getString('user') == null
        ? const Center(
            child: Text('Please login first!'),
          )
        : jsonDecode(jsonDecode(prefs.getString('user')!))['ID_INSTRUKTUR'] !=
                null
            ? FutureBuilder(
                future: fetchDataInstructor(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    var schedules = jsonDecode(snapshot.data!);
                    List<Widget> widgetList = <Widget>[];
                    final TextEditingController statementController =
                        TextEditingController();
                    final requestPermissionFormKey = GlobalKey<FormState>();
                    widgetList.add(
                      const Text('Schedule'),
                    );
                    for (var schedule in schedules) {
                      widgetList.add(
                        Card(
                          child: ListTile(
                              title: Text(schedule['NAMA_KELAS']),
                              subtitle: Text(schedule['TANGGAL_JADWAL_HARIAN']
                                      .substring(0, 10) +
                                  '\n' +
                                  [
                                    '06.00',
                                    '06.30',
                                    '07.00',
                                    '07.30',
                                    '08.00',
                                    '08.30',
                                    '09.00',
                                    '09.30',
                                    '10.00',
                                    '17.00',
                                    '17.30',
                                    '18.00',
                                    '18.30',
                                    '19.00',
                                    '19.30',
                                    '20.00',
                                    '20.30',
                                    '21.00',
                                  ][int.parse(schedule['SESI_JADWAL'])]),
                              trailing:
                                  schedule['PRESENSI_INSTRUKTUR']
                                              ['STATUS_PRESENSI_INSTRUKTUR'] ==
                                          null
                                      ? ElevatedButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext
                                                    requestPermissionDialogContext) {
                                                  return AlertDialog(
                                                      title:
                                                          const Text("Confirm"),
                                                      content: Form(
                                                        key:
                                                            requestPermissionFormKey,
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child:
                                                                  TextFormField(
                                                                      controller:
                                                                          statementController,
                                                                      decoration: const InputDecoration(
                                                                          border:
                                                                              OutlineInputBorder(),
                                                                          labelText:
                                                                              'Statement'),
                                                                      validator:
                                                                          (value) {
                                                                        if (statementController
                                                                            .text
                                                                            .isEmpty) {
                                                                          return 'Statement is empty';
                                                                        }
                                                                      }),
                                                            ),
                                                            Row(
                                                              children: [
                                                                const Spacer(),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child:
                                                                      ElevatedButton(
                                                                    style: ButtonStyle(
                                                                        backgroundColor:
                                                                            MaterialStateProperty.all<Color>(primaryColor)),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          requestPermissionDialogContext);
                                                                    },
                                                                    child: const Text(
                                                                        'CANCEL'),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child:
                                                                      ElevatedButton(
                                                                    style: ButtonStyle(
                                                                        backgroundColor:
                                                                            MaterialStateProperty.all<Color>(primaryColor)),
                                                                    onPressed:
                                                                        () {
                                                                      if (requestPermissionFormKey
                                                                          .currentState!
                                                                          .validate()) {
                                                                        Navigator.pop(
                                                                            requestPermissionDialogContext);
                                                                        http
                                                                            .post(Uri.parse('${baseURL}presensiinstruktur/ajukanizin'),
                                                                                body: jsonEncode({
                                                                                  'ID_PRESENSI_INSTRUKTUR': schedule['PRESENSI_INSTRUKTUR']['ID_PRESENSI_INSTRUKTUR'],
                                                                                  'KETERANGAN_PRESENSI_INSTRUKTUR': statementController.text,
                                                                                  'TOKEN': jsonDecode(jsonDecode(prefs.getString('user')!))['TOKEN']
                                                                                }))
                                                                            .then((value) {
                                                                          if (value.statusCode ==
                                                                              200) {
                                                                            const snackBar =
                                                                                SnackBar(content: Text('Permission request was successful!'), backgroundColor: Colors.green);
                                                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                            setState(() {});
                                                                          } else {
                                                                            const snackBar =
                                                                                SnackBar(content: Text('An error occurred while request the permission!'), backgroundColor: Colors.red);
                                                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                          }
                                                                        });
                                                                      }
                                                                    },
                                                                    child: const Text(
                                                                        'YES'),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ));
                                                });
                                          },
                                          child:
                                              const Text('Request Permission'),
                                        )
                                      : (schedule['PRESENSI_INSTRUKTUR'][
                                                  'STATUS_PRESENSI_INSTRUKTUR'] ==
                                              '0'
                                          ? const Text('Absent')
                                          : schedule['PRESENSI_INSTRUKTUR']['STATUS_PRESENSI_INSTRUKTUR'] ==
                                                  '1'
                                              ? (schedule['PRESENSI_INSTRUKTUR'][
                                                          'JAM_SELESAI_PRESENSI_INSTRUKTUR'] ==
                                                      null
                                                  ? ElevatedButton(
                                                      onPressed: () {
                                                        memberListOfSchedule =
                                                            schedule[
                                                                'DAFTAR_MEMBER'];
                                                        showDialog(
                                                            context: context,
                                                            builder: (_) =>
                                                                StatefulBuilder(builder:
                                                                    (BuildContext
                                                                            context,
                                                                        StateSetter
                                                                            setStateDialog) {
                                                                  return Dialog(
                                                                    insetPadding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    child:
                                                                        Scaffold(
                                                                      appBar:
                                                                          AppBar(
                                                                        title: const Text(
                                                                            'Member Attendance'),
                                                                      ),
                                                                      body: Center(
                                                                          child: ListView(
                                                                        children: memberListOfSchedule
                                                                            .map((member) => ListTile(
                                                                                  title: Text(member['NAMA_USER']),
                                                                                  trailing: member['STATUS_PRESENSI_KELAS'] == null
                                                                                      ? IconButton(
                                                                                          onPressed: () {
                                                                                            http
                                                                                                .post(Uri.parse('${baseURL}presensikelas/hadirkan'),
                                                                                                    body: jsonEncode({
                                                                                                      'NO_STRUK_PRESENSI_KELAS': member['NO_STRUK_PRESENSI_KELAS'],
                                                                                                      'TOKEN': jsonDecode(jsonDecode(prefs.getString('user')!))['TOKEN']
                                                                                                    }))
                                                                                                .then((value) {
                                                                                              if (value.statusCode == 200) {
                                                                                                const snackBar = SnackBar(content: Text('Success attend member!'), backgroundColor: Colors.green);
                                                                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                                                setState(() {});
                                                                                                var oldMember = member;
                                                                                                member['STATUS_PRESENSI_KELAS'] = '1';
                                                                                                memberListOfSchedule[memberListOfSchedule.indexOf(oldMember)] = member;
                                                                                                setStateDialog(() {});
                                                                                              } else {
                                                                                                const snackBar = SnackBar(content: Text('An error occurred while attend member!'), backgroundColor: Colors.red);
                                                                                                print(value.body);
                                                                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                                              }
                                                                                            });
                                                                                          },
                                                                                          icon: const Icon(Icons.check_box_outline_blank),
                                                                                          color: primaryColor)
                                                                                      : IconButton(
                                                                                          onPressed: () {
                                                                                            http
                                                                                                .post(Uri.parse('${baseURL}presensikelas/absenkan'),
                                                                                                    body: jsonEncode({
                                                                                                      'NO_STRUK_PRESENSI_KELAS': member['NO_STRUK_PRESENSI_KELAS'],
                                                                                                      'TOKEN': jsonDecode(jsonDecode(prefs.getString('user')!))['TOKEN']
                                                                                                    }))
                                                                                                .then((value) {
                                                                                              if (value.statusCode == 200) {
                                                                                                const snackBar = SnackBar(content: Text('Success absent member!'), backgroundColor: Colors.green);
                                                                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                                                setState(() {});
                                                                                                var oldMember = member;
                                                                                                member['STATUS_PRESENSI_KELAS'] = null;
                                                                                                memberListOfSchedule[memberListOfSchedule.indexOf(oldMember)] = member;
                                                                                                setStateDialog(() {});
                                                                                              } else {
                                                                                                const snackBar = SnackBar(content: Text('An error occurred while absent member!'), backgroundColor: Colors.red);
                                                                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                                              }
                                                                                            });
                                                                                          },
                                                                                          icon: const Icon(Icons.check_box),
                                                                                          color: primaryColor),
                                                                                ))
                                                                            .cast<Widget>()
                                                                            .toList(),
                                                                      )),
                                                                    ),
                                                                  );
                                                                }));
                                                      },
                                                      child: const Text(
                                                          'Member Attendance'))
                                                  : const Text('Attended'))
                                              : schedule['PRESENSI_INSTRUKTUR']
                                                          ['STATUS_PRESENSI_INSTRUKTUR'] ==
                                                      '2'
                                                  ? const Text('Late')
                                                  : schedule['PRESENSI_INSTRUKTUR']['STATUS_PRESENSI_INSTRUKTUR'] == '3'
                                                      ? const Text('Not Yet Approved Permission')
                                                      : schedule['PRESENSI_INSTRUKTUR']['STATUS_PRESENSI_INSTRUKTUR'] == '4'
                                                          ? const Text('Permission Approved')
                                                          : const Text('Permission Refused'))),
                        ),
                      );
                    }
                    return ListView(children: widgetList);
                  }
                },
              )
            : jsonDecode(jsonDecode(prefs.getString('user')!))['ID_MEMBER'] !=
                    null
                ? FutureBuilder(
                    future: fetchDataMember(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        var bookingGyms =
                            jsonDecode(snapshot.data!)['BOOKING_GYM'];
                        List<Widget> widgetList = <Widget>[];
                        widgetList.add(
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Gym Booking',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        );
                        for (var bookingGym in bookingGyms) {
                          widgetList.add(Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Card(
                              child: ListTile(
                                title: Text(bookingGym['TANGGAL_BOOKING_GYM']
                                    .substring(0, 10)),
                                subtitle: Text([
                                  '07.00-09.00',
                                  '09.00-11.00',
                                  '11.00-13.00',
                                  '13.00-15.00',
                                  '15.00-17.00',
                                  '17.00-19.00',
                                  '19.00-21.00',
                                ][int.parse(bookingGym['SESI_BOOKING_GYM'])]),
                                trailing:
                                    DateTime.parse(bookingGym[
                                                'TANGGAL_BOOKING_GYM'])
                                            .subtract(const Duration(days: 1))
                                            .isAfter(DateTime(
                                                DateTime.now().year,
                                                DateTime.now().month,
                                                DateTime.now().day - 1,
                                                00,
                                                00,
                                                00))
                                        ? ElevatedButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext
                                                      cancelBookDialogContext) {
                                                    return AlertDialog(
                                                        title: const Text(
                                                            "Confirm"),
                                                        content: Form(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8.0),
                                                                  child: Text(
                                                                      'Are you sure you wath to cancel gym booking?')),
                                                              Row(
                                                                children: [
                                                                  const Spacer(),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        ElevatedButton(
                                                                      style: ButtonStyle(
                                                                          backgroundColor:
                                                                              MaterialStateProperty.all<Color>(primaryColor)),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            cancelBookDialogContext);
                                                                      },
                                                                      child: const Text(
                                                                          'CANCEL'),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        ElevatedButton(
                                                                      style: ButtonStyle(
                                                                          backgroundColor:
                                                                              MaterialStateProperty.all<Color>(primaryColor)),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            cancelBookDialogContext);
                                                                        http
                                                                            .post(Uri.parse('${baseURL}bookinggym/delete'),
                                                                                body: jsonEncode({
                                                                                  'ID_BOOKING_GYM': bookingGym['ID_BOOKING_GYM'],
                                                                                  'TOKEN': jsonDecode(jsonDecode(prefs.getString('user')!))['TOKEN']
                                                                                }))
                                                                            .then((value) {
                                                                          if (value.statusCode ==
                                                                              200) {
                                                                            const snackBar =
                                                                                SnackBar(content: Text('Book canceled'), backgroundColor: Colors.green);
                                                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                            setState(() {});
                                                                          } else {
                                                                            const snackBar =
                                                                                SnackBar(content: Text('An error occurred while canceling book!'), backgroundColor: Colors.red);
                                                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                          }
                                                                        });
                                                                      },
                                                                      child: const Text(
                                                                          'YES'),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ));
                                                  });
                                            },
                                            child: const Text('Cancel Book'),
                                          )
                                        : null,
                              ),
                            ),
                          ));
                        }
                        widgetList.add(Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder:
                                        (_) => StatefulBuilder(builder:
                                                (BuildContext context,
                                                    StateSetter
                                                        setStateDialog) {
                                              return Dialog(
                                                insetPadding: EdgeInsets.zero,
                                                child: Scaffold(
                                                    appBar: AppBar(
                                                      title: const Text(
                                                          'New Book'),
                                                    ),
                                                    body: FutureBuilder(
                                                      future:
                                                          fetchDataClassBooking(),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          );
                                                        } else if (snapshot
                                                            .hasError) {
                                                          return Center(
                                                            child: Text(
                                                                'Error: ${snapshot.error}'),
                                                          );
                                                        } else {
                                                          dynamic data =
                                                              jsonDecode(
                                                                  snapshot
                                                                      .data!);
                                                          var activationStatus =
                                                              data[0][
                                                                  'STATUS_AKTIVASI'];
                                                          if (activationStatus ==
                                                              '0') {
                                                            return const Center(
                                                              child: Text(
                                                                  'Please activate your account first!'),
                                                            );
                                                          } else {
                                                            var schedules =
                                                                data.skip(1);
                                                            List<Widget>
                                                                widgetList =
                                                                <Widget>[];
                                                            widgetList.add(
                                                                const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                  'Book gym or class',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          40.0)),
                                                            ));
                                                            widgetList.add(
                                                                const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              child: Text('Gym',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20.0)),
                                                            ));
                                                            widgetList.add(
                                                                const BookGymCard());
                                                            widgetList.add(
                                                                const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                  'Class',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20.0)),
                                                            ));
                                                            for (var schedule
                                                                in schedules) {
                                                              for (var scheduleItems
                                                                  in schedule) {
                                                                for (var scheduleItem
                                                                    in scheduleItems) {
                                                                  widgetList
                                                                      .add(
                                                                    Card(
                                                                        child:
                                                                            ListTile(
                                                                      title: Text(
                                                                          scheduleItem[
                                                                              'NAMA_KELAS']),
                                                                      subtitle: Text((scheduleItem['JAD_ID_JADWAL'] == null
                                                                              ? scheduleItem['NAMA_USER']
                                                                              : scheduleItem['NAMA_USER'] + ' (replacing ' + scheduleItem['NAMA_INSTRUKTUR_SEBELUMNYA'] + ')') +
                                                                          '\n' +
                                                                          scheduleItem['TANGGAL_JADWAL_HARIAN'].substring(0, 10) +
                                                                          '\n' +
                                                                          [
                                                                            '06.00',
                                                                            '06.30',
                                                                            '07.00',
                                                                            '07.30',
                                                                            '08.00',
                                                                            '08.30',
                                                                            '09.00',
                                                                            '09.30',
                                                                            '10.00',
                                                                            '17.00',
                                                                            '17.30',
                                                                            '18.00',
                                                                            '18.30',
                                                                            '19.00',
                                                                            '19.30',
                                                                            '20.00',
                                                                            '20.30',
                                                                            '21.00',
                                                                          ][int.parse(scheduleItem['SESI_JADWAL'])] +
                                                                          '\n' +
                                                                          'Remaining slot: ' +
                                                                          scheduleItem['SISA_KUOTA']),
                                                                      trailing: int.parse(scheduleItem['SISA_KUOTA']) > 0 &&
                                                                              int.parse(scheduleItem['SUDAH_DIAMBIL']) == 0
                                                                          ? ElevatedButton(
                                                                              onPressed: (() {
                                                                                showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext bookContext) {
                                                                                      return AlertDialog(
                                                                                        title: const Text('Book'),
                                                                                        content: const Text('Are you sure you want to book this class?'),
                                                                                        actions: <Widget>[
                                                                                          TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator.of(bookContext).pop();
                                                                                            },
                                                                                            child: const Text('Cancel'),
                                                                                          ),
                                                                                          TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator.of(bookContext).pop();
                                                                                              http
                                                                                                  .post(Uri.parse('${baseURL}bookingkelas/create'),
                                                                                                      body: jsonEncode({
                                                                                                        'ID_USER': jsonDecode(jsonDecode(prefs.getString('user')!))['ID_USER'],
                                                                                                        'ID_MEMBER': jsonDecode(jsonDecode(prefs.getString('user')!))['ID_MEMBER'],
                                                                                                        'TOKEN': jsonDecode(jsonDecode(prefs.getString('user')!))['TOKEN'],
                                                                                                        'ID_JADWAL': scheduleItem['ID_JADWAL']
                                                                                                      }))
                                                                                                  .then((response) {
                                                                                                if (response.statusCode == 201) {
                                                                                                  const snackBar = SnackBar(content: Text('Booking Success!'), backgroundColor: Colors.green);
                                                                                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                                                  setStateDialog(() {});
                                                                                                } else {
                                                                                                  const snackBar = SnackBar(content: Text('Booking Failed!'), backgroundColor: Colors.red);
                                                                                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                                                }
                                                                                              });
                                                                                            },
                                                                                            child: const Text('Book'),
                                                                                          ),
                                                                                        ],
                                                                                      );
                                                                                    });
                                                                              }),
                                                                              child: const Text('Book'),
                                                                            )
                                                                          : ElevatedButton(
                                                                              onPressed: (() {
                                                                                showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext bookContext) {
                                                                                      return AlertDialog(
                                                                                        title: const Text('Book'),
                                                                                        content: const Text('Are you sure you want to cancel booking for this class?'),
                                                                                        actions: <Widget>[
                                                                                          TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator.of(bookContext).pop();
                                                                                            },
                                                                                            child: const Text('No'),
                                                                                          ),
                                                                                          TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator.of(bookContext).pop();
                                                                                              http
                                                                                                  .post(Uri.parse('${baseURL}bookingkelas/delete'),
                                                                                                      body: jsonEncode({
                                                                                                        'ID_USER': jsonDecode(jsonDecode(prefs.getString('user')!))['ID_USER'],
                                                                                                        'ID_BOOKING_KELAS': scheduleItem['ID_BOOKING_KELAS']
                                                                                                      }))
                                                                                                  .then((response) {
                                                                                                if (response.statusCode == 200) {
                                                                                                  const snackBar = SnackBar(content: Text('Cancel Booking Success!'), backgroundColor: Colors.green);
                                                                                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                                                  setStateDialog(() {});
                                                                                                } else {
                                                                                                  const snackBar = SnackBar(content: Text('Cancel Booking Failed!'), backgroundColor: Colors.red);
                                                                                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                                                }
                                                                                              });
                                                                                            },
                                                                                            child: const Text('Yes'),
                                                                                          ),
                                                                                        ],
                                                                                      );
                                                                                    });
                                                                              }),
                                                                              child: const Text('Cancel Book'),
                                                                            ),
                                                                    )),
                                                                  );
                                                                }
                                                              }
                                                            }
                                                            return ListView(
                                                                children:
                                                                    widgetList);
                                                          }
                                                        }
                                                      },
                                                    )),
                                              );
                                            }));
                              },
                              child: const Text('New Book')),
                        ));
                        return ListView(children: widgetList);
                      }
                    },
                  )
                : FutureBuilder(
                    future: fetchDataEmployee(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        var schedules = jsonDecode(snapshot.data!);
                        List<Widget> scheduleList = <Widget>[];
                        scheduleList.add(
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Today Schedule',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        );
                        for (var schedulePerSession in schedules) {
                          for (var schedule in schedulePerSession) {
                            scheduleList.add(Card(
                              child: ListTile(
                                title: Text(schedule['NAMA_KELAS']),
                                subtitle: Text(schedule['NAMA_USER'] +
                                    (schedule['NAMA_INSTRUKTUR_SEBELUMNYA'] ==
                                            null
                                        ? ''
                                        : ' (replacing ${schedule['NAMA_INSTRUKTUR_SEBELUMNYA']})') +
                                    '\n' +
                                    [
                                      '06.00',
                                      '06.30',
                                      '07.00',
                                      '07.30',
                                      '08.00',
                                      '08.30',
                                      '09.00',
                                      '09.30',
                                      '10.00',
                                      '17.00',
                                      '17.30',
                                      '18.00',
                                      '18.30',
                                      '19.00',
                                      '19.30',
                                      '20.00',
                                      '20.30',
                                      '21.00',
                                    ][int.parse(schedule['SESI_JADWAL'])]),
                                trailing: schedule[
                                            'TANGGAL_PRESENSI_INSTRUKTUR'] ==
                                        null
                                    ? ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext
                                                  startClassDialogContext) {
                                                return AlertDialog(
                                                  title: const Text("Confirm"),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                            'Are you sure you want to start this class? By starting this class, instructor will automatically mark as attended and instructor will be able to mark attendance for this class.'),
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Spacer(),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child:
                                                                ElevatedButton(
                                                              style: ButtonStyle(
                                                                  backgroundColor:
                                                                      MaterialStateProperty.all<
                                                                              Color>(
                                                                          primaryColor)),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    startClassDialogContext);
                                                              },
                                                              child: const Text(
                                                                  'CANCEL'),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child:
                                                                ElevatedButton(
                                                              style: ButtonStyle(
                                                                  backgroundColor:
                                                                      MaterialStateProperty.all<
                                                                              Color>(
                                                                          primaryColor)),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    startClassDialogContext);
                                                                http
                                                                    .post(
                                                                        Uri.parse(
                                                                            '${baseURL}presensiinstruktur/hadirkan'),
                                                                        body:
                                                                            jsonEncode({
                                                                          'ID_PRESENSI_INSTRUKTUR':
                                                                              schedule['ID_PRESENSI_INSTRUKTUR'],
                                                                          'ID_JADWAL':
                                                                              schedule['ID_JADWAL'],
                                                                          'PEG_ID_USER':
                                                                              jsonDecode(jsonDecode(prefs.getString('user')!))['ID_USER'],
                                                                          'ID_PEGAWAI':
                                                                              jsonDecode(jsonDecode(prefs.getString('user')!))['ID_PEGAWAI'],
                                                                          'TOKEN':
                                                                              jsonDecode(jsonDecode(prefs.getString('user')!))['TOKEN']
                                                                        }))
                                                                    .then(
                                                                        (value) {
                                                                  if (value
                                                                          .statusCode ==
                                                                      200) {
                                                                    const snackBar = SnackBar(
                                                                        content:
                                                                            Text(
                                                                                'Success start class'),
                                                                        backgroundColor:
                                                                            Colors.green);
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                            snackBar);
                                                                    setState(
                                                                        () {});
                                                                  } else {
                                                                    const snackBar = SnackBar(
                                                                        content:
                                                                            Text(
                                                                                'An error occurred while starting class!'),
                                                                        backgroundColor:
                                                                            Colors.red);
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                            snackBar);
                                                                  }
                                                                });
                                                              },
                                                              child: const Text(
                                                                  'YES'),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                );
                                              });
                                        },
                                        child: const Text('Start Class'),
                                      )
                                    : schedule['JAM_SELESAI_PRESENSI_INSTRUKTUR'] ==
                                            null
                                        ? ElevatedButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext
                                                      finishClassDialogContext) {
                                                    return AlertDialog(
                                                      title:
                                                          const Text("Confirm"),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Text(
                                                                'Are you sure you want to finish this class? By finishing this class, instructor will not be able to mark attendance for this class.'),
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Spacer(),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    ElevatedButton(
                                                                  style: ButtonStyle(
                                                                      backgroundColor:
                                                                          MaterialStateProperty.all<Color>(
                                                                              primaryColor)),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        finishClassDialogContext);
                                                                  },
                                                                  child: const Text(
                                                                      'CANCEL'),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    ElevatedButton(
                                                                  style: ButtonStyle(
                                                                      backgroundColor:
                                                                          MaterialStateProperty.all<Color>(
                                                                              primaryColor)),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        finishClassDialogContext);
                                                                    http
                                                                        .post(
                                                                            Uri.parse(
                                                                                '${baseURL}presensiinstruktur/selesaikan'),
                                                                            body:
                                                                                jsonEncode({
                                                                              'ID_PRESENSI_INSTRUKTUR': schedule['ID_PRESENSI_INSTRUKTUR'],
                                                                              'TOKEN': jsonDecode(jsonDecode(prefs.getString('user')!))['TOKEN']
                                                                            }))
                                                                        .then(
                                                                            (value) {
                                                                      if (value
                                                                              .statusCode ==
                                                                          200) {
                                                                        const snackBar = SnackBar(
                                                                            content:
                                                                                Text('Success finish class'),
                                                                            backgroundColor: Colors.green);
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(snackBar);
                                                                        setState(
                                                                            () {});
                                                                      } else {
                                                                        const snackBar = SnackBar(
                                                                            content:
                                                                                Text('An error occurred while finishing class!'),
                                                                            backgroundColor: Colors.red);
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(snackBar);
                                                                      }
                                                                    });
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                          'YES'),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: const Text('Finish Class'),
                                          )
                                        : Text(
                                            'Finished at ${schedule["JAM_SELESAI_PRESENSI_INSTRUKTUR"].substring(11, 16)}'),
                              ),
                            ));
                          }
                        }
                        return ListView(children: scheduleList);
                      }
                    },
                  );
  }
}

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  Future<String> fetchData() async {
    late http.Response response;
    if (jsonDecode(jsonDecode(prefs.getString('user')!))['ID_MEMBER'] != null) {
      response = await http.post(Uri.parse('${baseURL}member/tampilprofil'),
          body: jsonEncode({
            'ID_USER':
                jsonDecode(jsonDecode(prefs.getString('user')!))['ID_USER'],
            'TOKEN': jsonDecode(jsonDecode(prefs.getString('user')!))['TOKEN']
          }));
    } else if (jsonDecode(
            jsonDecode(prefs.getString('user')!))['ID_INSTRUKTUR'] !=
        null) {
      response = await http.post(Uri.parse('${baseURL}instruktur/tampilprofil'),
          body: jsonEncode({
            'ID_USER':
                jsonDecode(jsonDecode(prefs.getString('user')!))['ID_USER'],
            'BULAN': DateTime.now().month,
            'TAHUN': DateTime.now().year,
            'TOKEN': jsonDecode(jsonDecode(prefs.getString('user')!))['TOKEN']
          }));
    } else {
      response = http.Response('', 200);
    }
    // Simulating an asynchronous data fetching operation
    return response.body;
  }

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _retypePasswordController =
      TextEditingController();
  final _changePasswordFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return prefs.getString('user') == null
        ? const Login()
        : FutureBuilder<String>(
            future: fetchData(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                var profileData = {};
                if (jsonDecode(
                        jsonDecode(prefs.getString('user')!))['ID_PEGAWAI'] ==
                    null) profileData = jsonDecode(snapshot.data!);
                DateTime historyStartDate = DateTime.parse(
                    jsonDecode(jsonDecode(prefs.getString('user')!))[
                        'TANGGAL_LAHIR_USER']);
                DateTime historyEndDate = DateTime.now();
                int historyYear = DateTime.now().year;
                int historyMonth = DateTime.now().month;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: jsonDecode(jsonDecode(prefs
                                        .getString('user')!))['FOTO_USER'] !=
                                    null
                                ? MemoryImage(base64Decode(jsonDecode(
                                        jsonDecode(prefs.getString('user')!))[
                                    'FOTO_USER']))
                                : const AssetImage(
                                        'assets/images/account_circle_FILL0_wght400_GRAD0_opsz48.png')
                                    as ImageProvider,
                            radius: 100,
                          )
                        ],
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              jsonDecode(jsonDecode(prefs.getString('user')!))[
                                  'NAMA_USER'],
                              style: const TextStyle(fontSize: 24),
                            ),
                          ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 300,
                            child: Text(
                              'Email\t: ${jsonDecode(jsonDecode(prefs.getString('user')!))['EMAIL_USER']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 300,
                              child: Text(
                                'ID\t\t\t\t\t\t: ${jsonDecode(jsonDecode(prefs.getString('user')!))['ID_MEMBER'] ?? (jsonDecode(jsonDecode(prefs.getString('user')!))['ID_INSTRUKTUR'] ?? jsonDecode(jsonDecode(prefs.getString('user')!))['ID_PEGAWAI'])}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ]),
                      jsonDecode(jsonDecode(prefs.getString('user')!))[
                                  'ID_INSTRUKTUR'] !=
                              null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  SizedBox(
                                    width: 300,
                                    child: Text(
                                      'Total Late: ${profileData['JUMLAH_WAKTU_TERLAMBAT']}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ])
                          : const SizedBox(),
                      jsonDecode(jsonDecode(prefs.getString('user')!))[
                                  'ID_MEMBER'] !=
                              null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  SizedBox(
                                    width: 300,
                                    child: Text(
                                      'Active until: ${profileData['AKTIVASI']['TANGGAL_KADALUARSA_MEMBERSHIP'].substring(0, 10)}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ])
                          : const SizedBox(),
                      jsonDecode(jsonDecode(prefs.getString('user')!))[
                                  'ID_MEMBER'] !=
                              null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  SizedBox(
                                    width: 300,
                                    child: Text(
                                      'Balance: ${profileData['DEPOSIT_UANG']['SISA_DEPOSIT_UANG']}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ])
                          : const SizedBox(),
                      jsonDecode(jsonDecode(prefs.getString('user')!))[
                                  'ID_MEMBER'] !=
                              null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  SizedBox(
                                    width: 300,
                                    child: Text(
                                      'Class Deposits: ${profileData['DEPOSIT_KELAS'].map((e) => e['NAMA_KELAS'] + ' (' + e['JUMLAH_DEPOSIT_KELAS'] + ')').join(', ')}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ])
                          : const SizedBox(),
                      jsonDecode(jsonDecode(prefs.getString('user')!))[
                                  'ID_MEMBER'] !=
                              null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(primaryColor)),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (_) =>
                                                  StatefulBuilder(builder:
                                                      (BuildContext context,
                                                          StateSetter
                                                              setStateDialog) {
                                                    return Dialog(
                                                      insetPadding:
                                                          EdgeInsets.zero,
                                                      child: Scaffold(
                                                        appBar: AppBar(
                                                          title: const Text(
                                                              'Activity History'),
                                                        ),
                                                        body: Center(
                                                            child: ListView(
                                                          children:
                                                              //[
                                                              //       ListTile(
                                                              //         title: Text(
                                                              //             'Showing from ${historyStartDate.toIso8601String().substring(0, 10)} to ${historyEndDate.toIso8601String().substring(0, 10)}'),
                                                              //         trailing:
                                                              //             IconButton(
                                                              //                 onPressed:
                                                              //                     () async {
                                                              //                   final pickedDateRange = await showDateRangePicker(
                                                              //                       context: context,
                                                              //                       firstDate: DateTime.parse(jsonDecode(jsonDecode(prefs.getString('user')!))['TANGGAL_LAHIR_USER']),
                                                              //                       lastDate: DateTime.now());
                                                              //                   if (pickedDateRange !=
                                                              //                       null) {
                                                              //                     setStateDialog(() {
                                                              //                       historyStartDate = pickedDateRange.start;
                                                              //                       historyEndDate = pickedDateRange.end;
                                                              //                       historyStartDate.subtract(const Duration(minutes: 1));
                                                              //                       historyEndDate.add(const Duration(minutes: 1));
                                                              //                     });
                                                              //                   }
                                                              //                 },
                                                              //                 icon:
                                                              //                     Icon(Icons.calendar_today)),
                                                              //       )
                                                              //     ].cast<Widget>() +
                                                              profileData[
                                                                      'AKTIVITAS']
                                                                  // .where((activity) =>
                                                                  //     DateTime.parse(activity[
                                                                  //             'TANGGAL_AKTIVITAS'])
                                                                  //         .isAfter(
                                                                  //             historyStartDate) &&
                                                                  //     DateTime.parse(activity[
                                                                  //             'TANGGAL_AKTIVITAS'])
                                                                  //         .isBefore(
                                                                  //             historyEndDate))
                                                                  .map((activity) =>
                                                                      ListTile(
                                                                        title: Text(activity['JENIS_AKTIVITAS'] ==
                                                                                '0'
                                                                            ? 'Gym'
                                                                            : 'Class'),
                                                                        subtitle: activity['JENIS_AKTIVITAS'] ==
                                                                                '0'
                                                                            ? null
                                                                            : Text('Class: ${activity['NAMA_KELAS']}\nInstructor: ${activity['NAMA_USER']}'),
                                                                        trailing:
                                                                            Text(activity['TANGGAL_AKTIVITAS']),
                                                                      ))
                                                                  .cast<
                                                                      Widget>()
                                                                  .toList(),
                                                        )),
                                                      ),
                                                    );
                                                  }));
                                        },
                                        child: const SizedBox(
                                            width: 272,
                                            child: Center(
                                                child:
                                                    Text('ACTIVITY HISTORY'))),
                                      )),
                                ])
                          : const SizedBox(),
                      jsonDecode(jsonDecode(prefs.getString('user')!))[
                                  'ID_INSTRUKTUR'] !=
                              null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(primaryColor)),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (_) =>
                                                  StatefulBuilder(builder:
                                                      (BuildContext context,
                                                          StateSetter
                                                              setStateDialog) {
                                                    return Dialog(
                                                      insetPadding:
                                                          EdgeInsets.zero,
                                                      child: Scaffold(
                                                        appBar: AppBar(
                                                          title: const Text(
                                                              'Activity History'),
                                                        ),
                                                        body: Center(
                                                            child: ListView(
                                                          children: [
                                                                ListTile(
                                                                  title: Text(
                                                                      'Showing from $historyYear-$historyMonth-01'),
                                                                  trailing:
                                                                      IconButton(
                                                                          onPressed:
                                                                              () async {
                                                                            final pickedDateRange = await showMonthYearPicker(
                                                                                context: context,
                                                                                initialDate: historyStartDate,
                                                                                firstDate: DateTime.parse(jsonDecode(jsonDecode(prefs.getString('user')!))['TANGGAL_LAHIR_USER']),
                                                                                lastDate: DateTime.now());
                                                                            if (pickedDateRange !=
                                                                                null) {
                                                                              setStateDialog(() {
                                                                                historyYear = pickedDateRange.year;
                                                                                historyMonth = pickedDateRange.month;
                                                                              });
                                                                            }
                                                                          },
                                                                          icon:
                                                                              Icon(Icons.calendar_today)),
                                                                )
                                                              ].cast<Widget>() +
                                                              profileData[
                                                                      'AKTIVITAS']
                                                                  .where((activity) => DateTime.parse(
                                                                          activity[
                                                                              'TANGGAL_PRESENSI_INSTRUKTUR'])
                                                                      .isAfter(DateTime
                                                                          .parse(
                                                                              '$historyYear-${historyMonth.toString().padLeft(2, '0')}-01')))
                                                                  .map((activity) =>
                                                                      ListTile(
                                                                        title: const Text(
                                                                            'Teaching'),
                                                                        subtitle:
                                                                            Text('Class: ${activity['NAMA_KELAS']}\nMembers Count: ${activity['JUMLAH_MEMBER']}\n${activity['STATUS_PRESENSI_INSTRUKTUR'] == '2' ? 'On Time' : 'Late'}'),
                                                                        trailing:
                                                                            Text(activity['TANGGAL_PRESENSI_INSTRUKTUR']),
                                                                      ))
                                                                  .cast<
                                                                      Widget>()
                                                                  .toList(),
                                                        )),
                                                      ),
                                                    );
                                                  }));
                                        },
                                        child: const SizedBox(
                                            width: 272,
                                            child: Center(
                                                child:
                                                    Text('ACTIVITY HISTORY'))),
                                      )),
                                ])
                          : const SizedBox(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            primaryColor)),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext
                                          changePasswordDialogContext) {
                                        return AlertDialog(
                                            title:
                                                const Text("Change Password"),
                                            content: Form(
                                              key: _changePasswordFormKey,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 4.0),
                                                    child: TextFormField(
                                                      controller:
                                                          _currentPasswordController,
                                                      decoration:
                                                          const InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        labelText:
                                                            'Current Password',
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 4.0),
                                                    child: TextFormField(
                                                      controller:
                                                          _newPasswordController,
                                                      decoration:
                                                          const InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        labelText:
                                                            'New Password',
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 4.0),
                                                    child: TextFormField(
                                                        controller:
                                                            _retypePasswordController,
                                                        decoration: const InputDecoration(
                                                            border:
                                                                OutlineInputBorder(),
                                                            labelText:
                                                                'Retype Password'),
                                                        validator: (value) {
                                                          if (value !=
                                                              _newPasswordController
                                                                  .text) {
                                                            return 'Password does not match!';
                                                          }
                                                        }),
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Spacer(),
                                                      ElevatedButton(
                                                        style: ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all<Color>(
                                                                        primaryColor)),
                                                        onPressed: () {
                                                          if (_changePasswordFormKey
                                                              .currentState!
                                                              .validate()) {
                                                            Navigator.pop(
                                                                changePasswordDialogContext);
                                                            http
                                                                .post(
                                                                    Uri.parse(
                                                                        '${baseURL}autentikasi/changepassword'),
                                                                    body:
                                                                        jsonEncode({
                                                                      'ID_USER':
                                                                          jsonDecode(
                                                                              jsonDecode(prefs.getString('user')!))['ID_USER'],
                                                                      'TOKEN': jsonDecode(
                                                                              jsonDecode(prefs.getString('user')!))[
                                                                          'TOKEN'],
                                                                      'PASSWORD_USER':
                                                                          _newPasswordController
                                                                              .text,
                                                                      'PASSWORD_LAMA':
                                                                          _currentPasswordController
                                                                              .text
                                                                    }))
                                                                .then((value) {
                                                              if (value
                                                                      .statusCode ==
                                                                  200) {
                                                                const snackBar = SnackBar(
                                                                    content: Text(
                                                                        'Password change was successful!'),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .green);
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                        snackBar);
                                                              } else if (value
                                                                      .statusCode ==
                                                                  401) {
                                                                const snackBar = SnackBar(
                                                                    content: Text(
                                                                        'Current password is incorrect!'),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red);
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                        snackBar);
                                                              } else {
                                                                const snackBar = SnackBar(
                                                                    content: Text(
                                                                        'An error occurred while changing password!'),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red);
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                        snackBar);
                                                              }
                                                            });
                                                          }
                                                        },
                                                        child: const Icon(
                                                            Icons.check),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ));
                                      });
                                },
                                child: const SizedBox(
                                    width: 272,
                                    child:
                                        Center(child: Text('CHANGE PASSWORD'))),
                              ))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          primaryColor)),
                              onPressed: () {
                                prefs.remove('user');
                                setState(() {});
                              },
                              child: const SizedBox(
                                  width: 272,
                                  child: Center(child: Text('LOGOUT'))),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                );
              }
            });
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  static final _emailController = TextEditingController();
  static final _passwordController = TextEditingController();
  String email = '', password = '';
  @override
  Widget build(BuildContext context) {
    return prefs.getString('user') != null
        ? const Account()
        : Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_picture_small.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 300,
                height: 400,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Image.asset('assets/images/undraw_login_re_4vu2.png'),
                        const Text(
                          'Please login to your account...',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Email',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Password',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Spacer(),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          primaryColor),
                                ),
                                onPressed: () {
                                  http
                                      .post(
                                          Uri.parse(
                                              '${baseURL}autentikasi/login'),
                                          body: jsonEncode({
                                            'EMAIL': _emailController.text,
                                            'PASSWORD': _passwordController.text
                                          }))
                                      .then((value) {
                                    if (value.statusCode == 200) {
                                      prefs.setString(
                                          'user', jsonEncode(value.body));
                                      setState(() {});
                                    } else {
                                      const snackBar = SnackBar(
                                          content: Text(
                                              'Email or password is incorrect!'),
                                          backgroundColor: Colors.red);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    }
                                  });
                                },
                                child: const Text('LOGIN'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}

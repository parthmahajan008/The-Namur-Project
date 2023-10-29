import 'package:active_ecommerce_flutter/features/profile/hive_models/models.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import '../../../custom/device_info.dart';

import 'package:time_range_picker/time_range_picker.dart';

// import '../seller_platform/seller_platform.dart';

class MachineRentForm extends StatefulWidget {
  final String imageURL;
  final String machineName;
  final double machinePrice;
  const MachineRentForm({
    Key? key,
    required this.imageURL,
    required this.machineName,
    required this.machinePrice,
  }) : super(key: key);

  @override
  State<MachineRentForm> createState() => _MachineRentFormState();
}

class _MachineRentFormState extends State<MachineRentForm> {
  DateTime dateNow = DateTime.now();
  DateTime? dateOfRenting;

  TimeRange? timeRangeOfRenting;

  String? landDropdownValue;
  late Future<List<Land>> landList;

  @override
  void initState() {
    super.initState();
    landList = getLandList();
  }

  Future<List<Land>> getLandList() async {
    var dataBox = Hive.box<ProfileData>('profileDataBox3');

    var savedData = dataBox.get('profile');

    if (savedData == null) {
      throw Exception('Failed to load data');
    }

    return savedData.land;
  }

  @override
  Widget build(BuildContext context) {
    TimeOfDay? rentStartTime = timeRangeOfRenting?.startTime;
    TimeOfDay? rentEndTime = timeRangeOfRenting?.endTime;
    return Container(
      color: Colors.white,
      height: DeviceInfo(context).height,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          // elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xff107B28), Color(0xff4C7B10)]),
            ),
          ),
          title: Text(
            AppLocalizations.of(context)!.rent_a_machine,
            style: TextStyle(
                color: MyTheme.white,
                fontWeight: FontWeight.w500,
                letterSpacing: .5,
                fontFamily: 'Poppins'),
          ),
          centerTitle: true,
        ),
        bottomSheet: Container(
          height: 60,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              // widget.isProductEditScreen
              //     ? await onPressedEdit(context)
              //     : await onPressedPost(context);
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(MyTheme.primary_color),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0))),
            ),
            child: Text(
              AppLocalizations.of(context)!.book,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
          physics: BouncingScrollPhysics(),
          children: [
            SizedBox(
              height: 10,
            ),

            TitleWidget(text: 'Machine'),

            SizedBox(
              height: 10,
            ),

            // Machine Image
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      height: 200,
                      child: widget.imageURL.isEmpty
                          ? Center(
                              child: Text(
                                  AppLocalizations.of(context)!.no_image_found))
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              child: Image.network(
                                widget.imageURL,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    SizedBox(
                      height: 10,
                    ),

                    // Machine Price
                    Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, bottom: 12, top: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.machineName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Text(
                            '\₹${widget.machinePrice}/30 mins',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              height: 15,
            ),
            TitleWidget(text: 'Planning Date'),

            SizedBox(
              height: 5,
            ),

            // Planning Date
            Container(
              // height: 50,
              // color: Colors.amber,
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.all(8),
                      child: ElevatedButton(
                        onPressed: () async {
                          DateTime? newData = await showDatePicker(
                              context: context,
                              initialDate: dateNow,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2025));

                          if (newData != null) {
                            setState(() {
                              dateOfRenting = newData;
                            });
                          }
                        },
                        child: Text(
                          dateOfRenting != null
                              ? '${dateOfRenting!.day}/${dateOfRenting!.month}/${dateOfRenting!.year}'
                              : 'Date',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(0),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                        color: Colors.transparent, width: 0))),
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 255, 172, 200))),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.all(8),
                      child: ElevatedButton(
                        onPressed: () async {
                          TimeRange result = await showTimeRangePicker(
                            context: context,
                            start: const TimeOfDay(hour: 22, minute: 9),
                            interval: const Duration(minutes: 30),
                            minDuration: const Duration(minutes: 30),
                            use24HourFormat: false,
                            padding: 30,
                            strokeWidth: 12,
                            handlerRadius: 9,
                            strokeColor: MyTheme.primary_color,
                            handlerColor: MyTheme.green_light,
                            selectedColor: MyTheme.primary_color,
                            backgroundColor: Colors.black.withOpacity(0.3),
                            ticks: 12,
                            ticksColor: Colors.white,
                            snap: true,
                            labels: [
                              "12 am",
                              "3 am",
                              "6 am",
                              "9 am",
                              "12 pm",
                              "3 pm",
                              "6 pm",
                              "9 pm"
                            ].asMap().entries.map((e) {
                              return ClockLabel.fromIndex(
                                  idx: e.key, length: 8, text: e.value);
                            }).toList(),
                            labelOffset: -30,
                            labelStyle: const TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                            timeTextStyle: TextStyle(
                                color: MyTheme.primary_color,
                                fontSize: 24,
                                fontWeight: FontWeight.w900),
                            activeTimeTextStyle: TextStyle(
                                color: MyTheme.primary_color,
                                fontSize: 26,
                                fontWeight: FontWeight.bold),
                          );

                          print("result " + result.toString());

                          setState(() {
                            timeRangeOfRenting = result;
                          });
                        },
                        child: Text(
                          timeRangeOfRenting != null
                              ? '${rentStartTime!.hourOfPeriod}:${rentStartTime.minute == 0 ? '00' : rentStartTime.minute} ${rentStartTime.period.name} - ${rentEndTime!.hourOfPeriod}:${rentEndTime.minute == 0 ? '00' : rentEndTime.minute} ${rentEndTime.period.name}'
                              : 'Time',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(0),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                        color: Colors.transparent, width: 0))),
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 255, 243, 131))),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 15,
            ),

            TitleWidget(text: 'Land'),

            SizedBox(
              height: 20,
            ),

            // Select Land
            FutureBuilder(
                future: landList,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: DropdownButtonWidget(
                        hintText: 'Select Land',
                        itemList: List.generate(
                            snapshot.data!.length,
                            (index) => DropdownMenuItem<String>(
                                  value: snapshot.data![index].syno,
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                              snapshot.data![index].village)),
                                      Expanded(
                                          child:
                                              Text(snapshot.data![index].syno)),
                                    ],
                                  ),
                                )).toList(),
                        dropdownValue: landDropdownValue,
                        onChanged: (value) {
                          setState(() {
                            landDropdownValue = value;
                          });
                        },
                      ),
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }),
          ],
        ),
      ),
    );
  }

  Column DropdownButtonWidget(
      {required String hintText,
      required List<DropdownMenuItem<String>>? itemList,
      required String? dropdownValue,
      required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey, // You can customize the border color here
            ),
          ),
          child: DropdownButton<String>(
            hint: Text(
              hintText,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            isExpanded: true,
            value: dropdownValue,
            icon: Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            underline: SizedBox(), // Remove the underline
            style: TextStyle(
              fontSize: 16,
              color: Colors.black, // You can customize the text color here
            ),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              onChanged(value!);
            },
            // items: itemList.map<DropdownMenuItem<String>>((String value) {
            //   return DropdownMenuItem<String>(
            //     value: value,
            //     child: Text(value),
            //   );
            // }).toList(),
            items: itemList,
          ),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MyTheme.green_lighter,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// translation done.

import 'dart:async';
import 'dart:typed_data';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/features/profile/enum.dart';
import 'package:active_ecommerce_flutter/features/profile/models/updates_data.dart';
import 'package:active_ecommerce_flutter/utils/hive_models/models.dart';
import 'package:active_ecommerce_flutter/features/profile/models/userdata.dart';
import 'package:active_ecommerce_flutter/features/profile/screens/more_details.dart';
import 'package:active_ecommerce_flutter/features/profile/services/profile_bloc/profile_bloc.dart';
import 'package:active_ecommerce_flutter/features/profile/services/profile_bloc/profile_event.dart';
import 'package:active_ecommerce_flutter/features/profile/services/profile_bloc/profile_state.dart';
import 'package:active_ecommerce_flutter/features/profile/utils.dart';
import 'package:active_ecommerce_flutter/presenter/home_presenter.dart';
import 'package:active_ecommerce_flutter/utils/imageLinks.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  HomePresenter homeData = HomePresenter();
  ScrollController _mainScrollController = ScrollController();
  late BuildContext loadingcontext;

  ProfileSection _profileSection = ProfileSection.updates;
  late Future<List<UpdatesData>> updatesDataFuture;
  late Future<List<Crop>> cropsDataFuture;

  var imageLinks = imageForNameCloud;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BlocProvider.of<ProfileBloc>(context).add(
      ProfileDataRequested(),
    );
    updatesDataFuture = getUpdatesDate();
    cropsDataFuture = getCropsDate();
  }

  Future<List<UpdatesData>> getUpdatesDate() async {
    List<UpdatesData> updatesData = [];

    var userSnapshot =
        await FirebaseFirestore.instance.collection('updates').get();

    for (var document in userSnapshot.docs) {
      // userSnapshot.docs[0].data()!['imageURL']
      updatesData.add(UpdatesData(
        imageURL: document.data()['imageURL'],
        goToURL: document.data()['link'],
      ));
    }

    return updatesData;
  }

  Future<List<Crop>> getCropsDate() async {
    List<Crop> cropsData = [];

    var dataBox = Hive.box<ProfileData>('profileDataBox3');
    var savedData = dataBox.get('profile');

    if (savedData == null) {
      return [];
    }

    for (Land land in savedData.land) {
      for (Crop crop in land.crops) {
        cropsData.add(crop);
      }
    }

    return cropsData;
  }

  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  Uint8List? _image;

  selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    print('image uploaded');
    _image = img;
  }

  saveProfileImage() async {
    await selectImage();
    BlocProvider.of<ProfileBloc>(context).add(
      ProfileImageUpdateRequested(file: _image!),
    );
  }

  Future<List<Object?>> getNumberOfFriends() async {
    var dataBox = Hive.box<ProfileData>('profileDataBox3');

    var savedData = dataBox.get('profile');

    if (savedData!.address[0].pincode.isEmpty) {
      throw Exception('Failed to load data');
    }

    int count = 0;
    String villageName = savedData.address[0].village;
    String pincode = savedData.address[0].pincode;

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('buyer')
        .where(FieldPath.documentId, isNotEqualTo: null)
        .where('profileData', isNotEqualTo: null)
        .get();

    List<DocumentSnapshot<Map<String, dynamic>>> documents = querySnapshot.docs;

    for (var document in documents) {
      Map<String, dynamic> data = document.data()!;
      if (data['profileData']['address'].isNotEmpty) {
        Map<String, dynamic> data = document.data()!;
        if (data['profileData']['address'][0]['pincode'] ==
            savedData.address[0].pincode) {
          count++;
          print('count incremented');
        }
      }
    }

    return [villageName, pincode, count - 1];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Directionality(
        textDirection:
            app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
        child: buildView(context, _profileSection),
      ),
    );
  }

  Widget buildView(context, _profileSection) {
    return Container(
      color: Colors.white,
      height: DeviceInfo(context).height,
      child: Stack(
        children: [
          Scaffold(
            // appBar: buildCustomAppBar(context),
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  size: 35,
                  color: MyTheme.white,
                ),
              ),
              automaticallyImplyLeading: false,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xff107B28), Color(0xff4C7B10)]),
                ),
              ),
              title: Text(AppLocalizations.of(context)!.profile_ucf,
                  style: TextStyle(
                      color: MyTheme.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: .5,
                      fontFamily: 'Poppins')),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return MoreDetails();
                    }));
                  },
                  icon: Icon(
                    Icons.settings,
                    // size: 35,
                    color: MyTheme.white,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
            key: homeData.scaffoldKey,
            // drawer: const MainDrawer(),

            backgroundColor: Colors.transparent,
            body: RefreshIndicator(
              child: buildBodyChildren(_profileSection),
              onRefresh: () async {
                BlocProvider.of<ProfileBloc>(context).add(
                  ProfileDataRequested(),
                );
                updatesDataFuture = getUpdatesDate();
                cropsDataFuture = getCropsDate();
              },
            ),
          ),
        ],
      ),
    );
  }

  CustomScrollView buildBodyChildren(profileSection) {
    _launchYouTubeVideo(url) async {
      print('clicked');
      final Uri _url = Uri.parse(url);
      if (await canLaunchUrl(_url)) {
        await launchUrl(_url);
      } else {
        throw 'Could not launch';
      }
    }

    return CustomScrollView(
      controller: _mainScrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is Error) {
              ToastComponent.showDialog(state.error,
                  gravity: Toast.center, duration: Toast.lengthLong);
              Navigator.pop(context);
              return;
            }
            if (state is ProfileDataNotReceived) {
              ToastComponent.showDialog(
                  'Could Not Retrieve Profile Data. Please Try Again.',
                  gravity: Toast.center,
                  duration: Toast.lengthLong);
              Navigator.pop(context);
              return;
            }
            if (state is ProfileDataReceived) {
              print('STATE: ProfileDataReceived');
            }
            if (state is ProfileImageUpdated) {
              print('STATE: ProfileImageUpdated');

              ToastComponent.showDialog('Profile Image Updated',
                  gravity: Toast.center, duration: Toast.lengthLong);

              BlocProvider.of<ProfileBloc>(context).add(
                ProfileDataRequested(),
              );
              return;
            }
          },
          child:
              BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
            if (state is ProfileDataReceived) {
              BuyerData buyerUserData = state.buyerProfileData;
              TabController tabController =
                  TabController(length: 2, vsync: this);
              return SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2,
                    child: (buyerUserData.photoURL == null ||
                            buyerUserData.photoURL == '')
                        ? Image.asset(
                            "assets/default_profile2.png",
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: buyerUserData.photoURL!,
                            fit: BoxFit.cover,
                          ),
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  //Profile Name
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 25),
                    child: Text(
                      buyerUserData.name,
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins"),
                    ),
                  ),

                  // CircleAvatar, Region, Friends and Neighbors texts
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, left: 20, right: 20),
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 50,
                            width: 130,
                            child: Stack(
                              children: [
                                for (var i = 0; i < [1, 2, 3, 4].length; i++)
                                  Positioned(
                                    left: (i * (1 - .4) * 40).toDouble(),
                                    top: 0,
                                    child: CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.transparent,
                                      // Set the background color to transparent
                                      backgroundImage: AssetImage(
                                          'assets/Ellipse2.png'), // Provide the asset image path
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: FutureBuilder(
                                future: getNumberOfFriends(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Column(
                                      children: [
                                        //Region text
                                        Text('${snapshot.data![0]}',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15,
                                                color: Colors.black)),
                                        Text('${snapshot.data![1]}',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15,
                                                color: Colors.black)),

                                        //Friends and Neighbors text
                                        Text(
                                          '${snapshot.data![2]} ${AppLocalizations.of(context)!.friends_and_neighbours}',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15,
                                              color: Colors.black),
                                        ),
                                      ],
                                    );
                                  }
                                  if (snapshot.hasError) {
                                    return Text(
                                      AppLocalizations.of(context)!
                                          .add_address_to_see_this,
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                          color: Colors.red),
                                    );
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }),
                          )
                        ],
                      ),
                    ),
                  ),

                  // tabs
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: MyTheme.field_color,
                          ),
                        ),
                        child: TabBar(
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              color: Color(0xff4C7B10),
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black,
                            controller: tabController,
                            labelPadding: EdgeInsets.symmetric(horizontal: 25),
                            tabs: [
                              Tab(
                                child: Text(
                                  AppLocalizations.of(context)!.updates,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins'),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  AppLocalizations.of(context)!.my_stock,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins'),
                                ),
                              ),
                            ]),
                      ),
                    ),
                  ),

                  Container(
                    height: MediaQuery.of(context).size.height - 300,
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        FutureBuilder(
                            future: updatesDataFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasData &&
                                  snapshot.connectionState ==
                                      ConnectionState.done) {
                                List<UpdatesData> updatesList = snapshot.data!;
                                return updatesList.length == 0
                                    ? Center(
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .no_data_is_available,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Poppins'),
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: updatesList.length,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        await _launchYouTubeVideo(
                                                            updatesList[index]
                                                                .goToURL);
                                                      },
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            updatesList[index]
                                                                .imageURL,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                              }
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }),
                        FutureBuilder(
                            future: cropsDataFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasData && snapshot.data != null) {
                                return snapshot.data!.length == 0
                                    ? Center(
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .no_data_is_available,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Poppins'),
                                        ),
                                      )
                                    : SingleChildScrollView(
                                        child: MasonryGridView.count(
                                          crossAxisCount: 3,
                                          mainAxisSpacing: 16,
                                          crossAxisSpacing: 16,
                                          itemCount: snapshot.data!.length,
                                          shrinkWrap: true,
                                          padding: EdgeInsets.only(
                                              top: 10.0, left: 18, right: 18),
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.vertical,
                                          itemBuilder: (context, index) {
                                            //
                                            return Container(
                                              //  height: 100,
                                              decoration: BoxDecoration(
                                                color: MyTheme.green_lighter
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0),
                                                    child: Container(
                                                      height: 50,
                                                      width: 50,
                                                      // child: Image.asset(
                                                      //   stocks[index],
                                                      //   fit: BoxFit.cover,
                                                      // ),
                                                      child: CachedNetworkImage(
                                                          imageUrl: imageLinks[
                                                                  snapshot
                                                                      .data![
                                                                          index]
                                                                      .name
                                                                      .toLowerCase()] ??
                                                              imageLinks[
                                                                  'placeholder']!),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0,
                                                            bottom: 8.0,
                                                            left: 5,
                                                            right: 5),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        snapshot
                                                            .data![index].name,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
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
                ]),
              );
            }
            return SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  height: DeviceInfo(context).height,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              ]),
            );
          }),
        ),
      ],
    );
  }
}

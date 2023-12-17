// translation done.

import 'dart:typed_data';

import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/features/auth/models/postoffice_response_model.dart';
import 'package:active_ecommerce_flutter/features/auth/services/auth_bloc/auth_bloc.dart';
import 'package:active_ecommerce_flutter/features/auth/services/auth_bloc/auth_event.dart';
import 'package:active_ecommerce_flutter/features/auth/services/auth_bloc/auth_state.dart'
    as authState;
import 'package:active_ecommerce_flutter/features/profile/enum.dart';
import 'package:active_ecommerce_flutter/features/profile/services/hive_bloc/hive_bloc.dart';
import 'package:active_ecommerce_flutter/features/profile/services/hive_bloc/hive_event.dart';
import 'package:active_ecommerce_flutter/features/profile/services/hive_bloc/hive_state.dart';
import 'package:active_ecommerce_flutter/features/profile/services/profile_bloc/profile_bloc.dart';
import 'package:active_ecommerce_flutter/features/profile/services/profile_bloc/profile_event.dart';
import 'package:active_ecommerce_flutter/features/profile/services/profile_bloc/profile_state.dart'
    as profileState;
import 'package:active_ecommerce_flutter/features/profile/utils.dart';
import 'package:active_ecommerce_flutter/features/sellAndBuy/services/sell_bloc/sell_bloc.dart';
import 'package:active_ecommerce_flutter/features/sellAndBuy/services/sell_bloc/sell_event.dart';
import 'package:active_ecommerce_flutter/utils/hive_models/models.dart';
import 'package:active_ecommerce_flutter/features/profile/screens/more_details.dart';
import 'package:active_ecommerce_flutter/utils/location_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:active_ecommerce_flutter/features/profile/address_list.dart'
    as addressList;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _hobliController = TextEditingController();
  TextEditingController _villageController = TextEditingController();

  TextEditingController _village2Controller = TextEditingController();
  TextEditingController _synoController = TextEditingController();
  TextEditingController _areaController = TextEditingController();

  TextEditingController _aadharController = TextEditingController();
  TextEditingController _panController = TextEditingController();
  TextEditingController _gstController = TextEditingController();

  TextEditingController _yieldController = TextEditingController();
  TextEditingController _pinCodeController = TextEditingController();
  TextEditingController _pinCodeControllerForLand = TextEditingController();

  TextEditingController _nameControllerForAccount = TextEditingController();

  TextEditingController _animalNameController = TextEditingController();
  TextEditingController _animalQuantityController = TextEditingController();

  final districts = addressList.districtTalukMap;

  final cropsList = addressList.crops;
  final equipmentsList = addressList.equipment;

  LocationRepository locationRepository = LocationRepository();

  List<String> taluks = [];

  String? districtDropdownValue;
  String? talukDropdownValue;

  String? landDropdownValue;

  String? cropDropdownValue;
  String? equipmentDropdownValue;

  String? locationDropdownValue;
  String? locationDropdownValueForLand;

  bool talukDropdownEnabled = false;
  bool isDropdownEnabled = false;
  bool isDropdownForLandEnabled = false;

  PostOfficeResponse? postOfficeResponse;

  // String? pincode;
  String? addressName;
  String? districtName;
  String? addressCircle;
  String? addressRegion;

  PostOfficeResponse? postOfficeResponseForLand;

  // String? pincode;
  String? addressNameForLand;
  String? districtNameForLand;
  String? addressCircleForLand;
  String? addressRegionForLand;

  List<String> locationsList = [];
  List<String> locationsListForLand = [];

  List<String> districtsList = [];
  List<String> taluksList = [];
  List<String> gramPanchayatsList = [];
  List<String> villageNamesList = [];

  bool isDistrictEnabled = false;
  bool isTalukEnabled = false;
  bool isGramPanchayadEnabled = false;
  bool isVillageNameEnabled = false;

  String? districtsDropdownValue;
  String? taluksDropdownValue;
  String? gramPanchayatsDropdownValue;
  String? villageNamesDropdownValue;

  late bool profileDataUpdating;

  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  late var localContext;

  get console => null;

  getAddressValues() {
    postOfficeResponse!.postOffices.forEach((postOffice) {
      if (postOffice.name == locationDropdownValue) {
        addressName = postOffice.name;
        districtName = postOffice.district;
        addressCircle = postOffice.circle;
        addressRegion = postOffice.region;
      }
    });
  }

  clearAddressValues() {
    addressName = null;
    districtName = null;
    addressCircle = null;
    addressRegion = null;
  }

  getAddressValuesForLand() {
    postOfficeResponseForLand!.postOffices.forEach((postOffice) {
      if (postOffice.name == locationDropdownValueForLand) {
        addressNameForLand = postOffice.name;
        districtNameForLand = postOffice.district;
        addressCircleForLand = postOffice.circle;
        addressRegionForLand = postOffice.region;
      }
    });
  }

  clearAddressValuesForLand() {
    addressNameForLand = null;
    districtNameForLand = null;
    addressCircleForLand = null;
    addressRegionForLand = null;
  }

  void fetchLocations(BuildContext buildContext) {
    if (_pinCodeController.text.toString().isEmpty ||
        _pinCodeController.text.toString().length != 6) {
      ToastComponent.showDialog(localContext.enter_valid_pincode,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }
    BlocProvider.of<AuthBloc>(buildContext).add(
      LocationsForPincodeRequested(_pinCodeController.text.toString()),
    );
  }

  void fetchDistricts() async {
    if (_pinCodeController.text.toString().isEmpty ||
        _pinCodeController.text.toString().length != 6) {
      ToastComponent.showDialog(localContext.enter_valid_pincode,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    List<String> temp = await locationRepository.getDistrictsForPincode(
        pinCode: _pinCodeController.text);
    setState(() {
      districtsList = temp;
      isDistrictEnabled = true;
    });
  }

  void fetchTaluks({
    required String districtName,
  }) {
    List<String> temp =
        locationRepository.getTaluksForDistrict(districtName: districtName);
    setState(() {
      taluksList = temp;
      isTalukEnabled = true;
    });
  }

  void fetchGramPanchayats({
    required String talukName,
  }) {
    List<String> temp =
        locationRepository.getGramPanchayatsForTaluk(taluk: talukName);
    setState(() {
      gramPanchayatsList = temp;
      isGramPanchayadEnabled = true;
    });
  }

  void fetchVillageNames({
    required String gramPanchayatName,
  }) {
    List<String> temp = locationRepository.getVillagesForGramPanchayat(
        gramPanchayat: gramPanchayatName);
    setState(() {
      villageNamesList = temp;
      isVillageNameEnabled = true;
    });
  }

  void fetchLocationsForLand(BuildContext buildContext) {
    if (_pinCodeControllerForLand.text.toString().isEmpty ||
        _pinCodeControllerForLand.text.toString().length != 6) {
      ToastComponent.showDialog(localContext.enter_valid_pincode,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }
    BlocProvider.of<AuthBloc>(buildContext).add(
      LandLocationsForPincodeRequested(
          _pinCodeControllerForLand.text.toString()),
    );
  }

  void _addAddressToHive({
    required String? pincode,
    required String? gramPanchayat,
    required String? district,
    required String? villageName,
    required String? taluk,
  }) async {
    var dataBox = Hive.box<ProfileData>('profileDataBox3');

    var savedData = dataBox.get('profile');

    if (savedData!.address.length != 0) {
      ToastComponent.showDialog(localContext.already_added_address,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }
    if (pincode == null || pincode.isEmpty) {
      ToastComponent.showDialog(localContext.enter_pincode,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }
    if (district == null || district.isEmpty) {
      ToastComponent.showDialog(localContext.select_district,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }
    if (taluk == null || taluk.isEmpty) {
      ToastComponent.showDialog(localContext.select_taluk,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }
    if (gramPanchayat == null || gramPanchayat.isEmpty) {
      ToastComponent.showDialog(localContext.select_gram_panchayat,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }
    if (villageName == null || villageName.isEmpty) {
      ToastComponent.showDialog(localContext.select_village,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    var address = Address()
      ..district = district
      ..taluk = taluk
      ..gramPanchayat = gramPanchayat
      ..village = villageName
      ..pincode = pincode;

    // if (savedData != null) {
    // print('object detected');
    print(savedData.id);
    var newData = ProfileData()
      ..id = savedData.id
      ..updated = savedData.updated
      ..address = [...savedData.address, address]
      ..kyc = savedData.kyc
      ..land = savedData.land;

    await dataBox.put(newData.id, newData);
    // print('object updated');

    BlocProvider.of<HiveBloc>(context).add(
      SyncHiveToFirestoreRequested(profileData: newData),
    );

    BlocProvider.of<SellBloc>(context).add(
      UpdateAddressInProductsAndSellerDocumentRequested(
        district: district,
        taluk: taluk,
        gramPanchayat: gramPanchayat,
        villageName: villageName,
      ),
    );

    _hobliController.clear();
    _villageController.clear();

    BlocProvider.of<HiveBloc>(context).add(
      HiveDataRequested(),
    );
  }

  void _addLandToHive(area, syno, village) async {
    if (village == null) {
      ToastComponent.showDialog(localContext.select_village,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    if (syno.isEmpty) {
      ToastComponent.showDialog('${localContext.enter} Sy No',
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    if (area.isEmpty) {
      ToastComponent.showDialog(localContext.enter_area_name,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    double areaDouble = 0.0;
    try {
      areaDouble = double.parse(area);
    } catch (e) {
      ToastComponent.showDialog(localContext.enter_valid_area_name,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    var dataBox = Hive.box<ProfileData>('profileDataBox3');

    var savedData = dataBox.get('profile');

    var land = Land()
      ..area = areaDouble
      ..syno = syno
      ..village = village
      ..crops = []
      ..animals = []
      ..equipments = [];

    if (savedData != null) {
      // print('object detected');
      print(savedData.id);
      var newData = ProfileData()
        ..id = savedData.id
        ..updated = savedData.updated
        ..address = savedData.address
        ..kyc = savedData.kyc
        ..land = [...savedData.land, land];

      await dataBox.put(newData.id, newData);
      // print('object updated');

      BlocProvider.of<HiveBloc>(context).add(
        SyncHiveToFirestoreRequested(profileData: newData),
      );
    }

    _areaController.clear();
    _synoController.clear();
    _village2Controller.clear();

    BlocProvider.of<HiveBloc>(context).add(
      HiveDataRequested(),
      // HiveAppendAddress(context: context),
    );
  }

  void initState() {
    districtsList = locationRepository.getAllDistricts();
    profileDataUpdating = false;
    super.initState();
    var dataBox = Hive.box<ProfileData>('profileDataBox3');

    var savedData = dataBox.get('profile');

    if (savedData == null) {
      var kyc = KYC()
        ..aadhar = ''
        ..pan = ''
        ..gst = '';
      var emptyProfileData = ProfileData()
        ..id = 'profile'
        ..updated = true
        ..address = []
        ..kyc = kyc
        ..land = [];
      dataBox.put(emptyProfileData.id, emptyProfileData);
    }
    BlocProvider.of<HiveBloc>(context).add(
      HiveDataRequested(),
      // HiveAppendAddress(context: context),
    );
    BlocProvider.of<ProfileBloc>(context).add(
      ProfileDataRequested(),
      // HiveAppendAddress(context: context),
    );
  }

  void dispose() {
    super.dispose();
  }

  void _saveKycToHive(aadhar, pan, gst) async {
    if (aadhar.length != 12) {
      ToastComponent.showDialog(localContext.enter_valid_aadhar_number,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    var dataBox = Hive.box<ProfileData>('profileDataBox3');

    var savedData = dataBox.get('profile');

    if (savedData != null) {
      var kyc = KYC()
        ..aadhar = aadhar
        ..pan = pan
        ..gst = gst;

      var newData = ProfileData()
        ..id = savedData.id
        ..updated = savedData.updated
        ..address = savedData.address
        ..kyc = kyc
        ..land = savedData.land;

      await dataBox.put(newData.id, newData);

      BlocProvider.of<HiveBloc>(context).add(
        SyncHiveToFirestoreRequested(profileData: newData),
      );
    }

    BlocProvider.of<HiveBloc>(context).add(
      HiveDataRequested(),
    );
  }

  void _deleteKycFromHive() async {
    var dataBox = Hive.box<ProfileData>('profileDataBox3');

    var savedData = dataBox.get('profile');

    if (savedData != null) {
      var kyc = KYC()
        ..aadhar = ''
        ..pan = ''
        ..gst = '';

      var newData = ProfileData()
        ..id = savedData.id
        ..updated = savedData.updated
        ..address = savedData.address
        ..kyc = kyc
        ..land = savedData.land;

      await dataBox.put(newData.id, newData);

      BlocProvider.of<HiveBloc>(context).add(
        SyncHiveToFirestoreRequested(profileData: newData),
      );
    }

    BlocProvider.of<HiveBloc>(context).add(
      HiveDataRequested(),
    );
  }

  void _deleteDataFromHive(DataCollectionType dataCollectionType, index) async {
    var dataBox = Hive.box<ProfileData>('profileDataBox3');

    var savedData = dataBox.get('profile');

    if (dataCollectionType == DataCollectionType.address) {
      savedData!.address.removeAt(index);
      BlocProvider.of<SellBloc>(context).add(
        UpdateAddressInProductsAndSellerDocumentRequested(
          district: "",
          taluk: "",
          gramPanchayat: "",
          villageName: "",
        ),
      );
    } else if (dataCollectionType == DataCollectionType.land) {
      landDropdownValue = null;
      savedData!.land.removeAt(index);
    }

    var newData = ProfileData()
      ..id = savedData!.id
      ..updated = savedData.updated
      ..address = savedData.address
      ..kyc = savedData.kyc
      ..land = savedData.land;

    await dataBox.put(newData.id, newData);

    BlocProvider.of<HiveBloc>(context).add(
      SyncHiveToFirestoreRequested(profileData: savedData),
    );

    BlocProvider.of<HiveBloc>(context).add(
      HiveDataRequested(),
      // HiveAppendAddress(context: context),
    );
  }

  void _addCropToHive(landSyno, crop, yieldOfCrop) async {
    if (landSyno.isEmpty) {
      ToastComponent.showDialog(localContext.select_land,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    if (crop.isEmpty) {
      ToastComponent.showDialog(localContext.select_crop,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    if (yieldOfCrop.isEmpty) {
      ToastComponent.showDialog(localContext.enter_yield,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    double yieldOfCropDouble = 0.0;
    try {
      yieldOfCropDouble = double.parse(yieldOfCrop);
    } catch (e) {
      ToastComponent.showDialog(localContext.enter_valid_yield,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    var dataBox = Hive.box<ProfileData>('profileDataBox3');

    var savedData = dataBox.get('profile');

    // Find the Land instance with the specified syno
    int index = savedData!.land.indexWhere((land) => land.syno == landSyno);

    if (index != -1) {
      savedData.land[index].crops.add(Crop()
        ..name = crop
        ..yieldOfCrop = yieldOfCropDouble);

      dataBox.put(savedData.id, savedData);

      BlocProvider.of<HiveBloc>(context).add(
        SyncHiveToFirestoreRequested(profileData: savedData),
      );

      print('Crop added');
    } else {
      // Handle the case where the Land instance with the specified syno is not found
      print('Land with syno $landSyno not found.');
    }

    _yieldController.clear();

    BlocProvider.of<HiveBloc>(context).add(
      HiveDataRequested(),
    );
  }

  void _deleteCropFromHive(landSyno, indexToDelete) async {
    var dataBox = Hive.box<ProfileData>('profileDataBox3');

    var savedData = dataBox.get('profile');

    // Find the Land instance with the specified syno
    int index = savedData!.land.indexWhere((land) => land.syno == landSyno);

    if (index != -1) {
      savedData.land[index].crops.removeAt(indexToDelete);

      dataBox.put(savedData.id, savedData);

      // print('Crop removed');
      dataBox.put(savedData.id, savedData);

      BlocProvider.of<HiveBloc>(context).add(
        SyncHiveToFirestoreRequested(profileData: savedData),
      );
    } else {
      // print('Land with syno $landSyno not found.');
    }

    BlocProvider.of<HiveBloc>(context).add(
      HiveDataRequested(),
    );
  }

  void _addAnimalToHive(landSyno, name, quantity) async {
    if (name.isEmpty) {
      ToastComponent.showDialog(
        localContext.enter_animal_name,
        gravity: Toast.center,
        duration: Toast.lengthLong,
      );
      return;
    }

    if (quantity.isEmpty) {
      ToastComponent.showDialog(
        localContext.enter_count,
        gravity: Toast.center,
        duration: Toast.lengthLong,
      );
      return;
    }

    int quantityInt = 0;
    try {
      quantityInt = int.parse(quantity);
    } catch (e) {
      ToastComponent.showDialog(localContext.enter_valid_count,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    var dataBox = Hive.box<ProfileData>('profileDataBox3');

    var savedData = dataBox.get('profile');

    // Find the Land instance with the specified syno
    int index = savedData!.land.indexWhere((land) => land.syno == landSyno);

    if (index != -1) {
      savedData.land[index].animals.add(
        Animal()
          ..name = name
          ..quantity = quantityInt,
      );

      dataBox.put(savedData.id, savedData);

      BlocProvider.of<HiveBloc>(context).add(
        SyncHiveToFirestoreRequested(profileData: savedData),
      );
    } else {
      // Handle the case where the Land instance with the specified syno is not found
      print('Land with syno $landSyno not found.');
    }

    _animalNameController.clear();
    _animalQuantityController.clear();

    BlocProvider.of<HiveBloc>(context).add(
      HiveDataRequested(),
    );
  }

  void _deleteAnimalFromHive(landSyno, indexToDelete) async {
    var dataBox = Hive.box<ProfileData>('profileDataBox3');

    var savedData = dataBox.get('profile');

    // Find the Land instance with the specified syno
    int index = savedData!.land.indexWhere((land) => land.syno == landSyno);

    if (index != -1) {
      savedData.land[index].animals.removeAt(indexToDelete);

      dataBox.put(savedData.id, savedData);

      // print('Crop removed');
      dataBox.put(savedData.id, savedData);

      BlocProvider.of<HiveBloc>(context).add(
        SyncHiveToFirestoreRequested(profileData: savedData),
      );
    } else {
      // print('Land with syno $landSyno not found.');
    }

    BlocProvider.of<HiveBloc>(context).add(
      HiveDataRequested(),
    );
  }

  List<Crop> getCropsForSyno(ProfileData profileData, String? landSyno) {
    if (landSyno == null) {
      return [];
    }
    int index = profileData.land.indexWhere((land) => land.syno == landSyno);
    // if (index != -1) {
    return profileData.land[index].crops;
  }

  List<Animal> getAnimalsForSyno(ProfileData profileData, String? landSyno) {
    if (landSyno == null) {
      return [];
    }
    int index = profileData.land.indexWhere((land) => land.syno == landSyno);
    // if (index != -1) {
    return profileData.land[index].animals;
  }

  List<String> getMachinesForSyno(ProfileData profileData, String? landSyno) {
    if (landSyno == null) {
      return [];
    }
    int index = profileData.land.indexWhere((land) => land.syno == landSyno);
    // if (index != -1) {
    return profileData.land[index].equipments;
  }

  void _addEquipmentToHive(landSyno, equipment) async {
    if (landSyno.isEmpty) {
      ToastComponent.showDialog(localContext.select_land,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    if (equipment.isEmpty) {
      ToastComponent.showDialog(localContext.select_crop,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    var dataBox = Hive.box<ProfileData>('profileDataBox3');

    var savedData = dataBox.get('profile');

    // Find the Land instance with the specified syno
    int index = savedData!.land.indexWhere((land) => land.syno == landSyno);

    if (index != -1) {
      savedData.land[index].equipments.add(equipment);

      dataBox.put(savedData.id, savedData);

      var equipmentDict = [];

      for (equipment in savedData.land[index].equipments) {
        equipmentDict.add(equipment);
      }

      dataBox.put(savedData.id, savedData);
      dataBox.put(savedData.id, savedData);

      BlocProvider.of<HiveBloc>(context).add(
        SyncHiveToFirestoreRequested(profileData: savedData),
      );

      print('equipment added');
    } else {
      // Handle the case where the Land instance with the specified syno is not found
      print('Land with syno $landSyno not found.');
    }

    BlocProvider.of<HiveBloc>(context).add(
      HiveDataRequested(),
    );
  }

  void _deleteEquipmentFromHive(landSyno, indexToDelete) async {
    var dataBox = Hive.box<ProfileData>('profileDataBox3');

    var savedData = dataBox.get('profile');

    // Find the Land instance with the specified syno
    int index = savedData!.land.indexWhere((land) => land.syno == landSyno);

    if (index != -1) {
      savedData.land[index].equipments.removeAt(indexToDelete);

      dataBox.put(savedData.id, savedData);

      print('equipment removed');
      dataBox.put(savedData.id, savedData);

      BlocProvider.of<HiveBloc>(context).add(
        SyncHiveToFirestoreRequested(profileData: savedData),
      );
    } else {
      // Handle the case where the Land instance with the specified syno is not found
      print('Land with syno $landSyno not found.');
    }

    BlocProvider.of<HiveBloc>(context).add(
      HiveDataRequested(),
    );
  }

  Uint8List? _image;
  selectImage() async {
    Uint8List img = await pickImage(ImageSource.camera);
    print('image uploaded');
    _image = img;
  }

  saveProfileImage() async {
    await selectImage();
    BlocProvider.of<ProfileBloc>(context).add(
      ProfileImageUpdateRequested(file: _image!),
    );
  }

  @override
  Widget build(BuildContext context) {
    localContext = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xff107B28), Color(0xff4C7B10)]),
          ),
        ),
        title: Text(AppLocalizations.of(context)!.edit_profile_ucf,
            style: TextStyle(
                color: MyTheme.white,
                fontWeight: FontWeight.w500,
                letterSpacing: .5,
                fontFamily: 'Poppins')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              size: 35,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MoreDetails();
              }));
            },
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: BlocListener<HiveBloc, HiveState>(
        listener: (context, state) {
          if (state is Error) {
            print('STATE: Error: ${state.error}');
          }
          if (state is HiveDataNotReceived) {
            print('STATE: No Data Found');
          }
          if (state is HiveDataReceived) {
            print('STATE: Data Received');
            print(state.profileData.land);
          }
        },
        child: BlocBuilder<HiveBloc, HiveState>(
          builder: (context, state) {
            if (state is Loading)
              return Center(
                child: CircularProgressIndicator(),
              );
            if (state is HiveDataReceived)
              return ListView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(15),
                children: [
                  // The top bar section
                  SizedBox(
                    height: 10,
                  ),
                  HeadingTextWidget(localContext.account_ucf),

                  BlocBuilder<ProfileBloc, profileState.ProfileState>(
                    builder: (context, state) {
                      if (state is profileState.Loading) {
                        return LinearProgressIndicator();
                      }
                      if (state is profileState.ProfileDataReceived) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 3),
                          // height: 100,
                          width: double.infinity,
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.starta,
                            children: [
                              Stack(
                                alignment: AlignmentDirectional.bottomEnd,
                                children: [
                                  Container(
                                    height: 250,
                                    margin: EdgeInsets.only(
                                        bottom: 20, left: 20, right: 20),
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      child: (state.buyerProfileData.photoURL ==
                                                  null ||
                                              state.buyerProfileData.photoURL ==
                                                  '')
                                          ? Image.asset(
                                              "assets/default_profile2.png",
                                              fit: BoxFit.cover,
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: state
                                                  .buyerProfileData.photoURL!,
                                              fit: BoxFit.cover,
                                              progressIndicatorBuilder: (context,
                                                      url, downloadProgress) =>
                                                  Center(
                                                      child: CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress)),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 20,
                                    right: 15,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 5, right: 10),
                                      child: InkWell(
                                        onTap: () {
                                          saveProfileImage();
                                        },
                                        child: Container(
                                            padding: EdgeInsets.all(11),
                                            decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.image,
                                                  color: Colors.white,
                                                ),
                                                Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            )),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              !profileDataUpdating
                                  ? Container(
                                      height: 80,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: MyTheme.green_lighter,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    '${localContext.name_ucf}: ${state.buyerProfileData.name}',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "${localContext.phone_ucf}: ${state.buyerProfileData.phoneNumber}",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Expanded(child: Text('PAN')),
                                          Container(
                                            width: 30,
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _nameControllerForAccount
                                                          .text =
                                                      state.buyerProfileData
                                                          .name;
                                                  profileDataUpdating =
                                                      !profileDataUpdating;
                                                });
                                              },
                                              child: CircleAvatar(
                                                radius: 12,
                                                backgroundColor: MyTheme.green,
                                                child: Icon(
                                                  Icons.edit,
                                                  size: 15.0,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 3),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: MyTheme.green_lighter,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                          "${localContext.phone_ucf}: ${state.buyerProfileData.phoneNumber}"),
                                                    ),
                                                  ],
                                                ),
                                                // Expanded(child: Text('PAN')),
                                                // InkWell(
                                                //   onTap: () {
                                                //     setState(() {
                                                //       _nameControllerForAccount
                                                //               .text =
                                                //           state.buyerProfileData
                                                //               .name;
                                                //       profileDataUpdating =
                                                //           !profileDataUpdating;
                                                //     });
                                                //   },
                                                //   child: CircleAvatar(
                                                //     radius: 12,
                                                //     backgroundColor:
                                                //         MyTheme.green,
                                                //     child: Icon(
                                                //       Icons.edit,
                                                //       size: 15.0,
                                                //       color: Colors.white,
                                                //     ),
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        TextFieldWidget(
                                          'Aadhar Card',
                                          _nameControllerForAccount,
                                          localContext.enter,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(child: SizedBox()),
                                            TextButton(
                                              child:
                                                  Text(localContext.save_ucf),
                                              onPressed: () {
                                                BlocProvider.of<ProfileBloc>(
                                                        context)
                                                    .add(
                                                  UserNameUpdateRequested(
                                                      name:
                                                          _nameControllerForAccount
                                                              .text),
                                                );
                                                setState(() {
                                                  profileDataUpdating = false;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),

                  SizedBox(
                    height: 18,
                  ),
                  Divider(
                    // color: MyTheme.grey_153,
                    thickness: 2,
                  ),
                  SizedBox(
                    height: 8,
                  ),

                  HeadingTextWidget('KYC'),

                  if (state.profileData.kyc.aadhar.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 3),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: MyTheme.green_lighter,
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      'Aadhar: ${state.profileData.kyc.aadhar}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      "PAN: ${state.profileData.kyc.pan == '' ? 'N/A' : state.profileData.kyc.pan}"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      "GST: ${state.profileData.kyc.gst == '' ? 'N/A' : state.profileData.kyc.gst}"),
                                ),
                              ],
                            ),
                            // Expanded(child: Text('PAN')),
                            InkWell(
                              onTap: () {
                                _aadharController.text =
                                    state.profileData.kyc.aadhar;
                                _panController.text =
                                    state.profileData.kyc.pan.toString();
                                _gstController.text =
                                    state.profileData.kyc.gst.toString();
                                _deleteKycFromHive();
                                // _editKyc();
                              },
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: MyTheme.green,
                                child: Icon(
                                  Icons.edit,
                                  size: 15.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 10,
                  ),
                  if (state.profileData.kyc.aadhar.isEmpty)
                    Column(
                      children: [
                        TextFieldWidget('Aadhar Card', _aadharController,
                            '${localContext.enter} Aadhar Card'),
                        Row(
                          children: [
                            Expanded(child: SizedBox.shrink()),
                            Text(
                              '${_aadharController.text.length}/12',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: _aadharController.text.length > 12
                                    ? Colors.red
                                    : _aadharController.text.length == 12
                                        ? Colors.green
                                        : Colors.grey,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFieldWidget('PAN Card', _panController,
                            '${localContext.enter} PAN Card'),
                        TextFieldWidget('GST', _gstController,
                            '${localContext.enter} GST Number'),
                        Row(
                          children: [
                            Expanded(child: SizedBox()),
                            TextButton(
                              child: Text(localContext.save_ucf),
                              onPressed: () {
                                _saveKycToHive(_aadharController.text,
                                    _panController.text, _gstController.text);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                  SizedBox(
                    height: 8,
                  ),
                  Divider(
                    // color: MyTheme.grey_153,
                    thickness: 2,
                  ),
                  SizedBox(
                    height: 12,
                  ),

                  HeadingTextWidget(localContext.address_details),
                  Column(
                    children: List.generate(
                      state.profileData.address.length,
                      (index) {
                        var item = state.profileData.address[index];
                        return Container(
                          height: 130,
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: MyTheme.green_lighter,
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${localContext.district}: ${item.district}'),
                                  Text('${localContext.taluk}: ${item.taluk}'),
                                  Text(
                                      '${localContext.gram_panchayat}: ${item.gramPanchayat}'),
                                  Text(
                                      '${localContext.village}: ${item.village}'),
                                  Text('Pincode: ${item.pincode}'),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  _deleteDataFromHive(
                                    DataCollectionType.address,
                                    index,
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: MyTheme.green,
                                  child: Icon(
                                    Icons.delete,
                                    size: 15.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),

                  // address input
                  if (state.profileData.address.length == 0)
                    Column(
                      children: [
                        TexiFieldWidgetForDouble(
                          _pinCodeController,
                          "Pincode",
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        AddressSearchDropdown(
                            title: localContext.select_district,
                            hintText: localContext.search,
                            context: context,
                            dropdownValue: districtsDropdownValue,
                            listOfItems: districtsList,
                            searchController: textEditingController,
                            onChanged: (String? newValue) {
                              setState(() {
                                taluksDropdownValue = null;
                                gramPanchayatsDropdownValue = null;
                                villageNamesDropdownValue = null;
                                districtsDropdownValue = newValue!;
                              });
                              fetchTaluks(
                                  districtName: districtsDropdownValue!);
                            },
                            onMenuStateChange: (p0) {
                              if (!p0) {
                                textEditingController.clear();
                              }
                            },
                            isEnabled: true,
                            disabledHint: localContext.district),
                        SizedBox(
                          height: 10,
                        ),
                        AddressSearchDropdown(
                          isEnabled: isTalukEnabled,
                          disabledHint: localContext.select_district_first,
                          title: localContext.select_taluk,
                          hintText: localContext.search,
                          context: context,
                          dropdownValue: taluksDropdownValue,
                          listOfItems: taluksList,
                          searchController: textEditingController,
                          onChanged: (String? newValue) {
                            setState(() {
                              gramPanchayatsDropdownValue = null;
                              villageNamesDropdownValue = null;
                              taluksDropdownValue = newValue!;
                            });
                            fetchGramPanchayats(
                                talukName: taluksDropdownValue!);
                          },
                          onMenuStateChange: (p0) {
                            if (!p0) {
                              textEditingController.clear();
                            }
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        AddressSearchDropdown(
                          searchController: textEditingController,
                          hintText: localContext.search,
                          title: localContext.select_gram_panchayat,
                          context: context,
                          dropdownValue: gramPanchayatsDropdownValue,
                          listOfItems: gramPanchayatsList,
                          disabledHint: localContext.select_taluk_first,
                          isEnabled: isGramPanchayadEnabled,
                          onChanged: (String? newValue) {
                            setState(() {
                              villageNamesDropdownValue = null;
                              gramPanchayatsDropdownValue = newValue!;
                            });
                            fetchVillageNames(
                                gramPanchayatName:
                                    gramPanchayatsDropdownValue!);
                          },
                          onMenuStateChange: (p0) {
                            if (!p0) {
                              textEditingController.clear();
                            }
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        AddressSearchDropdown(
                          searchController: textEditingController,
                          hintText: localContext.search,
                          title: localContext.select_village,
                          context: context,
                          dropdownValue: villageNamesDropdownValue,
                          listOfItems: villageNamesList,
                          disabledHint:
                              localContext.select_gram_panchayat_first,
                          isEnabled: isVillageNameEnabled,
                          onChanged: (String? newValue) {
                            setState(() {
                              villageNamesDropdownValue = newValue!;
                            });
                          },
                          onMenuStateChange: (p0) {
                            if (!p0) {
                              textEditingController.clear();
                            }
                          },
                        ),
                        Row(
                          children: [
                            Expanded(child: SizedBox()),
                            TextButton(
                              child: Text(localContext.save_ucf),
                              onPressed: () {
                                _addAddressToHive(
                                  pincode: _pinCodeController.text,
                                  gramPanchayat: gramPanchayatsDropdownValue,
                                  district: districtsDropdownValue,
                                  villageName: villageNamesDropdownValue,
                                  taluk: taluksDropdownValue,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      // color: MyTheme.grey_153,
                      thickness: 2,
                    ),
                  ),

                  // land details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeadingTextWidget(localContext.land_details),

                      Column(
                        children: List.generate(
                          state.profileData.land.length,
                          (index) {
                            var item = state.profileData.land[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 3),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: MyTheme.green_lighter,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(item.village)),
                                    Expanded(child: Text(item.syno)),
                                    Expanded(child: Text(item.area.toString())),
                                    // Expanded(child: Text(item.village)),
                                    InkWell(
                                      onTap: () {
                                        _deleteDataFromHive(
                                          DataCollectionType.land,
                                          index,
                                        );
                                        setState(() {});
                                      },
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundColor: MyTheme.green,
                                        child: Icon(
                                          Icons.delete,
                                          size: 15.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      BlocListener<AuthBloc, authState.AuthState>(
                        listener: (context, state) {
                          if (state
                              is authState.LandLocationsForPincodeReceived) {
                            ToastComponent.showDialog(
                                localContext.locations_fetched,
                                gravity: Toast.center,
                                duration: Toast.lengthLong);
                            postOfficeResponseForLand =
                                state.postOfficeResponse;
                            for (var postOffice
                                in state.postOfficeResponse.postOffices) {
                              locationsListForLand.add(postOffice.name);
                            }
                            isDropdownForLandEnabled = true;
                            // print(state.postOfficeResponse.postOffices[0].name);
                            // print(state.postOfficeResponse.message);
                          }
                          if (state
                              is authState.LandLocationsForPincodeLoading) {
                            locationDropdownValueForLand = null;
                            clearAddressValuesForLand();
                            locationsListForLand.clear();
                            ToastComponent.showDialog(
                                localContext.fetching_locations,
                                gravity: Toast.center,
                                duration: Toast.lengthLong);
                          }
                          // TODO: implement listener
                        },
                        child: BlocBuilder<AuthBloc, authState.AuthState>(
                          builder: (context, state) {
                            return Column(
                              children: [
                                Container(
                                  height: 40,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          // height: 40,
                                          child: TextField(
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                            controller:
                                                _pinCodeControllerForLand,
                                            autofocus: false,
                                            decoration: InputDecorations
                                                .buildInputDecoration_1(
                                                    hint_text: "Pincode"),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          fetchLocationsForLand(context);
                                        },
                                        child: Container(
                                          height: double.infinity,
                                          color: MyTheme.green_lighter,
                                          margin: EdgeInsets.only(
                                            left: 10,
                                            top: 2,
                                            bottom: 2,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Center(
                                            child: Text(
                                              localContext.search,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors
                                          .grey, // You can customize the border color here
                                    ),
                                  ),
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    hint: Text(
                                      localContext.select_village,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                    disabledHint: Text(
                                      localContext.enter_pincode_first,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                    value: locationDropdownValueForLand,
                                    icon: Icon(Icons.arrow_drop_down),
                                    iconSize: 24,
                                    elevation: 16,
                                    underline:
                                        SizedBox(), // Remove the underline
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors
                                          .black, // You can customize the text color here
                                    ),
                                    onChanged: isDropdownForLandEnabled
                                        ? (String? newValue) {
                                            setState(() {
                                              locationDropdownValueForLand =
                                                  newValue!;
                                              getAddressValuesForLand();
                                            });
                                          }
                                        : null,
                                    items: locationsListForLand
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      TextFieldWidget('Syno', _synoController,
                          '${localContext.enter} Syno'),

                      //custom Area text field for accepting double values
                      TexiFieldWidgetForDouble(
                        // 'Area',
                        _areaController,
                        localContext.enter_area_in_acres,
                      ),

                      //Add Land to Hive
                      Row(
                        children: [
                          Expanded(child: SizedBox()),
                          TextButton(
                            child: Text(localContext.save_ucf),
                            onPressed: () {
                              _addLandToHive(
                                _areaController.text,
                                _synoController.text,
                                locationDropdownValueForLand,
                              );
                              landDropdownValue = null;
                            },
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 8,
                      ),
                      Divider(
                        // color: MyTheme.grey_153,
                        thickness: 2,
                      ),
                      SizedBox(
                        height: 12,
                      ),
                    ],
                  ),

                  // farm details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeadingTextWidget(localContext.farm_details),
                      SizedBox(
                        height: 10,
                      ),
                      (state.profileData.land.length == 0)
                          ? Padding(
                              padding: const EdgeInsets.all(20),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  localContext.add_land_first,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: .5,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                DropdownButtonWidget(
                                    localContext.land,
                                    localContext.select_land,
                                    List.generate(
                                      state.profileData.land.length,
                                      (index) {
                                        var item =
                                            state.profileData.land[index];
                                        return DropdownMenuItem(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  child: Text(item.village)),
                                              Expanded(child: Text(item.syno)),
                                              Expanded(
                                                  child: Text(
                                                      item.area.toString())),
                                              // Expanded(child: Text(item.village)),
                                            ],
                                          ),
                                          value: item.syno,
                                        );
                                      },
                                    ),
                                    landDropdownValue, (value) {
                                  setState(() {
                                    landDropdownValue = value;
                                    setState(() {});
                                  });
                                }),

                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8, top: 10, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      localContext.add_crop,
                                      style: TextStyle(
                                          // color: MyTheme.accent_color,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: .5,
                                          fontFamily: 'Poppins'),
                                    ),
                                  ),
                                ),
                                if (landDropdownValue != null)
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Wrap(
                                      children: List.generate(
                                        getCropsForSyno(state.profileData,
                                                landDropdownValue)
                                            .length,
                                        (index) {
                                          var item = getCropsForSyno(
                                              state.profileData,
                                              landDropdownValue)[index];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2),
                                            child: Chip(
                                              backgroundColor:
                                                  MyTheme.green_lighter,
                                              labelPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 0),
                                              label: Text(
                                                  '${item.name} (${item.yieldOfCrop.toInt()})'),
                                              // deleteIcon: Icon(Icons.delete),
                                              onDeleted: () {
                                                _deleteCropFromHive(
                                                    landDropdownValue, index);
                                                setState(() {});
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),

                                // for crop
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    children: [
                                      Row(
                                        // :
                                        // CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: DropdownButtonWidget(
                                                '',
                                                localContext.select_crop,
                                                cropsList.map<
                                                        DropdownMenuItem<
                                                            String>>(
                                                    (String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                                cropDropdownValue, (value) {
                                              setState(() {
                                                cropDropdownValue = value;
                                              });
                                            }),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: TexiFieldWidgetForDouble(
                                                // 'Yield',
                                                _yieldController,
                                                localContext.enter_crop_yield),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(child: SizedBox()),
                                          TextButton(
                                            child: Text(localContext.save_ucf),
                                            onPressed: () {
                                              _addCropToHive(
                                                landDropdownValue,
                                                cropDropdownValue,
                                                _yieldController.text,
                                              );
                                              setState(() {
                                                cropDropdownValue = null;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // add machines
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8, top: 10, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      localContext.add_machines,
                                      style: TextStyle(
                                          // color: MyTheme.accent_color,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: .5,
                                          fontFamily: 'Poppins'),
                                    ),
                                  ),
                                ),
                                // showing machines
                                if (landDropdownValue != null)
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Wrap(
                                      children: List.generate(
                                        getMachinesForSyno(state.profileData,
                                                landDropdownValue)
                                            .length,
                                        (index) {
                                          var item = getMachinesForSyno(
                                              state.profileData,
                                              landDropdownValue)[index];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2),
                                            child: Chip(
                                              backgroundColor:
                                                  MyTheme.green_lighter,
                                              labelPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 0),
                                              label: Text(item),
                                              // deleteIcon: Icon(Icons.delete),
                                              onDeleted: () {
                                                _deleteEquipmentFromHive(
                                                    landDropdownValue, index);
                                                setState(() {});
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                // select machines dropdowns
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    children: [
                                      DropdownButtonWidget(
                                          '',
                                          localContext.select_equipments,
                                          equipmentsList
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          equipmentDropdownValue, (value) {
                                        setState(() {
                                          equipmentDropdownValue = value;
                                        });
                                      }),
                                      Row(
                                        children: [
                                          Expanded(child: SizedBox()),
                                          TextButton(
                                            child: Text(localContext.save_ucf),
                                            onPressed: () {
                                              _addEquipmentToHive(
                                                landDropdownValue,
                                                equipmentDropdownValue,
                                              );
                                              setState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8, top: 10, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      localContext.add_animal,
                                      style: TextStyle(
                                          // color: MyTheme.accent_color,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: .5,
                                          fontFamily: 'Poppins'),
                                    ),
                                  ),
                                ),
                                if (landDropdownValue != null)
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Wrap(
                                      children: List.generate(
                                        getAnimalsForSyno(state.profileData,
                                                landDropdownValue)
                                            .length,
                                        (index) {
                                          var item = getAnimalsForSyno(
                                              state.profileData,
                                              landDropdownValue)[index];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2),
                                            child: Chip(
                                              backgroundColor:
                                                  MyTheme.green_lighter,
                                              labelPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 0),
                                              label: Text(
                                                  '${item.name} (${item.quantity})'),
                                              // deleteIcon: Icon(Icons.delete),
                                              onDeleted: () {
                                                _deleteAnimalFromHive(
                                                    landDropdownValue, index);
                                                setState(() {});
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),

                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: TextFieldWidget(
                                              localContext.animal,
                                              _animalNameController,
                                              localContext.enter_animal_name,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: TexiFieldWidgetForDouble(
                                              // 'Quantity',
                                              _animalQuantityController,
                                              localContext.enter_count,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(child: SizedBox()),
                                          TextButton(
                                            child: Text(localContext.save_ucf),
                                            onPressed: () {
                                              _addAnimalToHive(
                                                landDropdownValue,
                                                _animalNameController.text,
                                                _animalQuantityController.text,
                                              );
                                              setState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ],
              );
            return Container(
              color: Colors.white30,
              child: Text(localContext.something_went_wrong),
            );
          },
        ),
      ),
    );
  }

  DropdownButtonHideUnderline AddressSearchDropdown({
    required BuildContext context,
    required String title,
    required String hintText,
    required String? dropdownValue,
    required List<String> listOfItems,
    required Function(String?) onChanged,
    required TextEditingController searchController,
    required Function(bool) onMenuStateChange,
    required String disabledHint,
    required bool isEnabled,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        disabledHint: Text(
          disabledHint,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        isExpanded: false,
        dropdownStyleData: new DropdownStyleData(
            maxHeight: 400,
            // width: double.infinity,
            // direction: DropdownDirection.textDirection,
            isOverButton: false,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            )),
        hint: Text(
          title,
          maxLines: 1,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).hintColor,
          ),
        ),
        items: listOfItems
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ))
            .toList(),
        value: dropdownValue,
        onChanged: !isEnabled
            ? null
            : (value) {
                onChanged(value);
              },
        buttonStyleData: ButtonStyleData(
          height: 40,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey, // You can customize the border color here
            ),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
        ),
        dropdownSearchData: DropdownSearchData(
          searchController: searchController,
          searchInnerWidgetHeight: 50,
          searchInnerWidget: Container(
            height: 50,
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 4,
              right: 8,
              left: 8,
            ),
            child: TextFormField(
              expands: true,
              maxLines: null,
              controller: searchController,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                hintText: hintText,
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          searchMatchFn: (item, searchValue) {
            return item.value
                .toString()
                .toLowerCase()
                .contains(searchValue.toLowerCase());
          },
        ),
        onMenuStateChange: (isOpen) {
          onMenuStateChange(isOpen);
        },
      ),
    );
  }

  Container NewDropdownWidget({
    required BuildContext context,
    required List<String> listOfItems,
    required String title,
    required String disabledHint,
    required String? dropdownValue,
    required Function(String?) onChanged,
    required bool isEnabled,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey, // You can customize the border color here
        ),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        hint: Text(
          title,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        disabledHint: Text(
          disabledHint,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        value: dropdownValue,
        icon: Icon(Icons.arrow_drop_down),
        iconSize: 24,
        elevation: 16,
        underline: SizedBox(),
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        onChanged: isEnabled ? onChanged : null,
        items: listOfItems.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Column TexiFieldWidgetForDouble(
    // String title,
    TextEditingController _textController,
    String hintText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          child: TextField(
            controller: _textController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            autofocus: false,
            decoration:
                InputDecorations.buildInputDecoration_1(hint_text: hintText),
          ),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  Container DropdownButtonWidget(
      String title,
      String hintText,
      List<DropdownMenuItem<String>>? itemList,
      String? dropdownValue,
      Function(String) onChanged) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      margin: EdgeInsets.only(bottom: 10),
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
        underline: SizedBox(),
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        onChanged: (String? value) {
          onChanged(value!);
        },
        items: itemList,
      ),
    );
  }

  Padding HeadingTextWidget(String headingText) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 7),
      child: Text(
        headingText,
        style: TextStyle(
            color: MyTheme.accent_color,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            // letterSpacing: .5,
            // decoration: TextDecoration.underline,
            fontFamily: 'Poppins'),
      ),
    );
  }

  Column TextFieldWidget(
      String title, TextEditingController _textController, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          child: TextField(
            onChanged: (value) {
              setState(() {});
            },
            controller: _textController,
            autofocus: false,
            decoration:
                InputDecorations.buildInputDecoration_1(hint_text: hintText),
          ),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}

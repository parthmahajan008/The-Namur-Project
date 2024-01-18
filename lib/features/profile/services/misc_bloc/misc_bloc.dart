import 'package:active_ecommerce_flutter/utils/hive_models/models.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'misc_event.dart';
part 'misc_state.dart';

class MiscBloc extends Bloc<MiscEvent, MiscState> {
  MiscBloc() : super(MiscInitial()) {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    on<MiscEvent>((event, emit) {});

    on<MiscDataRequested>((event, emit) async {
      try {
        emit(MiscLoading());
        int friendsCount = 0;
        String villageName;
        String pincode;
        int cropCount = 0;

        var dataBox = Hive.box<ProfileData>('profileDataBox3');

        var savedData = dataBox.get('profile');

        if (savedData == null) {
          emit(MiscError());
          return;
        }

        if (savedData.address.isEmpty || savedData.address[0].village.isEmpty) {
          emit(MiscError());
          return;
        }

        villageName = savedData.address[0].village;
        pincode = savedData.address[0].pincode;

        for (Land land in savedData.land) {
          cropCount += land.crops.length;
        }

        print('here');

        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('buyer')
            .where(FieldPath.documentId, isNotEqualTo: null)
            .where('profileData', isNotEqualTo: null)
            .get();

        print('here2');

        var documents = querySnapshot.docs;

        print(documents[0]);
        print('here3');

        // for (var document in documents) {
        //   Map<String, dynamic> data = document.data()!;
        //   if (data['profileData']['address'].isNotEmpty) {
        //     Map<String, dynamic> data = document.data()!;
        //     if (data['profileData']['address'][0]['pincode'] ==
        //         savedData.address[0].pincode) {
        //       friendsCount++;
        //       print('count incremented');
        //     }
        //   }
        // }

        for (var document in documents) {
          Map<String, dynamic> data = document.data();

          if (data['profileData'] == null) {
            continue;
          }

          if (data['profileData']['address'][0]['pincode'] ==
              savedData.address[0].pincode) {
            friendsCount++;
            print('count incremented');
          }
        }

        print('here4');

        // return [villageName, pincode, count - 1];
        emit(MiscDataReceived(
          numberOfFriends: (friendsCount - 1) < 0 ? 0 : friendsCount - 1,
          numberOfCrops: cropCount,
          villageName: villageName,
          pincode: pincode,
        ));
      } catch (e) {
        emit(MiscError());
      }
    });
  }
}

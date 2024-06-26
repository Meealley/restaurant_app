import 'dart:developer';
// import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kfc/constants/constants.dart';
import 'package:kfc/controller/provider/profile_provider.dart';
import 'package:kfc/controller/services/toast_message_services.dart';
import 'package:kfc/model/address_model.dart';
import 'package:kfc/model/user_address_model.dart';
import 'package:kfc/model/user_model.dart';
import 'package:kfc/view/authscreens/signin_logic_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class UserDataCRUDServices {
  static registerUser(UserModel data, BuildContext context) async {
    try {
      await firestore
          .collection("User")
          .doc(auth.currentUser!.uid)
          .set(data.toMap())
          .whenComplete(() {
        Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              child: const SigninLogiceScreen(),
              type: PageTransitionType.rightToLeft,
            ),
            (route) => false);
      });
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  static addAddress(UserAddressModel data, BuildContext context) async {
    try {
      // String docID = uuid.v1().toString();
      await firestore
          .collection("Address")
          .doc(data.addressID)
          .set(data.toMap())
          .whenComplete(() {
        ToastService.sendScaffoldAlert(
          msg: "Address Added Successfully!",
          toastStatus: "SUCCESS",
          context: context,
        );
        // Navigator.pushAndRemoveUntil(
        //     context,
        //     PageTransition(
        //       child: const SigninLogiceScreen(),
        //       type: PageTransitionType.rightToLeft,
        //     ),
        //     (route) => false);
      });
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  static fetchUserData() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await firestore.collection('User').doc(auth.currentUser!.uid).get();

      UserModel data = UserModel.fromMap(snapshot.data()!);
      return data;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  static fetchAddresses() async {
    List<UserAddressModel> addresses = [];

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('Address')
          .where('userID', isEqualTo: auth.currentUser!.uid)
          .get();
      snapshot.docs.forEach((element) {
        addresses.add(UserAddressModel.fromMap(element.data()));
      });
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
    return addresses;
  }

  static fetchActiveAddress() async {
    List<UserAddressModel> addresses = [];

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('Address')
          .where('userID', isEqualTo: auth.currentUser!.uid)
          .where("isActive", isEqualTo: true)
          .get();
      snapshot.docs.forEach((element) {
        addresses.add(UserAddressModel.fromMap(element.data()));
      });
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
    return addresses[0];
  }

  static setAddressAsActive(UserAddressModel data, BuildContext context) async {
    List<UserAddressModel> addresses =
        context.read<ProfileProvider>().addresses;

    for (var addressData in addresses) {
      if (addressData.addressID != data.addressID) {
        await firestore
            .collection("Address")
            .doc(addressData.addressID)
            .update({"isActive": false});
      }
    }
    await firestore
        .collection("Address")
        .doc(data.addressID)
        .update({"isActive": true});
  }
}

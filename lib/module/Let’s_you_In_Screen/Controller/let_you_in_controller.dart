
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import '../../../api/listing/api_listing.dart';
import '../../../api/url/api_url.dart';
import '../../../routes/app_pages.dart';


class Lets_You_in_controller extends GetxController {

  // final GoogleSignIn googleSignIn = GoogleSignIn(
  //     scopes: ['email', 'profile', 'https://www.googleapis.com/auth/drive'],
  //     clientId:
  //     '229528905608-hprheq53ee8q3ggkvgcrem91fe54qn09.apps.googleusercontent.com');

  // String? get userId => user.value?.uid;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'openid', // ✅ REQUIRED for ID Token
    ],

    serverClientId: '867126694749-7t9ii4an3ad7pv9dmc4a6766pcjt5rkk.apps.googleusercontent.com',

  );
  GoogleSignInAccount? user;

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // user.bindStream(_auth.authStateChanges());
  }

  // Future signInWithGoogle() async {
  //   try {
  //     final GoogleSignIn googleSignIn = GoogleSignIn();
  //     final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
  //     if (googleSignInAccount != null) {
  //       final GoogleSignInAuthentication googleSignInAuthentication =
  //       await googleSignInAccount.authentication;
  //
  //       final OAuthCredential credential = GoogleAuthProvider.credential(
  //         accessToken: googleSignInAuthentication.accessToken,
  //         idToken: googleSignInAuthentication.idToken,
  //       );
  //
  //       final UserCredential authResult =
  //       await FirebaseAuth.instance.signInWithCredential(credential);
  //
  //       // final User? user = authResult.user;
  //
  //       // if (user != null) {
  //       //   // Checking if user is logging in for the first time
  //       //   final userDoc = await FirebaseFirestore.instance
  //       //       .collection('users')
  //       //       .doc(user.uid)
  //       //       .get();
  //       //   if (!userDoc.exists) {
  //       //     // New user. You can now navigate the user to your onboarding screen or create a new user document in Firestore.
  //       //     // For example, creating a user document:
  //       //     await FirebaseFirestore.instance
  //       //         .collection('users')
  //       //         .doc(user.uid)
  //       //         .set({
  //       //       'uid': user.uid,
  //       //       'email': user.email,
  //       //       // Add more fields as needed
  //       //     });
  //       //     print("New user created");
  //       //   } else {
  //       //     // Existing user. Navigate the user to your home screen or perform other actions.
  //       //     print("Welcome back!");
  //       //   }
  //       // }
  //       return authResult;
  //     }
  //   } catch (error) {
  //     print('Error signing in with Google: $error');
  //     // Handle error further if needed
  //   }
  // }

// Future<bool?> facebookLogin() async {
//   try {
//     isLoading.value = true;
//     LoginResult loginResult = await FacebookAuth.instance
//         .login(permissions: ['public_profile', 'email']);
//     final OAuthCredential credential =
//         FacebookAuthProvider.credential(loginResult.accessToken!.token);
//     if (loginResult.status == LoginResult.success) {
//       final userData = await FacebookAuth.instance
//           .getUserData(fields: 'id, name, email, picture');
//       final UserCredential authResult =
//           await FirebaseAuth.instance.signInWithCredential(credential);
//       final String uid = authResult.user!.uid;
//       DateTime now = DateTime.now();
//       String formattedString = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
//       UserDetails userdata = UserDetails(
//           createdAt: formattedString,
//           uid: uid,
//           fid: userData["id"],
//           ProfileImages: userData["picture"]["data"]["url"],
//           name: userData["name"],
//           email: userData["email"],
//           acsessToken: loginResult.accessToken!.token);
//       DocumentReference documentReference =
//           await userDataInfo.add(userdata.toMap());
//       String docId = documentReference.id;
//       userdata.did = docId;
//       await userDataInfo.doc(docId).update(userdata.toMap());
//       isLoading.value = false;
//       return true;
//     } else if (loginResult.status == LoginStatus.cancelled) {
//       isLoading.value = false;
//       print("Cancels");
//       return false;
//     } else {
//       isLoading.value = false;
//       print("Error ");
//       return false;
//     }
//   } catch (e) {
//     print("Error");
//   } finally {
//     isLoading.value = false;
//   }
// }

// Future<UserCredential> signInWithFacebook() async {
//   // Trigger the sign-in flow
//   final LoginResult result = await FacebookAuth.instance.login();
//
//   if (result.status == LoginStatus.success) {
//     // Obtain the access token from the Facebook login result
//     final AccessToken accessToken = result.accessToken!;
//
//     // Print the access token
//     print("Access Token: ${accessToken.tokenString}");
//
//     // Create a credential from the access token
//     final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(accessToken.tokenString);
//
//     // Sign in with the credential and return the UserCredential
//     return await _auth.signInWithCredential(facebookAuthCredential);
//   } else {
//     throw FirebaseAuthException(
//       message: result.message,
//       code: 'ERROR_ABORTED_BY_USER',
//     );
//   }
// }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('❌ User canceled Google Sign-In');
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        print("❌ ID Token is null. Ensure SHA-1 fingerprint is set up in Firebase.");
        return;
      }



      // Prepare request to backend
      final Map<String, String> headers = {'Content-Type': 'application/json'};
      final Map<String, dynamic> body = {'idToken': idToken};

      print("📡 Sending ID Token to Backend: ${ApiUrl.googleLogin}");

      final response = await NetworkService.makePostRequest(
        url: ApiUrl.googleLogin,
        headers: headers,
        body: body,
      );

      print("🧾 Backend Response: $response");

      if (response.containsKey('statusCode') &&
          (response['statusCode'] == 200 || response['statusCode'] == 201)) {
        print("✅ Login Successful");

      } else {
        print("❌ Login Failed: ${response['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print("❌ Exception during Google Sign-In: $e");
    }
  }
}



import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';


class Lets_You_in_controller extends GetxController {

  // final GoogleSignIn googleSignIn = GoogleSignIn(
  //     scopes: ['email', 'profile', 'https://www.googleapis.com/auth/drive'],
  //     clientId:
  //     '229528905608-hprheq53ee8q3ggkvgcrem91fe54qn09.apps.googleusercontent.com');

  // String? get userId => user.value?.uid;

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
}

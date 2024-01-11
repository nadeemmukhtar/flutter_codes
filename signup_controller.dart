import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/common/widgets/loaders/loader.dart';
import 'package:t_store/data/repositories.authentication/authentication_repository.dart';
import 'package:t_store/data/repositories.user/user_repository.dart';
import 'package:t_store/features/authentication/controllers/controllers.networkManager/network_manager.dart';
import 'package:t_store/features/authentication/models/user_model.dart';
import 'package:t_store/features/authentication/screens/signup/verify_email.dart';
import 'package:t_store/utils/constants/image_strings.dart';
import 'package:t_store/utils/popups/full_screen_loader.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  /// Varibles
  final hidePassword = true.obs;
  final privacyPolicy = false.obs;
  // final selectedGender = "".obs;

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final username = TextEditingController();
  final email = TextEditingController();
  final phoneNumber = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  // onChangedGender(gender) {
  //   selectedGender.value = gender;
  // }

  /// Signup
  void signup() async {
    try {
      /// start loading

      TFullScreenLoader.openLoadingDialog(
          'We are processing your information...', TImages.loading);

      /// Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TLoaders.warningSnackBar(
          title: 'Oops!',
          message: 'Please check your internet connection',
        );
        TFullScreenLoader.stopLoading();
        return;
      }

      /// Form Validaition
      if (!signupFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      /// Privacy Policy Check
      if (!privacyPolicy.value) {
        TLoaders.warningSnackBar(
          title: 'Accept Privacy Policy',
          message:
              'In order to create account, you must have to read and accept the Privact Policy & Terms of Use.',
        );
        TFullScreenLoader.stopLoading();
        return;
      }

      /// Register user in firebase authentication and save your data in firebase
      final userCredential = await AuthenticationRepository.instance
          .registerWithEmailAndPassword(
              email.text.trim(), password.text.trim());

      /// Save Authenticated user data in firebase firestore
      final newUser = UserModel(
        id: userCredential.user!.uid,
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        username: username.text.trim(),
        email: email.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        gender: 'Not Set',
        dob: DateTime.fromMillisecondsSinceEpoch(0),
        profilePicture: '',
      );

      final userRepository = Get.put(UserRepository());
      await userRepository.saveUserRecord(newUser);

      TFullScreenLoader.stopLoading();

      /// show success message
      TLoaders.successSnackBar(
        title: 'Congratulations',
        message: 'Your account has been created! verify email to continue',
      );

      /// Move to verify screen
      Get.to(VerifyEmailScreen(email: email.text.trim()));
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}

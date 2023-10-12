import 'dart:io' show Platform;

import 'package:active_ecommerce_flutter/features/auth/screens/otp.dart';
import 'package:active_ecommerce_flutter/features/auth/screens/password_forget.dart';
// import 'package:active_ecommerce_flutter/screens/password_otp.dart';
import 'package:active_ecommerce_flutter/features/auth/screens/registration.dart';
import 'package:active_ecommerce_flutter/features/auth/services/auth_bloc/auth_bloc.dart';
import 'package:active_ecommerce_flutter/features/auth/services/auth_bloc/auth_state.dart';
import 'package:active_ecommerce_flutter/features/auth/services/auth_repository.dart';
import 'package:active_ecommerce_flutter/features/auth/services/firestore_repository.dart';
import 'package:active_ecommerce_flutter/features/profile/enum.dart';
import 'package:active_ecommerce_flutter/features/profile/hive_models/models.dart'
    as hiveModels;
// import 'package:active_ecommerce_flutter/features/auth/services/auth_service.text';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart'
    as permissionHandler;
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:toast/toast.dart';

import '../../../app_config.dart';
import '../../../custom/btn.dart';
import '../../../custom/input_decorations.dart';
import '../../../custom/intl_phone_input.dart';
import '../../../custom/toast_component.dart';
import '../../../helpers/shared_value_helper.dart';
import '../../../my_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../repositories/address_repository.dart';
import '../../../ui_elements/auth_ui.dart';
import '../../../screens/main.dart';
import '../services/auth_bloc/auth_event.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _login_by = "email"; //phone or email
  String initialCountry = 'US';

  // final _auth = FirebaseAuth.instance;

  // PhoneNumber phoneCode = PhoneNumber(isoCode: 'US', dialCode: "+1");
  var countries_code = <String?>[];

  String? _phone = "";

  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
    fetch_country();
  }

  fetch_country() async {
    var data = await AddressRepository().getCountryList();
    data.countries.forEach((c) => countries_code.add(c.code));
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  // late User loggedInUser;

  onPressedLogin(BuildContext buildContext) async {
    // print('login clicked');
    var email = _emailController.text.toString();
    var phone = _phoneNumberController.text.toString();
    var password = _passwordController.text.toString();

    if (_login_by == 'email' && email == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_email,
          gravity: Toast.center, duration: Toast.lengthLong);
      return Main(
        go_back: false,
      );
    } else if (_login_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.enter_phone_number,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    } else if (_login_by == 'email' && password == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_password,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    if (_login_by == "phone") {
      String newNumber = '+91 $phone';
      BlocProvider.of<AuthBloc>(buildContext).add(
        PhoneVerificationRequested(newNumber),
      );
    } else {
      // print('calling begins');
      BlocProvider.of<AuthBloc>(buildContext).add(
        SignInWithEmailRequested(email, password),
      );
      // print('calling ends');
    }
  }

  onPressedGoogleLogin(BuildContext buildContext) async {
    BlocProvider.of<AuthBloc>(buildContext).add(
      GoogleSignInRequested(),
    );
  }

  onPressedFacebookLogin() async {
    print('Facebook login attempted');
    // final user = await AuthService.firebase().loginWithGoogle();
    //
    // Navigator.pushAndRemoveUntil(context,
    //     MaterialPageRoute(builder: (context) {
    //       return Main();
    //     }), (newRoute) => false);
  }

  Location location = Location();
  late bool _serviceEnabled;
  late permissionHandler.PermissionStatus _permissionGranted;
  late LocationData _locationData;

  Future<void> checkLocationPermission() async {
    var dataBox = Hive.box<hiveModels.PrimaryLocation>('primaryLocationBox');

    var savedData = dataBox.get('locationData');

    if (savedData != null) {
      print("saved Latitude: ${savedData.latitude}");
      print("saved Longitude: ${savedData.longitude}");
      return;
    }

    print('no saved location data found');

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await permissionHandler.Permission.location.request();
    if (_permissionGranted != permissionHandler.PermissionStatus.granted) {
      return;
    }

    _locationData = await location.getLocation();
    print("new Latitude: ${_locationData.latitude}");
    print("new Longitude: ${_locationData.longitude}");

    var primaryLocation = hiveModels.PrimaryLocation()
      ..id = "locationData"
      ..isAddress = false
      ..latitude = _locationData.latitude as double
      ..longitude = _locationData.longitude as double
      ..address = "";

    await dataBox.put(primaryLocation.id, primaryLocation);
  }

  @override
  Widget build(BuildContext context) {
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    AuthRepository _authRepository = AuthRepository();
    FirestoreRepository _firestoreRepository = FirestoreRepository();
    return BlocProvider(
      create: (context) => AuthBloc(
          authRepository: _authRepository,
          firestoreRepository: _firestoreRepository),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is Authenticated) {
            ToastComponent.showDialog('Login Successful',
                gravity: Toast.center, duration: Toast.lengthLong);
            await checkLocationPermission();
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) {
              return Main();
            }), (newRoute) => false);
          }
          if (state is AuthError) {
            final errorMessage =
                state.error.toString().replaceAll('Exception:', '');
            ToastComponent.showDialog(errorMessage.trim(),
                gravity: Toast.center, duration: Toast.lengthLong);
          }
          if (state is PhoneVerificationCompleted) {
            ToastComponent.showDialog('OTP sent to your phone number',
                gravity: Toast.center, duration: Toast.lengthLong);

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Otp(verificationId: state.verificationId.toString()
                            // resendToken: resendToken
                            )));
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Loading)
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            if (state is Authenticated)
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            return Scaffold(
              body: AuthScreen.buildScreen(
                  context,
                  "${AppLocalizations.of(context)!.login_to} " +
                      AppConfig.app_name,
                  buildBody(context, _screen_width)),
            );
          },
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context, double _screen_width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: _screen_width,
          height: MediaQuery.of(context).size.height / 2.01,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "ನಮ್ಮೂರ್",
                style: TextStyle(
                  color: MyTheme.primary_color,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                "Welcome to namur",
                style: TextStyle(
                    color: MyTheme.primary_color,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    fontFamily: 'Poppins'),
              ),

              SizedBox(height: 10),

              (_login_by == "phone") ? SizedBox(height: 30) : Container(),

              if (_login_by == "email")
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 40,
                        //"Email_ Id" text field
                        child: TextField(
                          controller: _emailController,
                          autofocus: false,
                          decoration: InputDecorations.buildInputDecoration_1(
                              hint_text: "Email Id"),
                        ),
                      ),
                      otp_addon_installed.$
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  _login_by = "phone";
                                });
                              },
                              child: Text(
                                AppLocalizations.of(context)!
                                    .or_login_with_a_phone,
                                style: TextStyle(
                                    color: MyTheme.accent_color,
                                    fontStyle: FontStyle.italic,
                                    decoration: TextDecoration.underline),
                              ),
                            )
                          : Container()
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 40,
                        child: CustomInternationalPhoneNumberInput(
                          // isEnabled: false,
                          maxLength: 12,
                          countries: countries_code,
                          initialValue: PhoneNumber(isoCode: 'IN'),
                          // Set the initial value to India (ISO code: 'IN')
                          onInputChanged: (PhoneNumber number) {
                            print(number.phoneNumber);
                            setState(() {
                              _phone = number.phoneNumber;
                              print('phone: $_phone');
                            });
                          },
                          onInputValidated: (bool value) {
                            print(value);
                          },
                          selectorConfig: SelectorConfig(
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                            leadingPadding: 0.0,
                            showFlags: false,
                            trailingSpace: false,
                            setSelectorButtonAsPrefixIcon: false,
                          ),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          selectorTextStyle:
                              TextStyle(color: MyTheme.font_grey),
                          textStyle: TextStyle(color: MyTheme.font_grey),
                          // initialValue: PhoneNumber(
                          //     isoCode: countries_code[0].toString()),
                          textFieldController: _phoneNumberController,
                          formatInput: false,
                          // Set this to false to remove the space after the 4th character
                          keyboardType: TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          inputDecoration:
                              InputDecorations.buildInputDecoration_phone(
                                  hint_text: "Mobile Number"),
                          onSaved: (PhoneNumber number) {
                            print('On Saved: $number');
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              //Password textbox
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    (_login_by == "email")
                        ? Container(
                            height: 40,
                            child: TextField(
                              controller: _passwordController,
                              autofocus: false,
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              decoration:
                                  InputDecorations.buildInputDecoration_1(
                                      hint_text: "Password"),
                            ),
                          )
                        : Container(),

                    SizedBox(height: 10),

                    //"Forgot Password" Text button
                    if (_login_by == "email")
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return PasswordForget();
                          }));
                        },
                        child: Text(
                          AppLocalizations.of(context)!
                              .login_screen_forgot_password,
                          style: TextStyle(
                              color: MyTheme.primary_color,
                              fontFamily: 'Poppins',
                              fontStyle: FontStyle.italic,
                              decoration: TextDecoration.underline),
                        ),
                      )
                  ],
                ),
              ),

              // SizedBox(height: 10),
              //SIGNUP and LOGIN buttons row
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //SIGNUP button
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width / 2.5,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: MyTheme.textfield_grey, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12.0)),
                          color: MyTheme.primary_color),
                      child: Btn.minWidthFixHeight(
                        minWidth: MediaQuery.of(context).size.width,
                        height: 44,
                        //  color: MyTheme.amber,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0))),
                        child: Text(
                          AppLocalizations.of(context)!
                              .login_screen_create_account,
                          style: TextStyle(
                              color: MyTheme.white,
                              fontFamily: 'Poppins',
                              letterSpacing: .5,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Registration()));
                        },
                      ),
                    ),

                    SizedBox(width: 20),

                    //LOGIN button
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width / 2.5,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: MyTheme.textfield_grey, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12.0))),
                      child: Btn.minWidthFixHeight(
                        minWidth: MediaQuery.of(context).size.width,
                        height: 50,
                        color: MyTheme.primary_color,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0))),
                        child: Text(
                          AppLocalizations.of(context)!.login_screen_log_in,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              letterSpacing: .5,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500),
                        ),
                        onPressed: () {
                          onPressedLogin(context);
                          // BlocProvider.of<AuthBloc>(context).add(
                          //   SignInWithEmailRequested(
                          //       _emailController.text.toString(),
                          //       _passwordController.text.toString()),
                          // );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // login with email/phone button
              if (_login_by == "email")
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20, top: 20),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _login_by = "phone";
                      });
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          border: Border.all(color: MyTheme.primary_color),
                          borderRadius: BorderRadius.circular(10)),
                      child: Btn.minWidthFixHeight(
                          minWidth: MediaQuery.of(context).size.width,
                          height: 50,
                          //  color: MyTheme.amber,
                          shape: RoundedRectangleBorder(
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(10.0))),
                          child: Text(
                            AppLocalizations.of(context)!.or_login_with_a_phone,
                            style: TextStyle(
                                color: MyTheme.primary_color,
                                fontFamily: 'Poppins'),
                          )),
                    ),
                  ),
                )
              else
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20, top: 25),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _login_by = "email";
                      });
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          border: Border.all(color: MyTheme.primary_color),
                          borderRadius: BorderRadius.circular(10)),
                      child: Btn.minWidthFixHeight(
                        minWidth: MediaQuery.of(context).size.width,
                        height: 50,
                        //  color: MyTheme.amber,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0))),
                        child: Text(
                          AppLocalizations.of(context)!.or_login_with_an_email,
                          style: TextStyle(
                            color: MyTheme.primary_color,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // SizedBox(height: 20),
              // Padding(
              //   padding: const EdgeInsets.only(top: 15.0, left: 50, right: 50),
              //   child: Divider(
              //     color: MyTheme.textfield_grey,
              //     thickness: 3,
              //   ),
              // ),
              // SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        onPressedGoogleLogin(context);
                        // print('google');
                      },
                      child: Container(
                        width: 40,
                        child: Image.asset("assets/google_logo.png"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

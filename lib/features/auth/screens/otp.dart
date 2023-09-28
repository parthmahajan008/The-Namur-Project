import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/features/auth/services/auth_exceptions.dart';
// import 'package:active_ecommerce_flutter/features/auth/services/auth_service.text';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/features/auth/screens/login.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:otp_text_field/style.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:otp_text_field/otp_text_field.dart';

import 'package:active_ecommerce_flutter/screens/main.dart';
// import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class Otp extends StatefulWidget {
  Otp(
      {Key? key,
      this.verify_by = "email",
      this.user_id,
      required this.verificationId})
      : super(key: key);
  final String verify_by;
  final int? user_id;
  final String verificationId;

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  //controllers
  TextEditingController _verificationCodeController = TextEditingController();
  OtpFieldController _verificationController = OtpFieldController();
  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onTapResend() async {
    var resendCodeResponse = await AuthRepository()
        .getResendCodeResponse(widget.user_id, widget.verify_by);

    if (resendCodeResponse.result == false) {
      ToastComponent.showDialog(resendCodeResponse.message!,
          gravity: Toast.center, duration: Toast.lengthLong);
    } else {
      ToastComponent.showDialog(resendCodeResponse.message!,
          gravity: Toast.center, duration: Toast.lengthLong);
    }
  }

  onPressConfirm() async {
    // var code = _verificationController.toString();
    String code = otp.join('');
    print('OTP: $code');

    if (code == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_verification_code,
        gravity: Toast.center,
        duration: Toast.lengthLong,
      );
      return;
    }
    if (otp.length < 6) {
      ToastComponent.showDialog(
        'Please enter full code',
        gravity: Toast.center,
        duration: Toast.lengthLong,
      );
      return;
    }
    //
    // final credential = PhoneAuthProvider.credential(
    //   verificationId: widget.verificationId,
    //   smsCode: code,
    // );

    try {
      // final user = await AuthService.firebase()
      //     .loginWithPhone(verificationId: widget.verificationId, otp: code);

      // print('User: ${user?.userId.toString()}');
      ToastComponent.showDialog(
        'Login Successful',
        gravity: Toast.center,
        duration: Toast.lengthLong,
      );
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return Main();
      }), (newRoute) => false);
    } on InvalidOTPAuthException {
      ToastComponent.showDialog('Invalid OTP',
          gravity: Toast.center, duration: Toast.lengthLong);
    } on TooManyRequestsAuthException {
      ToastComponent.showDialog(
          'Maximum requests limit reached. Please try again later',
          gravity: Toast.center,
          duration: Toast.lengthLong);
    } on ExpiredOTPAuthException {
      ToastComponent.showDialog('OTP Expired.',
          gravity: Toast.center, duration: Toast.lengthLong);
    } on GenericAuthException {
      ToastComponent.showDialog('Something went wrong. Please try again.',
          gravity: Toast.center, duration: Toast.lengthLong);
    }

    // var confirmCodeResponse =
    //     await AuthRepository().getConfirmCodeResponse(widget.user_id, code);
    //
    // if (confirmCodeResponse.result == false) {
    //   ToastComponent.showDialog(confirmCodeResponse.message!,
    //       gravity: Toast.center, duration: Toast.lengthLong);
    // } else {
    //   ToastComponent.showDialog(confirmCodeResponse.message!,
    //       gravity: Toast.center, duration: Toast.lengthLong);
    //
    //   Navigator.push(context, MaterialPageRoute(builder: (context) {
    //     return Login();
    //   }));
  }

  List<String> otp = List.filled(6, ''); // Change the size to 6

  @override
  Widget build(BuildContext context) {
    String _verify_by = widget.verify_by; //phone or email
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                    child: Container(
                        height: MediaQuery.of(context).size.height / 2,
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          'assets/Group 211.png',
                          fit: BoxFit.cover,
                        ))),
                SizedBox()
              ],
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 20,
              // left: 0,
              // right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(),
                  Container(
                    decoration: BoxDecoration(
                        color: MyTheme.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                    width: _screen_width,
                    height: MediaQuery.of(context).size.height / 2.01,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /* Padding(
                      padding: const EdgeInsets.only(top: 40.0, bottom: 15),
                      child: Container(
                        width: 75,
                        height: 75,
                        child:
                            Image.asset('assets/login_registration_form_logo.png'),
                      ),
                    ),*/
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0, top: 20),
                          child: Text(
                            "Enter OTP Code",
                            /*  + (_verify_by == "email"
                                ? AppLocalizations.of(context)!.email_account_ucf
                                : AppLocalizations.of(context)!.phone_number_ucf),*/
                            style: TextStyle(
                                color: MyTheme.primary_color,
                                fontSize: 25,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        /* Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                          width: _screen_width * (3 / 4),
                          child: _verify_by == "email"
                              ? Text(
                              AppLocalizations.of(context)!.enter_the_verification_code_that_sent_to_your_email_recently,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: MyTheme.dark_grey, fontSize: 14))
                              : Text(
                              AppLocalizations.of(context)!.enter_the_verification_code_that_sent_to_your_phone_recently,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: MyTheme.dark_grey, fontSize: 14))),
                    ),*/
                        SizedBox(height: 20),
                        Container(
                          width: _screen_width * (3 / 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Padding(
                              //   padding: const EdgeInsets.only(bottom: 8.0),
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.end,
                              //     children: [
                              //       Container(
                              //         height: 36,
                              //         child: TextField(
                              //           controller: _verificationCodeController,
                              //           autofocus: false,
                              //           decoration:
                              //               InputDecorations.buildInputDecoration_otp(
                              //                   hint_text: "A X B 4 J H"),
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              Center(
                                child: OTPTextField(
                                  controller: _verificationController,
                                  length:
                                      6, // Change this to 6 for a 6-digit OTP
                                  width: MediaQuery.of(context).size.width,
                                  textFieldAlignment:
                                      MainAxisAlignment.spaceAround,
                                  otpFieldStyle: OtpFieldStyle(
                                    backgroundColor: Color(0xffC3FF77),
                                  ),
                                  fieldWidth: 40,
                                  fieldStyle: FieldStyle.box,
                                  outlineBorderRadius: 10,
                                  style: TextStyle(fontSize: 17),
                                  onChanged: (pin) {
                                    setState(() {
                                      otp = pin.split('');
                                    });
                                    print("Changed: " + pin);
                                  },
                                  onCompleted: (pin) {
                                    print("Completed: " + pin);
                                  },
                                ),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              //     children: <Widget>[
                              //       otpBoxBuilder(  _verificationCodeController, context),
                              //       SizedBox(width: 3,),
                              //       otpBoxBuilder(_verificationCodeController, context),
                              //       SizedBox(width: 3,),
                              //       otpBoxBuilder(_verificationCodeController, context),
                              //     ],
                              //   ),
                              // ),
                              SizedBox(height: 80),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 40.0),
                                  child: Container(
                                    height: 50,
                                    width: 150,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: MyTheme.textfield_grey,
                                            width: 1),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(12.0))),
                                    child: Btn.basic(
                                      minWidth:
                                          MediaQuery.of(context).size.width,
                                      color: MyTheme.accent_color,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(12.0))),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .confirm_ucf,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            letterSpacing: .5,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins'),
                                      ),
                                      onPressed: () {
                                        onPressConfirm();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        /*  Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: InkWell(
                        onTap: (){
                          onTapResend();
                        },
                        child: Text(AppLocalizations.of(context)!.resend_code_ucf,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: MyTheme.accent_color,
                                decoration: TextDecoration.underline,
                                fontSize: 13)),
                      ),
                    ),*/
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget otpBoxBuilder(_controller, index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xffC3FF77),
      ),
      width: 50, // Adjust the width to accommodate 6 digits
      height: 50,
      child: TextFormField(
        controller: _controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [LengthLimitingTextInputFormatter(1)],
        decoration: InputDecoration(
          border: InputBorder.none,
          disabledBorder: InputBorder.none,
          counterText: '',
          hintStyle: TextStyle(color: Colors.black, fontSize: 20.0),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
          otp[index] = value; // Update the corresponding index in the otp list
        },
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:plant_collector/formats/colors.dart';
import 'package:plant_collector/formats/text.dart';
import 'package:plant_collector/screens/login/widgets/login_template.dart';
import 'package:plant_collector/widgets/stateful_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:plant_collector/screens/login/widgets/input_card.dart';
import 'package:plant_collector/models/user.dart';
import 'package:plant_collector/screens/login/widgets/button_auth.dart';
import 'package:plant_collector/widgets/dialogs/dialog_confirm.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StatefulWrapper(
      onInit: () {
        Provider.of<UserAuth>(context).signInAttempts = 0;
      },
      child: LoginTemplate(
        leadingGraphic: FlareActor('assets/animations/grow_border.flr',
            alignment: Alignment.center,
            fit: BoxFit.contain,
            animation: "Grow"),
        children: <Widget>[
          InputCard(
            keyboardType: TextInputType.emailAddress,
            cardPrompt: 'User Email',
            onChanged: (input) {
              Provider.of<UserAuth>(context).email = input;
            },
            validator: (input) {
              String response;
              if (Provider.of<UserAuth>(context).email.contains('@')) {
                response = 'Please double check your email';
              }
              return response;
            },
          ),
          Consumer<UserAuth>(builder: (context, userAuth, child) {
            return userAuth.showPasswordReset == true
                ? FlatButton(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 20.0,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            width: 2.0,
                            color: kGreenDark,
                          )),
                      child: Text(
                        'Email Password Reset?',
                        style: TextStyle(
                          color: AppTextColor.black,
                          fontSize: AppTextSize.medium *
                              MediaQuery.of(context).size.width,
                        ),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return DialogConfirm(
                            title: 'Password Reset',
                            text: 'Send an email to reset your password?',
                            buttonText: 'Yes',
                            onPressed: () {
                              Provider.of<UserAuth>(context)
                                  .sendPasswordReset();
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                  )
                : Container();
          }),
          InputCard(
            keyboardType: TextInputType.text,
            cardPrompt: 'Password',
            obscureText: true,
            onChanged: (input) {
              Provider.of<UserAuth>(context).password = input;
            },
          ),
          SizedBox(
            height: 10.0,
          ),
          ButtonAuth(
            text: 'Log In',
            onPress: () async {
              //log user in
              FirebaseUser user =
                  (await Provider.of<UserAuth>(context).loginUser());
              //check if verified
              bool verified =
                  Provider.of<UserAuth>(context).userIsVerified(user: user);
              //if user is logged in and verified
              if (user != null && verified == true) {
                //have to sent to loading first to then sent to route and initiate first stream
                Navigator.pushNamed(context, 'loading');
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DialogConfirm(
                      title: 'Sign in Issue',
                      text:
                          'We had trouble signing you in. Please make sure your email and password are correct.'
                          '\n\nIf you recently registered, please respond to the email we sent you.',
                      buttonText: 'OK',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              }
            },
          ),
//          GoogleAuthButton(
//              text: 'oogle Sign in',
//              onPress: () async {
//                //login the user with GOOGLE
//                FirebaseUser user =
//                    await Provider.of<UserAuth>(context).signInWithGoogle();
//                //check if verified
//                bool verified =
//                    Provider.of<UserAuth>(context).userIsVerified(user: user);
//                //if user is logged in and verified
//                if (user != null && verified == true) {
//                  //have to sent to loading first to then sent to route and initiate first stream
//                  Navigator.pushNamed(context, 'loading');
//                } else {
//                  showDialog(
//                    context: context,
//                    builder: (BuildContext context) {
//                      return DialogConfirm(
//                        title: 'Sign in Issue',
//                        text: 'We had trouble signing you in. Please try again.'
//                            '\n\nIf you recently registered, please respond to the email we sent you.',
//                        buttonText: 'OK',
//                        onPressed: () {
//                          Navigator.pop(context);
//                        },
//                      );
//                    },
//                  );
//                }
//              }),
          SizedBox(
            height: 10.0,
          ),
          Text(
            'OR',
            style: TextStyle(
              fontSize: AppTextSize.small * MediaQuery.of(context).size.width,
              color: kGreenDark,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          ButtonAuth(
              text: 'Start Here',
              textSize: AppTextSize.large,
              showImage: false,
              onPress: () {
                Navigator.pushNamed(context, 'register');
              }),
//          Padding(
//            padding: EdgeInsets.all(10.0),
//            child: FlatButton(
//              child: Text(
//                'Register a new account',
//                style: TextStyle(
//                  color: kGreenDark,
//                  fontSize:
//                      AppTextSize.small * MediaQuery.of(context).size.width,
//                  fontWeight: AppTextWeight.medium,
//                ),
//              ),
//              onPressed: () {
//                Navigator.pushNamed(context, 'register');
//              },
//            ),
//          ),
        ],
      ),
    );
  }
}

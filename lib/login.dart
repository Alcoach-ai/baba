import 'package:baba_bloc/features/customers/presentaion/pages/users_page.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String phone = '';
  String password = '';
  bool ischecked = false;
  bool bb = false;

  void moveToMainPage() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return UsersPage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: const Color.fromRGBO(223, 234, 254, 1),
        //   automaticallyImplyLeading: false,
        //   title: Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       IconButton(
        //         onPressed: () => Navigator,
        //         icon: const Icon(Icons.arrow_back,
        //             color: Color.fromRGBO(6, 25, 197, 1)),
        //       ),
        //       const Text(
        //         'Back',
        //         style: TextStyle(color: Color.fromRGBO(6, 25, 197, 1)),
        //       ),
        //     ],
        //   ),
        //   actions: [
        //     TextButton(
        //       child: Image.asset('images/menu_icon.png'),
        //       onPressed: () => Navigator,
        //       // icon: const Icon(Icons.arrow_back, color: Colors.white),
        //     ),
        //   ],
        // ),
        body: SingleChildScrollView(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(top: 80, bottom: 30),
          child: Image(
            image: AssetImage('assets/lo.png'),
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
          ),
        ),
        // const Padding(
        //   padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
        //   child: Text(
        //     'Hi! Login your account to  get a wonderful features',
        //     textAlign: TextAlign.center,
        //     style: TextStyle(
        //       fontSize: 16.0,
        //       fontWeight: FontWeight.w500,
        //     ),
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30.0,
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromRGBO(222, 232, 245, 1), width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromRGBO(222, 232, 245, 1), width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromRGBO(58, 138, 241, 1), width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                hintStyle: TextStyle(
                    fontSize: 15.0, color: Color.fromRGBO(199, 200, 201, 1)),
                hintText: 'ادخل رقم الجوال',
              ),
              onChanged: (v) {
                setState(() {
                  phone = v;
                });
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              // obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                // suffixIcon: Icon(Icons.remove_red_eye,
                //     color: Color.fromRGBO(222, 232, 245, 1)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromRGBO(222, 232, 245, 1), width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromRGBO(222, 232, 245, 1), width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromRGBO(58, 138, 241, 1), width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),

                hintStyle: TextStyle(
                    fontSize: 15.0, color: Color.fromRGBO(199, 200, 201, 1)),
                hintText: 'ادخل كلمة المرور',
              ),
              onChanged: (v) {
                setState(() {
                  password = v;
                });
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              // padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              backgroundColor: Colors.blue,
            ),
            onPressed: () {
              if (bb) {
                null;
              } else {
                bb = true;
                comp();
              }
              // comp();
            },
            child: const Text(
              'ادخل',
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            ),
          ),
        ),
        Image.asset('assets/giff.gif')
      ]),
    ));
  }

  void comp() {
    setState(() {
      ischecked = true;
    });

    if (phone == '555' && password == '') {
      moveToMainPage();
    } else {
      setState(() {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Column(
                    children: [
                      Text('هناك خطأ بالمعلومات المدخلة'),
                      Text(
                        'تأكد من معلوماتك',
                        style: TextStyle(color: Colors.blue),
                      )
                    ],
                  ),
                ));
        bb = false;
      });
    }
  }
}

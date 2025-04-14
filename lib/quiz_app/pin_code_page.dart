import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:realtime_quiz_app/main.dart';

class PinCodePage extends StatefulWidget {
  const PinCodePage({super.key});

  @override
  State<PinCodePage> createState() => _PinCodePageState();
}

class _PinCodePageState extends State<PinCodePage> {
  String? uid;
  String? nickName;
  String? pinCode;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  signInAnonymously() async {
    final signUser = await _auth.signInAnonymously();
    uid = signUser.user!.uid;
  }

  List codeItmes = [];

  Future<bool> findPinCode(String code) async {
    final quizRef = database?.ref('quiz');
    final result = await quizRef?.get();

    codeItmes.clear();
    for (var element in result!.children) {
      final data =
          jsonDecode(jsonEncode(element.value)) as Map<String, dynamic>;

      DateTime dateTimeNow = DateTime.now();
      DateTime generateTime = DateTime.parse(data['generateTime']);

      //(dateTimeNow.millisecondsSinceEpoch < generateTime.add(const Duration(days: 1)).millisecondsSinceEpoch)
      if (dateTimeNow.difference(generateTime).inDays < 1) {
        if (data.containsValue(code)) {
          codeItmes.add(data['quizDetailRef']);
        }
      }
    }

    return codeItmes.isEmpty ? false : true;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    signInAnonymously();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('입장 코드 입력')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Pin Code',
                    labelText: 'Pin Code',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pin Code 입력하세요.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    pinCode = value;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Nick Name',
                    labelText: 'Nick Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nick Name 입력하세요.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    nickName = value;
                  },
                ),
                const SizedBox(height: 20),
                MaterialButton(
                  height: 60,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!
                          .save(); //validate()에서 데이터 있는거 확인했으니 save 바로 진행.
                      debugPrint('$nickName,$pinCode');
                      findPinCode(pinCode!);
                      //findPinCode('540500');

                      final result = await findPinCode(pinCode!);
                      if (!context.mounted) return;
                      if (result) {
                        debugPrint('연결됨');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pin Code가 일치하지 않습니다.')),
                        );
                      }
                    }
                  },
                  color: Colors.indigo,
                  child: const Text(
                    '입장하기',
                    style: TextStyle(
                      color: Colors.white,
                      //fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';


class AddUrlPage extends StatefulWidget {
  const AddUrlPage({Key? key}) : super(key: key);

  @override
  State<AddUrlPage> createState() => _AddUrlPageState();
}

class _AddUrlPageState extends State<AddUrlPage> {
  TextEditingController urlcontroller = new TextEditingController();



  Widget UrlInputWidget(){return TextField(
      obscureText: false,
      controller: urlcontroller,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'url',
      ));}
  Widget EkleUrlButton(){
    return OutlinedButton(
      onPressed: () async {
        debugPrint('Received click ${urlcontroller.text}');
    },
      child: const Text('Url Ekle'),
    );
  }
  Widget ShowUrls(){
    return TextButton(
      onPressed: () {print('show urls');
      },
      child: Text('Print Storage'),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Center(child: Column(children: [UrlInputWidget(),EkleUrlButton(),ShowUrls()]),);
  }
}

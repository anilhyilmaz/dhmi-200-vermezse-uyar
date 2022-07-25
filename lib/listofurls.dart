import 'package:flutter/material.dart';
import 'package:dhmigov/addurlpage.dart';

class listofurls extends StatefulWidget {
  const listofurls({Key? key}) : super(key: key);

  @override
  State<listofurls> createState() => _listofurlsState();
}


class _listofurlsState extends State<listofurls> {

  @override
  Widget build(BuildContext context) {
    return Container(child: Text("url lists"));
  }
}

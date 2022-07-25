import 'package:dhmigov/urldbhelper.dart';
import 'package:flutter/material.dart';
import 'package:dhmigov/addurlpage.dart';
import 'url.dart';

class listofurls extends StatefulWidget {
  const listofurls({Key? key}) : super(key: key);

  @override
  State<listofurls> createState() => _listofurlsState();
}


class _listofurlsState extends State<listofurls> {
  final DbHelper = DatabaseHelper.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Container(child: Text("url lists"));
  }
}

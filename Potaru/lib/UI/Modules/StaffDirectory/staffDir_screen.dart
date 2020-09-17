import 'package:flutter/material.dart';
import 'package:dropdown_menu/dropdown_menu.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

import 'package:potaru/UI/utils/errorMsg.dart';
import 'package:potaru/UI/Modules/StaffDirectory/staff_screen.dart';
import 'package:potaru/UI/Modules/StaffDirectory/utils/staffImgRetrieve.dart';
import 'package:potaru/Controller/faculty.controller.dart';
import 'package:potaru/Controller/staff.controller.dart';
import 'package:potaru/UI/utils/customeRoute.dart';
import 'package:potaru/Model/staff.model.dart';

class StaffDirScreen extends StatefulWidget {
  const StaffDirScreen({Key key, this.animationController}) : super(key: key);

  final AnimationController animationController;
  @override
  _StaffDirScreenState createState() => _StaffDirScreenState();
}

class _StaffDirScreenState extends State<StaffDirScreen> {
  FacultyController facultyController = FacultyController();
  List<Map<String, String>> faculty = [];
  int facultyINDEX = 0;

  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;

  StaffController staffController = StaffController();
  List<Staff> staff = [];
  List<Staff> _searchStaffFac = [];
  List _searchStaffID = [];
  List<Staff> _searchStaffName = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<Map<String, String>>> getData() async {
    faculty = faculty.length == 0
        ? await facultyController.getFacultyList()
        : faculty;
    staff = staff.length == 0 ? await staffController.getStaffList() : staff;
    return faculty;
  }

  DropdownHeader buildDropdownHeader({DropdownMenuHeadTapCallback onTap}) {
    return DropdownHeader(onTap: onTap, titles: [faculty[facultyINDEX]]);
  }

  DropdownMenu buildDropdownMenu() {
    return DropdownMenu(maxMenuHeight: kDropdownMenuItemHeight * 6, menus: [
      DropdownMenuBuilder(
          builder: (BuildContext context) {
            return DropdownListMenu(
                selectedIndex: facultyINDEX,
                data: faculty,
                itemBuilder:
                    (BuildContext context, dynamic data, bool selected) {
                  if (!selected) {
                    return DecoratedBox(
                        decoration: BoxDecoration(
                            border: Border(
                                right: Divider.createBorderSide(context))),
                        child: Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Row(
                              children: <Widget>[
                                Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.90,
                                    child: Text(data['title'])),
                              ],
                            )));
                  } else {
                    return DecoratedBox(
                        decoration: BoxDecoration(
                            border: Border(
                                top: Divider.createBorderSide(context),
                                bottom: Divider.createBorderSide(context))),
                        child: Container(
                            color: Colors.blue[50],
                            child: Row(
                              children: <Widget>[
                                Container(
                                    color: Theme.of(context).primaryColor,
                                    width: 3.0,
                                    height: 20.0),
                                Padding(
                                    padding: EdgeInsets.only(left: 12.0),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.90,
                                        child: Text(data['title']))),
                              ],
                            )));
                  }
                });
          },
          height: kDropdownMenuItemHeight * faculty.length),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color(0xFFF2F3F8),
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(50.0),
                child: Stack(children: <Widget>[
                  Transform(
                    transform: Matrix4.translationValues(0.0, 0.0, 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  AppBar(
                    centerTitle: true,
                    actions: _buildActions(),
                    iconTheme: IconThemeData(
                      color: Color(0xFF17262A), //change your color here
                    ),
                    brightness: Brightness.light,
                    backgroundColor: Colors.white,
                    elevation: 0.0,
                    leading: IconButton(
                      icon: Icon(
                        Icons.home,
                        size: 22,
                      ),
                      color: Color(0xFF17262A),
                      onPressed: () => Navigator.of(context)
                          .pushNamedAndRemoveUntil(
                              '/homeUI', (Route<dynamic> route) => false),
                    ),
                    title: _isSearching
                        ? _buildSearchField()
                        : Text(
                            'Staff Directory',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              letterSpacing: 1.2,
                              color: Color(0xFF17262A),
                            ),
                          ),
                  )
                ])),
            backgroundColor: Colors.transparent,
            body: KeyboardDismissOnTap(
                child: FutureBuilder<List>(
                    future: getData(),
                    builder:
                        (BuildContext context, AsyncSnapshot<List> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          //print(snapshot.error);
                          return const SizedBox();
                        } else if (faculty.length == 0 || staff.length == 0) {
                          ErrorMsg.staffNotFoundMsg();
                          return const SizedBox();
                        } else {
                          return DefaultDropdownMenuController(
                              onSelected: (
                                  {int menuIndex,
                                  int index,
                                  int subIndex,
                                  dynamic data}) {
                                setState(() {
                                  facultyINDEX = index;
                                  onSearchFacultyChanged(data['code']);
                                });
                              },
                              child: Stack(
                                children: <Widget>[
                                  Transform(
                                      transform: Matrix4.translationValues(
                                          0.0, 35, 0.0),
                                      child: _searchStaffName.length != 0 ||
                                              _searchQueryController
                                                  .text.isNotEmpty
                                          ? _buildStaffList(_searchStaffName)
                                          : _searchStaffFac.length != 0
                                              ? _buildStaffList(_searchStaffFac)
                                              : _buildStaffList(staff)),
                                  Transform(
                                      transform: Matrix4.translationValues(
                                          0.0, 35, 0.0),
                                      child: buildDropdownMenu()),
                                  Transform(
                                    transform: Matrix4.translationValues(
                                        0.0, -15.0, 0.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(32.0),
                                        ),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color: Colors.grey,
                                              offset: const Offset(1.1, 1.1),
                                              blurRadius: 10.0),
                                        ],
                                      ),
                                      child: buildDropdownHeader(),
                                    ),
                                  ),
                                ],
                              ));
                        }
                      } else {
                        return Center(
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                              SizedBox(
                                  width: 35,
                                  height: 35,
                                  child: CircularProgressIndicator())
                            ]));
                      }
                    }))));
  }

  Widget _buildStaffList(List<Staff> staffData) {
    return ListView.builder(
        padding: EdgeInsets.only(bottom: 100),
        physics: BouncingScrollPhysics(),
        itemCount: staffData.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return Card(
              color: Colors.white,
              elevation: 1.0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).backgroundColor,
                    child: ImgRetrieve.imgCircle(staffData[index].sid),
                  ),
                  title: Text(
                    staffData[index].name,
                    style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                  ),
                  subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          staffData[index].designation,
                          style: TextStyle(fontSize: ScreenUtil().setSp(38)),
                        ),
                        staffData[index].email != ""
                            ? Text(staffData[index].email)
                            : SizedBox(),
                        staffData[index].telNo2 != ""
                            ? Text(
                                staffData[index].telNo2,
                                style:
                                    TextStyle(fontSize: ScreenUtil().setSp(38)),
                              )
                            : SizedBox(),
                        staffData[index].telNo1 != ""
                            ? Text(
                                staffData[index].telNo1,
                                style:
                                    TextStyle(fontSize: ScreenUtil().setSp(38)),
                              )
                            : SizedBox(),
                        staffData[index].roomNo != ""
                            ? Text(
                                staffData[index].roomNo,
                                style:
                                    TextStyle(fontSize: ScreenUtil().setSp(38)),
                              )
                            : SizedBox()
                      ]),
                  onTap: () {
                    navigateToDetail(staffData[index], 'Staff Info');
                  },
                ),
              ));
        });
  }

  onSearchFacultyChanged(String facultyCode) async {
    _clearSearchQuery();
    _searchStaffName.clear();
    _searchStaffFac.clear();
    if (facultyCode == "ALL") {
      setState(() {});
      return;
    }

    staff.forEach((userDetail) {
      if (userDetail.facultyCode.contains(facultyCode))
        _searchStaffFac.add(userDetail);
    });

    setState(() {});
  }

  void navigateToDetail(Staff staff, String name) {
    _isSearching = false;
    Navigator.push(
        context,
        MyCustomRoute(StaffScreen(
            animationController: widget.animationController,
            staff: staff,
            appBarTitle: name)));
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search Name...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey),
      ),
      style:
          TextStyle(color: Color(0xFF17262A), fontSize: ScreenUtil().setSp(40)),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
        color: Color(0xFF17262A),
      ),
    ];
  }

  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void updateSearchQuery(String name) {
    _searchStaffID.clear();
    _searchStaffName.clear();
    if (name.isEmpty) {
      setState(() {});
      return;
    }
    if (_searchStaffFac.length != 0) {
      _searchStaffFac.forEach((userDetail) {
        if (userDetail.name.toLowerCase().contains(name.toLowerCase())) {
          if (!_searchStaffID.contains(userDetail.sid)) {
            _searchStaffID.add(userDetail.sid);
            _searchStaffName.add(userDetail);
          }
        }
      });
    } else {
      staff.forEach((userDetail) {
        if (userDetail.name.toLowerCase().contains(name.toLowerCase())) {
          if (!_searchStaffID.contains(userDetail.sid)) {
            _searchStaffID.add(userDetail.sid);
            _searchStaffName.add(userDetail);
          }
        }
      });
    }

    setState(() {});
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
    });
  }
}

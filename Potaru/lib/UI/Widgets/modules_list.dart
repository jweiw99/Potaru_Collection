import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:potaru/UI/Widgets/module.model.dart';

class HomeModule extends StatefulWidget {
  const HomeModule(
      {Key key, this.animationController, this.animation, this.callBackIndex})
      : super(key: key);
  final Animation animation;
  final AnimationController animationController;
  final Function(ModuleIndex) callBackIndex;

  @override
  _HomeModule createState() => _HomeModule();
}

class _HomeModule extends State<HomeModule> {
  List<PageList> moduleList = PageList.moduleList;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: widget.animationController,
        builder: (BuildContext context, Widget child) {
          return FadeTransition(
              opacity: widget.animation,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - widget.animation.value), 0.0),
                child: Container(
                    margin: EdgeInsets.only(top: 0, left: 20, right: 20),
                    child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: moduleList.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4),
                        itemBuilder: (BuildContext context, int index) {
                          return inkwell(moduleList[index]);
                        })),
              ));
        });
  }

  Widget inkwell(PageList listData) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            navigationtoScreen(listData.index);
          },
          child: Image.asset(
            listData.imagePath,
            height: MediaQuery.of(context).size.width/8,
            width: MediaQuery.of(context).size.width/8,
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Flexible(
          child: Text(listData.labelName,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: ScreenUtil().setSp(37),
                  letterSpacing: 0.27,
                  color: Color(0xFF17262A))),
        ),
      ],
    );
  }

  Future<void> navigationtoScreen(ModuleIndex indexScreen) async {
    widget.callBackIndex(indexScreen);
  }
}

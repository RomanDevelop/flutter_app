import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:news_app/blocs/ads_bloc.dart';
import 'package:news_app/blocs/notification_bloc.dart';
import 'package:news_app/pages/categories.dart';
import 'package:news_app/pages/explore.dart';
import 'package:news_app/pages/profile.dart';
import 'package:news_app/pages/videos.dart';
import 'package:news_app/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _currentIndex = 0;
  PageController _pageController = PageController();

  List<IconData> iconList = [
    Feather.home,
    Feather.youtube,
    Feather.grid,
    Feather.user,
    Feather.user
  ];


  void onTabTapped(int index) {
    setState(() {
     _currentIndex = index;
     
    });
    _pageController.animateToPage(index,
      curve: Curves.easeIn,
      duration: Duration(milliseconds: 250));
   
  }


  _initServies ()async{
    Future.delayed(Duration(milliseconds: 0))
    .then((value) async{
      final adb = context.read<AdsBloc>();
      await NotificationService().initFirebasePushNotification(context)
      .then((value) => context.read<NotificationBloc>().checkPermission())
      .then((value) => adb.checkAdsEnable())
      .then((value)async{
        if(adb.interstitialAdEnabled == true || adb.bannerAdEnabled == true){
          adb.initiateAds();
        }
      });
    });
  }



 @override
  void initState() {
    super.initState();
    _initServies();
    
  }



  


  @override
  void dispose() {
    _pageController.dispose();
    //HiveService().closeBoxes();
    super.dispose();
  }



  Future _onWillPop () async{
    if(_currentIndex != 0){
      setState (()=> _currentIndex = 0);
      _pageController.animateToPage(0, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
    }else{
      await SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop', true);
    }
  }




  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        _onWillPop();
      },
      child: Scaffold(
        bottomNavigationBar: _bottomNavigationBar(),
        body: PageView(
          controller: _pageController,
          allowImplicitScrolling: false,
          physics: NeverScrollableScrollPhysics(),  
          children: <Widget>[
            Explore(),
            VideoArticles(),
            Categories(),
            ProfilePage()
          ],
        ),
      ),
    );
  }



  BottomNavigationBar _bottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      onTap: (index) => onTabTapped(index),
      currentIndex: _currentIndex,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      iconSize: 25,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(iconList[0]),
          label: 'home'.tr()

        ),
        BottomNavigationBarItem(
          icon: Icon(iconList[1]),
          label: 'videos'.tr()

        ),
        BottomNavigationBarItem(
          icon: Icon(iconList[2], size: 25,),
          label: 'categories'.tr()

        ),
        BottomNavigationBarItem(
          icon: Icon(iconList[3]),
          label: 'profile'.tr()

        )
      ],
    );
  }
}
import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newsupdate_newversion/CovidUpdate/CovidHome.dart';
import 'package:newsupdate_newversion/blocs/auth_bloc.dart';
import 'package:newsupdate_newversion/login.dart';
import 'package:newsupdate_newversion/theme.dart';
import 'package:provider/provider.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:newsupdate_newversion/countries.dart';
import 'package:http/http.dart'as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'drawercontent/AboutUs.dart';
var _defaultCountrycode='in';
var url;
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}
final TextEditingController Nickname= TextEditingController();
class _HomeState extends State<Home> with SingleTickerProviderStateMixin{
  StreamSubscription<User> loginStateSubscription;
  TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 74, vsync: this )..addListener(() {
      setState(() {

      });
    });
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    loginStateSubscription = authBloc.currentUser.listen((fbUser) {
      if (fbUser == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      }
    });
  }
  final Completer<WebViewController> _completer= Completer<WebViewController>();

  @override
  void dispose() {
    loginStateSubscription.cancel();
    super.dispose();
  }

  @override

  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    return SafeArea(
      child: new Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              iconTheme: IconThemeData(color: Colors.white),
              expandedHeight: 200.0,
              pinned: true,
              floating: false,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('NewsUpdate',style: TextStyle(color: Colors.white ,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),),
              background: Image.asset('assets/images/header.jpg',
              fit: BoxFit.cover,
              )
              ),
            ),
            SliverFillRemaining(
              child: FutureBuilder(
                future: http.get('http://newsapi.org/v2/top-headlines?country=$_defaultCountrycode&category=business&apiKey=50cd87a239064bb39c8d5c4343253080'),
                builder: (context,AsyncSnapshot newsData) => newsData.connectionState == ConnectionState.waiting ?
                Center(
                  child: CircularProgressIndicator(),
                )
                    : ListView.builder(

                  itemCount: json.decode(newsData.data.body)['articles'].length,
                  itemBuilder: (context,index) => Card(
                    borderOnForeground: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 20.0,

                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () {
                          url=json.decode(newsData.data.body)['articles'][index]['url'];
                          Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (context){

                            return Scaffold(
                                appBar: AppBar(
                                  leading: IconButton(icon: Icon(Icons.arrow_back,color: Colors.black,), onPressed: (){
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                                      return Home();
                                    }));
                                  }),
                                  backgroundColor: Colors.white,
                                  title: Text('news data',style: TextStyle(color: Colors.black),),
                                  centerTitle: true,
                                  actions: [
                                   Builder(
                                     builder:(context) => IconButton(icon: Icon(Icons.copy,color: Colors.black  ,),
                                     onPressed: () async{
                                       await FlutterClipboard.copy('This Url Link is from \'NewsUpdate App\' \n'
                                           ' To Download this App\n'
                                           '  Click the below Link and Download the app \n'
                                           '  http://newsupdate.freevar.com/newsupdate/app.apk \n'
                                           'You can download this on AmazonAppstore as well\n'
                                           '   Here is the news link!! \n'
                                           '${url.toString()}');
                                       Scaffold.of(context).showSnackBar(SnackBar(content: Text('Link is Copied'),));
                                     },
                                     ),
                                   ),
                                  ],
                                ),
                                body: WebView(
                                  initialUrl: url,
                                  javascriptMode: JavascriptMode.unrestricted,
                                  onWebViewCreated: ((WebViewController webViewController){
                                    setState(() {
                                      _completer.complete(webViewController);
                                    });
                                  }),
                                ),
                            );
                          }),);
                        },

                        child: Column(
                          children: [
                            Image.network(
                              json.decode(newsData.data.body)['articles'][index]
                              ['urlToImage'] ??
                                  "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/480px-No_image_available.svg.png",
                              loadingBuilder: (context , child, progress){
                                if(progress == null) return child;
                                return Container(
                                  height: 200,
                                  width: double.infinity,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        value: progress.expectedTotalBytes != null
                                            ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes
                                            : null,
                                    ),
                                  ),
                                );
                              },

                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(json.decode(newsData.data.body)['articles'][index]['title'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),),
                          ],
                        ),
                      ),
                    ),
                  ),

                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              StreamBuilder<User>(
                  stream: authBloc.currentUser,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    print(snapshot.data.photoURL);
                    return UserAccountsDrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        image: DecorationImage(image: AssetImage('assets/images/menuimage.jpg')
                          , fit: BoxFit.cover,
                        ),
                      ),
                      currentAccountPicture: CircleAvatar(
                        backgroundImage: NetworkImage(snapshot.data.photoURL.replaceFirst('s96','s400')),
                        radius: 60.0,
                      ),
                      accountName: Text('Menu',style: GoogleFonts.kanit(fontSize: 25.0,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),),
                      accountEmail: Text('NewsUpdate',style: GoogleFonts.kanit(fontSize: 20.0,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),),
                    );
                  }
              ),


              ListTile(
                title: Container(
                  margin: EdgeInsets.only(left: 20.0),
                  child: Consumer<ThemeNotifier>(
                    builder: (context,notifier,child) => SwitchListTile(
                      activeColor: Colors.white,
                      activeTrackColor: Colors.red,
                      inactiveThumbColor: Colors.black,
                      inactiveTrackColor: Colors.green,
                      onChanged: (val){
                        notifier.toggleTheme();
                      },
                      value: notifier.darkTheme ,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.locationArrow),
                title: Text('Location',style: GoogleFonts.kanit(fontSize: 25.0,),),
                onTap: () async{
                  var countrycode = await Navigator.push(context, MaterialPageRoute(builder: (context){
                    return Countries();
                  }));
                  if(countrycode.toString().isNotEmpty) {
                    setState(() {
                      _defaultCountrycode = countrycode;
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.virus),
                title: Text('CovidUpdate',style: GoogleFonts.kanit(fontSize: 25.0),),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return CovidHomepage();
                  }));
                },
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.addressCard),
                title: Text('AboutUs',style: GoogleFonts.kanit(fontSize: 25.0,),),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return Aboutus();
                  }));
                },
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.signOutAlt),
                title: Text('Logout',style: GoogleFonts.kanit(fontSize: 25.0,),),
                onTap: (){
                authBloc.logout();
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}


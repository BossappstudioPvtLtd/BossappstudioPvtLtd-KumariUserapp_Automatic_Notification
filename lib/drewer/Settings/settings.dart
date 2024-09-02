import 'package:app_settings/app_settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_app/components/m_buttons.dart';
import 'package:new_app/components/setting_listtile.dart';
import 'package:new_app/components/text_add.dart';
import 'package:new_app/navigatinbar/profile_edt.dart';
import 'package:new_app/themes/NewMethord/ui_Provider.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class LocalizationChecker {
  static Future<void> changeLanguage(
      BuildContext context, Locale newLocale) async {
    await context.setLocale(newLocale);
  }
}

class SettingsState extends State<Settings> {
  bool _switch = true;
  Locale _currentLocale = const Locale('en', 'US');

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentLocale = context.locale;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
     
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.blue,
            Color.fromARGB(255, 3, 6, 56),
          ],
        )),
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white70,
                  ),
                  Text(
                    'Settings'.tr(),
                    style: const TextStyle(
                      // fontSize: isSmallScreen ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
          
                  // IconButton(
                  //     onPressed: () {
                  //       Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (_) => const AdvertisementShow()));
                  //     },
                  //     icon: const Icon(Icons.remove_red_eye)),
                ],
              ),
               
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.person_outline,
                          
                      color: Colors.white70,
                      //Theme.of(context).colorScheme.onBackground,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Account".tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        //Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SettingListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrifileEdt(
                        name: '',
                        email: '',
                        phone: '',
                        photo: '',
                      ),
                    ),
                  );
                },
                text: "Edit Profile".tr(),
                leadingicon: Icons.edit_outlined,
                leadingiconcolor: Colors.teal,
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white
                ),
                text1: "App Settings".tr(),
                leadingiconcolor1: Colors.green,
                trailing1: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white
                ),
                onTap1: () {
                  AppSettings.openAppSettings();
                },
                leadingicon1: Icons.phonelink_setup,
              ),
              const SizedBox(
              
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.notifications_none,
                    color: Colors.white70
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Notification".tr(),
                      style: const TextStyle(
                        color: Colors.white70,
                        //Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 20),
                     child: Column(
                      children: <Widget>[
                        Card(
                          
                          color: Colors.transparent,
                          child: ListTile(
                            leading: const Icon(
                              Icons.notifications_active_outlined,
                              color: Colors.amber,
                            ),
                            title: Text(
                              "Notification".tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                
                          color: Colors.white,
                              ),
                            ),
                            trailing: Switch(
                              value: _switch,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              activeColor: Colors.green,
                              onChanged: (bool val) {
                                setState(() {
                                  _switch = val;
                                });
                              },
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Consumer<UiProvider>(
                              builder: (context, UiProvider notifier, child) {
                                return Icon(
                                  Icons.sunny,
                                  color: notifier.isDark
                                      ? Colors.grey
                                      : Colors.orange, // Change color based on theme
                                );
                              },
                            ),
                            title: const Text(
                              "Dark Mode",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                
                          color: Colors.white,
                              ),
                            ),
                            trailing: Consumer<UiProvider>(
                              builder: (context, UiProvider notifier, child) {
                                return Switch(
                                  value: notifier.isDark,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  activeColor: Colors.green,
                                  onChanged: (value) => notifier.changeTheme(),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                                       ),
                   ),
                
              
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.expand_more,
                      color: Colors.white70
                      //color: Theme.of(context).colorScheme.onBackground,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "More".tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        //Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SettingListTile(
                text: "Language".tr(),
                
                onTap: () {},
                leadingicon: Icons.language_outlined,
                leadingiconcolor: Colors.blue,
                trailing: DropdownButtonHideUnderline(
                  
                  child: DropdownButton<Locale>(
                    borderRadius: BorderRadius.circular(10),
                    dropdownColor: const Color.fromARGB(255, 5, 23, 39),
                    value: _currentLocale,
                    items: const [
                      DropdownMenuItem<Locale>(
                        value: Locale('en', 'US'),
                        child: Text('English',style: TextStyle(color: Colors.white),),
                      ),
                      DropdownMenuItem<Locale>(
                        value: Locale('ta', 'IN'),
                        child: Text('Tamil',style: TextStyle(color: Colors.white),),
                      ),
                      DropdownMenuItem<Locale>(
                        value: Locale('ml', 'IN'),
                        child: Text('Malayalam',style: TextStyle(color: Colors.white),),
                      ),
                    ],
                    onChanged: (Locale? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _currentLocale = newValue;
                          LocalizationChecker.changeLanguage(context, newValue);
                        });
                      }
                    },
                  ),
                ),
                text1: "Invite Friends".tr(),
                leadingiconcolor1: Colors.blueGrey,
                leadingicon1: Icons.person_add,
                trailing1: const Icon(
                  Icons.lock,
                  color: Colors.white
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 15),
              //   child: MaterialButtons(
              //     onTap: () {
              //       showCupertinoDialog(
              //         context: context,
              //         builder: (BuildContext context) {
              //           return AlertDialog(
              //             backgroundColor: Colors.black87,
              //             elevation: 20,
              //             title: TextEdt(
              //               text: 'Sign Out Your Account'.tr(),
              //               color: Colors.white,
              //               fontSize: null,
              //             ),
              //             content: TextEdt(
              //               text: 'Do you want to continue with sign out?'.tr(),
              //               fontSize: null,
              //               color: Colors.grey,
              //             ),
              //             actions: [
              //               Row(
              //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
              //                 children: [
              //                   MaterialButtons(
              //                     onTap: () {
              //                       Navigator.of(context).pop(false);
              //                     },
              //                     elevationsize: 20,
              //                     text: 'Cancel'.tr(),
              //                     fontSize: 17,
              //                     containerheight: 40,
              //                     containerwidth: 100,
              //                     borderRadius: const BorderRadius.all(
              //                       Radius.circular(10),
              //                     ),
              //                     onPressed: null,
              //                   ),
              //                   MaterialButtons(
              //                     onTap: () {
              //                       _signOut();
              //                       Navigator.of(context).pop();
              //                     },
              //                     elevationsize: 20,
              //                     text: 'Continue'.tr(),
              //                     fontSize: 17,
              //                     containerheight: 40,
              //                     containerwidth: 100,
              //                     borderRadius: const BorderRadius.all(
              //                       Radius.circular(10),
              //                     ),
              //                     onPressed: null,
              //                   ),
              //                 ],
              //               )
              //             ],
              //           );
              //         },
              //       );
              //     },
              //     containerheight: 40,
              //     borderRadius: BorderRadius.circular(10),
              //     meterialColor: Colors.black38,
              //     text: 'Sign Out'.tr(),
              //     textcolor: Colors.white,
              //     elevationsize: 20,
                  
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}

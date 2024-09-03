import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:new_app/components/card_list_tile.dart';
import 'package:new_app/drewer/HelpeCenter/fare.dart';
import 'package:new_app/drewer/HelpeCenter/guide_book.dart';
import 'package:new_app/drewer/HelpeCenter/safety_accident.dart';
import 'package:new_app/drewer/HelpeCenter/service.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {

  @override
  Widget build(BuildContext context) {
    
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
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
          
        
     child:   Column(
       children: [
        const SizedBox(height: 20,),
         Padding(
              padding: const EdgeInsets.all(1.0),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back,color: Colors.white70,)),
                  Text(
                    'Help Center'.tr(),
                    style: const TextStyle(
                     // fontSize: isSmallScreen ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),

                
                ],
              ),
            ),
         Padding(
           padding: const EdgeInsets.symmetric(horizontal: 20),
           child: Column(
         
                children: [
                 
        const SizedBox(height: 50,),
                  Center(
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Theme.of(context).colorScheme.onBackground,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Theme.of(context).colorScheme.onBackground,
                            backgroundImage:
                                const AssetImage("assets/logo/headphone.png"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Text('033 466 088',style:  TextStyle(color: Colors.white),),
                  const Text('cs@kumaricabs',style:  TextStyle(color: Colors.white),),
                  const SizedBox(
                    height: 30,
                  ),
                  CardListTILe(
                    title: "Guide to Book".tr(),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const GuideBook(
                                    text: '',
                                  )));
                    },
                  ),
                  CardListTILe(
                    title: "Services".tr(),
                    onTap: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (_) =>const Services()));
                    },
                  ),
                  CardListTILe(
                    title: "Fare Details".tr(),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const FareDetails()));
                    },
                  ),
                  CardListTILe(
                    title: "Safety and Accident".tr(),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SafetyAccident()));
                    },
                  ),
                ],
              ),
         ),
       ],
     ),
      ),
    );
  }
}

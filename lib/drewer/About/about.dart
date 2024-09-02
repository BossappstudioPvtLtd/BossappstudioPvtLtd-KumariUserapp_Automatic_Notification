import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:new_app/components/image_add.dart';
import 'package:new_app/components/text_add.dart';
import 'package:new_app/components/text_row.dart';
import 'package:new_app/drewer/About/webview.dart';

class About extends StatelessWidget {
  const About({super.key});

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
        child: ListView(
          
          children: [
             Row(
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
            const ImageAdd(image: "assets/images/cab2.png"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextEdt( text:"we’re more than just a transportation service; we’re your gateway to a smooth, safe, and comfortable journey. Our fleet of modern vehicles is equipped with the latest technology to ensure you reach your destination on time, every time.".tr(), fontSize: 12,color: Colors.white,),
                  const SizedBox( height: 20,),
                  TextEdt( text: "Our Mission To provide dependable, high-quality transportation solutions that cater to the diverse needs of our community. Whether it’s a rush to the airport, a tour of the city, or a daily commute, we’re here to make your travel experience seamless.".tr(),fontSize: 12,color: Colors.white,),
                  const SizedBox(height: 20,),
                  TextEdt(text:"Our Vision To be the leading cab service in the city, renowned for our commitment to excellence, customer satisfaction, and environmental sustainability. We strive to innovate and evolve, ensuring that every ride with us is a step towards a greener future.".tr(),fontSize: 12,color: Colors.white,),
                  const SizedBox( height: 20, ),
                  TextEdt(text: "Our Services".tr(), fontSize: 15,color: Colors.white,),
                  const SizedBox( height: 12, ),
                  TextRow( data:'24/7 Availability: Our cabs are available around the clock, ready to serve you at a moment’s notice.' .tr(),),
                  TextRow(data: 'Professional Drivers: Our drivers are experienced, knowledgeable, and dedicated to providing a friendly service'.tr(),),
                  TextRow(data:'Online Booking: Easily book your ride through our user-friendly app or website.'.tr(),),
                  TextRow( data:'Competitive Pricing: Enjoy transparent and fair pricing with no hidden fees.'.tr(),),
                  TextRow( data: 'Join the Ride Experience the difference with City Cabs. Book your next ride and let us take the wheel.'.tr(),),
                  const SizedBox( height: 20, ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const WebView()));
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Safe travels are just a click away!".tr(),
                        style: const TextStyle(
                            color:  Colors.white,
                            fontSize: 12),
                        children: const <TextSpan>[
                          TextSpan(
                              text: '  click More!',
                              style: TextStyle(color: Colors.blue, fontSize: 12,fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

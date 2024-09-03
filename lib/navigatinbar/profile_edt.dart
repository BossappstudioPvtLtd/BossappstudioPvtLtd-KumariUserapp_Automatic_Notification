import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_app/components/loading_dialog.dart';
import 'package:new_app/components/m_buttons.dart';
import 'package:easy_localization/easy_localization.dart';

class PrifileEdt extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String photo;

  const PrifileEdt({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.photo,
  });

  @override
  _PrifileEdtState createState() => _PrifileEdtState();
}

class _PrifileEdtState extends State<PrifileEdt> {
  final ImagePicker _picker = ImagePicker();
  User? user = FirebaseAuth.instance.currentUser;
  File? _image;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference databaseRef = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.name;
    _emailController.text = widget.email;
    _phoneController.text = widget.phone;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Registering your account"),
    );
    if (_image == null)
    {
       updateUserData(widget.photo);
    }else{
    String userId = _auth.currentUser!.uid;
    String fileName = 'user_photos/$userId';
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(fileName);
    UploadTask uploadTask = ref.putFile(_image!);
    await uploadTask.whenComplete(() async {
      String downloadURL = await ref.getDownloadURL();
      updateUserData(downloadURL);
    });
    }
  }
   Future<void> updateUserData(String photoUrl) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    Map<String, dynamic> usersData = {
      'name': _usernameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'photo': photoUrl,
     
    };

    await FirebaseDatabase.instance
        .reference()
        .child('users/$userId')
        .update(usersData);

    Navigator.pop(context);
    // Optionally, you can show a success message or navigate to another screen here
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text("Profile Editing".tr()),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
               GestureDetector(
  onTap: getImage,
  child: Material(
    borderRadius: BorderRadius.circular(40),
    elevation: 15,
    child: CircleAvatar(
      radius: 43,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 40,
        backgroundImage: _image != null
            ? FileImage(_image!) as ImageProvider
            : CachedNetworkImageProvider(widget.photo),
      ),
    ),
  ),
),
                Padding(
                  padding: const EdgeInsets.only(top: 60, left: 60),
                  child: InkWell(
                    onTap: getImage,
                    child: Material(
                      borderRadius: BorderRadius.circular(25),
                      color: const Color.fromARGB(235, 1, 72, 130),
                      child: const SizedBox(
                        height: 30,
                        width: 30,
                        child: Icon(Icons.add_a_photo_rounded,
                            size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 30,
              width: 300,
              child: Center(child: Text("Add Your Image".tr())),
            ),
            const SizedBox(height: 50),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Material(
                      color: Theme.of(context).colorScheme.background,
                      elevation: 10,
                      borderRadius: BorderRadius.circular(10.0),
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          labelText: 'Name'.tr(),
                          icon: const Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Icon(Icons.person),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Material(
                      color: Theme.of(context).colorScheme.background,
                      elevation: 10,
                      borderRadius: BorderRadius.circular(10.0),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          icon: const Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Icon(Icons.email_outlined),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          labelText: "Email".tr(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Material(
                      elevation: 10,
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(10.0),
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
                        controller: _phoneController,
                        decoration: InputDecoration(
                          icon: const Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Icon(Icons.phone_android_rounded),
                          ),
                          labelText: 'Phone'.tr(),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    MaterialButtons(
                      borderRadius: BorderRadius.circular(10),
                      meterialColor: const Color.fromARGB(255, 3, 22, 60),
                      containerheight: 50,
                      elevationsize: 20,
                      textcolor: Colors.white,
                      fontSize: 18,
                      textweight: FontWeight.bold,
                      text: "Submit".tr(),
                      onTap: () {
                        uploadFile();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

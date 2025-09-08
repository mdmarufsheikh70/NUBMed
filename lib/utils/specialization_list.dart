
import 'package:cloud_firestore/cloud_firestore.dart';

class Specialization{
  static List<String> doctor_specializaton=[];
  
  static Future<void> fetchSpecialization()async{
    final querySnapshot  = await FirebaseFirestore.instance.collection('specializations').get();
    doctor_specializaton = querySnapshot.docs.map((e){
      final data = e.data();
      return data['name'].toString();
    }).toList();
    doctor_specializaton.insert(0, "All");
}

}
import 'package:flutter/material.dart';

class Locationmodel  with ChangeNotifier{
  String _lat = '';
  String _lag = '';
  bool _status = false;
  String _message = '';

  //Getters 
  String get lat => _lat;
  String get lag => _lag;
  bool get status => _status;
  String get message => _message;

  //Setters
  void SetLocation({
    required String lat,
    required String lag,
    required bool status,
    required String message,
  }){
    _lat = lat;
    _lag = lag;
    _status = status;
    _message = message;
    notifyListeners();
  }

  //update lat and lag
  void Updatelatandlag( String lat , String lag, bool status, String message){
    _lat = lat;
    _lag = lag;
    _status = status;
    _message = message;
    notifyListeners();
  }
}
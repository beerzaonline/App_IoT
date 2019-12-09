import 'package:flutter/material.dart';
// import 'shared_prefs_helper.dart';
// import 'package:flutter/cupertino.dart';

class PreferencesSelectTime extends StatefulWidget {
    String _title;
    TimeOfDay _timeOfDay;
    Function _updateTimeFunction;

    PreferencesSelectTime(this._title, this._timeOfDay, this._updateTimeFunction);

    @override
    PreferencesSelectTimeState createState() => PreferencesSelectTimeState(_title, _timeOfDay, _updateTimeFunction);
}

class PreferencesSelectTimeState extends State<PreferencesSelectTime> {

    String _title;
    TimeOfDay _timeOfDay;
    Function _updateTimeFunction;
    PreferencesSelectTimeState(this._title, this._timeOfDay, this._updateTimeFunction);

    @override
    Widget build(BuildContext context) {
      

        return Scaffold(
            appBar: AppBar(
                title: Text(_title),
            ),
            body: FutureBuilder<TimeOfDay>(
                // future: SharedPreferencesHelper.getStartTime(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                        return Container(
                            height: MediaQuery.of(context).size.height / 4,
                                // child: CupertinoDatePicker(
                                //     mode: CupertinoDatePickerMode.time,
                                //     initialDateTime: DateTime(1969, 1, 1, _timeOfDay.hour, _timeOfDay.minute),
                                //     onDateTimeChanged: (DateTime newDateTime) {
                                //         var newTod = TimeOfDay.fromDateTime(newDateTime);
                                //         _updateTimeFunction(newTod);
                                //     },
                                //     use24hFormat: false,
                                //     minuteInterval: 1,
                                // )
                        );
                    } else {
                        return new CircularProgressIndicator();
                    }
                }
            )
        );
    }
}

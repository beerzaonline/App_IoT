List sw;
class tempSwitch {
  var _data;
  
  tempSwitch(var data) {
    this._data = data;
    sw.add(data);
    print(sw.length);
  }
}

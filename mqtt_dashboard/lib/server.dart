class server {
  
  String _broker;
  int _port;
  String _username;
  String _passwd;
  String _clientIdentifier = 'android';

  void set broker(String broker) {
    this._broker = broker;
  }

  String get broker {
    return this._broker;
  }
}

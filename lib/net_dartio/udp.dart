part of hetimanet_dartio;

class HetimaUdpSocketDartIo extends HetimaUdpSocket {
  static Random _random = new Random(new DateTime.now().millisecond);
  bool _verbose = false;
  bool get verbose => _verbose;
  RawDatagramSocket _udpSocket = null;
  HetimaUdpSocketDartIo({verbose: false}) {
    _verbose = verbose;
  }

  bool _isBindingNow = false;
  StreamController<HetimaReceiveUdpInfo> _receiveStream = new StreamController.broadcast();

  @override
  Future<HetimaBindResult> bind(String address, int port, {bool multicast: false}) async {
    if (_isBindingNow != false) {
      throw "now binding";
    }
    _isBindingNow = true;
    try {
      RawDatagramSocket socket = await RawDatagramSocket.bind(address, port, reuseAddress: true);
      _udpSocket = socket;
      socket.multicastLoopback = multicast;
      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.READ) {
          Datagram dg = socket.receive();
          if (dg != null) {
            log("read ${dg.address}:${dg.port} ${dg.data.length}");
            _receiveStream.add(new HetimaReceiveUdpInfo(dg.data, dg.address.address, dg.port));
          }
        }
      });
    } finally {
      _isBindingNow = false;
    }
    return new HetimaBindResult();
  }

  @override
  Future close() async {
    _udpSocket.close();
    return 0;
  }

  @override
  Stream<HetimaReceiveUdpInfo> get onReceive => _receiveStream.stream;

  @override
  Future<HetimaUdpSendInfo> send(List<int> buffer, String address, int port) async {
    try {
      try {
        IPConv.toRawIP(address);
      } catch (e) {
        List<InternetAddress> hosts = await InternetAddress.lookup(address);
        if (hosts == null || hosts.length == 0) {
          throw {"error": "not found ip from host ${address}"};
        }
        int n = 0;
        if (hosts.length > 1) {
          n = _random.nextInt(hosts.length - 1);
        }
        address = hosts[n].address;
      }
      _udpSocket.send(buffer, new InternetAddress(address), port);
      return await new HetimaUdpSendInfo(0);
    } catch (e) {
      throw e;
    }
  }

  log(String message) {
    if (_verbose) {
      print("d..${message}");
    }
  }
}

library hetimanet_stun;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:convert' as conv;
import 'dart:async';

import 'core.dart' as core;
import 'net.dart' as net;

part 'stun/attribute.dart';
part 'stun/attribute_address.dart';
part 'stun/attribute_changerequest.dart';
part 'stun/attribute_basic.dart';
part 'stun/attribute_errorcode.dart';
part 'stun/header.dart';
part 'stun/header_transactionid.dart';

class TurnClient {}

// stun.l.google.com:19302
// https://tools.ietf.org/html/rfc5389
// https://tools.ietf.org/html/rfc3489
// 3478
// 5349
//stun   3478/tcp   Session Traversal Utilities for NAT (STUN) port
//  stun   3478/udp   Session Traversal Utilities for NAT (STUN

//Full Cone
//Restricted Cone
//Port Restricted Cone
//Symmetric

class StunClient {
  net.TetSocketBuilder builder;
  String address;
  int port;
  String stunServer;
  int stunServerPort;

  Map<StunTransactionID, Completer<StunHeader>> cash = {};
  net.TetUdpSocket _udp = null;

  StunClient(this.builder, this.stunServer, this.stunServerPort, {this.address: "0.0.0.0", this.port: 0}) {
    ;
  }

  Future prepare() async {
    net.TetUdpSocket u = builder.createUdpClient();
    await u.bind(address, port);
    _udp = u;
    _udp.onReceive.listen((net.TetReceiveUdpInfo info) {
      print("## --------- receive packet ##");
      print("## ${info.data}");
      print("## ${info.remoteAddress}");
      print("## ${info.remotePort}");
      print("## --------- ##");
      StunHeader header = StunHeader.decode(info.data, 0);
      print("${header.toString()}");
      print("## --------- ##");
      if (cash.containsKey(header.transactionID)) {
        cash.remove(header.transactionID).complete(header);
      }
    });
  }

  Duration _defaultTimeout = new Duration(seconds: 5);
  Future<StunHeader> sendHeader(StunHeader header, {Duration timeout}) async {
    if (timeout == null) {
      timeout = _defaultTimeout;
    }
    if (cash.containsKey(header.transactionID)) {
      header.transactionID = new StunTransactionID.random();
    }
    cash[header.transactionID] = new Completer();
    _udp.send(header.encode(), stunServer, stunServerPort);
    cash[header.transactionID].future.timeout(timeout, onTimeout: () {
      cash.remove(header.transactionID).completeError({"mes":"timeout"});
    });
    return cash[header.transactionID].future;
  }

  Future test001() async {
    StunHeader header = new StunHeader(StunHeader.bindingRequest);
    header.attributes.add(new StunChangeRequestAttribute(false, false));
    StunHeader response = await sendHeader(header);
    StunAddressAttribute mappedAddress = response.getAttribute([StunAttribute.mappedAddress]);
    StunAddressAttribute changedAddress = response.getAttribute([StunAttribute.changedAddress]);
    StunAddressAttribute sourceAddress = response.getAttribute([StunAttribute.sourceAddress]);
    StunErrorCodeAttribute errorCode = response.getAttribute([StunAttribute.errorCode]);
    //
    if(errorCode != null) {
      print("# error 01 # ${response}");
      return ;
    }

    if(mappedAddress == null){// || changedAddress == null) {
      print("# error 02 # ${response}");
      return;
    }
    print("# ok 03 # ${response}");
    //print("# mapped address # ${mappedAddress.address} ${mappedAddress.port}");
    //print("# changed address # ${changedAddress.address} ${changedAddress.port}");
    //print("# changed address # ${sourceAddress.address} ${sourceAddress.port}");
  }

  Future test002() async {
    ;
  }

  Future test003() async {
    ;
  }
}

/*





class StunMappedAddress {
  var zeros; //1byte
  var family; // 0x01:ipv4 0x02:ipv6
  var port; //
  var address; //4byte or 8byte
}

//class StunUserName {}

class StunMessageIntegrity {}

class StunFingerPrint {}

//class StunErrorCode {}

class StunXorMappedAddress {
  var xxxx; //1byte
  var family; //
  var xPort; //
  var xAddress;
}

class StunMessage {
  // 20 byte header
  var zeroes; // message first 2bits be zero
  var messageType; // 2
  var messagelength; // 2
  var magicCookie; // 4 byte magic value
  var transactionId; // 96bit uniformaly value 12 byte

  // 2type request / response and 4 message
  //
  // M0-M11 and C0-C1
  var resuest = [0x0b, 0x00];
  var indication = [0x0b, 0x01];
  var successResponse = [0x0b, 0x10];
  var errorResponse = [0x0b, 0x11];
  //
  var exBindingRequest = [0x0b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01];
  //
  var coolieFixedValue = [0x21, 0x12, 0xA4, 0x42]; //network byte order (big)127.0.0.1-->  0x7f000001;

}
*/

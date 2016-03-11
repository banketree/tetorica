part of hetimanet_stun;

class StunClientBasicTestResult {
  List<StunNatType> possibility = [];
  List<net.IPAddr> addr = [];
  StunClientBasicTestResult(this.possibility, this.addr) {}
}

class StunClientBasicTest {
  StunClient client;
  StunClientBasicTest(this.client) {
    ;
  }

  Future prepare() async {
    return await client.prepare();
  }

  Future<List<StunNatType>> testBasic(List<net.IPAddr> ipList) async {
    StunClientSendHeaderResult test1Result = null;
    StunClientSendHeaderResult test2Result = null;
    StunClientSendHeaderResult test3Result = null;
    //
    // test 001
    try {
      test1Result = await test001();
      if (false == test1Result.passed()) {
        return [StunNatType.stunServerThrowError];
      }
      if (false == test1Result.header.haveOtherAddress()) {
        if (ipList.contains(new net.IPAddr.fromString(test1Result.remoteAddress))) {
          return [StunNatType.openInternet, StunNatType.symmetricUdpFirewall];
        } else {
          return [StunNatType.fullConeNat, StunNatType.symmetricNat, StunNatType.restricted, StunNatType.portRestricted];
        }
      }
    } catch (e) {
      // test1 is no response
      return [StunNatType.blockUdp];
    }

    //
    // test 002
    try {
      test2Result = await test002();
      if (ipList.contains(new net.IPAddr.fromString(test1Result.remoteAddress))) {
        if (test2Result.passed()) {
          return [StunNatType.openInternet];
        } else {
          return [StunNatType.openInternet, StunNatType.fullConeNat];
        }
      } else {
        if (test2Result.passed()) {
          return [StunNatType.fullConeNat];
        } else {
          return [StunNatType.fullConeNat, StunNatType.symmetricNat, StunNatType.restricted, StunNatType.portRestricted];
        }
      }
    } catch (e) {
      if (ipList.contains(new net.IPAddr.fromString(test1Result.remoteAddress))) {
        return [StunNatType.symmetricUdpFirewall];
      }
    }

    //
    // retest1
    return [StunNatType.restricted, StunNatType.portRestricted];
  }

  Future<StunClientSendHeaderResult> test001({StunRfcVersion version: StunRfcVersion.ref3489}) async {
    StunHeader header = new StunHeader(StunHeader.bindingRequest, version: version);
    if (version == StunRfcVersion.ref3489) {
      header.attributes.add(new StunChangeRequestAttribute(false, false));
    }
    return await client.sendHeader(header);
  }

  Future<StunClientSendHeaderResult> test002({StunRfcVersion version: StunRfcVersion.ref3489}) async {
    StunHeader header = new StunHeader(StunHeader.bindingRequest, version: version);
    header.attributes.add(new StunChangeRequestAttribute(true, true));
    return await client.sendHeader(header);
  }

  Future test003({StunRfcVersion version: StunRfcVersion.ref3489}) async {
    StunHeader header = new StunHeader(StunHeader.bindingRequest, version: version);
    header.attributes.add(new StunChangeRequestAttribute(false, true));
    return await client.sendHeader(header);
  }
}
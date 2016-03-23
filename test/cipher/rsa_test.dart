import 'package:tetorica/cipher/bigint.dart';
import 'package:tetorica/cipher/rsa.dart';
import 'package:tetorica/cipher/hex.dart';
import 'package:test/test.dart' as test;
String testModulus = "0xC4F8E9E15DCADF2B96C763D981006A644FFB4415030A16ED1283883340F2AA0E2BE2BE8FA60150B9046965837C3E7D151B7DE237EBB957C20663898250703B3F";
String testPrivateKey = "0x8a7e79f3fbfea8ebfd18351cb9979136f705b4d9114a06d4aa2fd1943816677a5374661846a30c45b30a024b4d22b15ab323622b2de47ba29115f06ee42c41";
String testPublicKey =  "0x010001";

main() {
  test.group("rsa", () {
    test.test("aa",(){
      BigInt d = new BigInt.fromBytes(Hex.decodeWithNew(testModulus), 300);
      BigInt pu = new BigInt.fromBytes(Hex.decodeWithNew(testPublicKey), 300);
      BigInt pr = new BigInt.fromBytes(Hex.decodeWithNew(testPrivateKey), 300);
      BigInt m = new BigInt.fromBytes([0xbc], 300);
      print(":d: ${d}");
      print(":m: ${m}");
      print(":pu: ${pu}");
      //
      //print(":zz: ${
      //  m.exponentiateWithMod(new BigInt.fromInt(100,32), new BigInt.fromInt(100,32))}");
      //
      BigInt c = RSA.compute(m, pu, d,mode:0);
      print(">>> ${c}");
      //print(">>> ${RSA.compute(c, pr, d,mode:0)}");

    });
    test.test("compute 001", () {
      {
        //
        // n = pq
        // c = m**e % n
        // m = c**d % n
        // sigma = (p-1)(q-1)
        // e := (ex 2**16+1)
        // ed % sigma = 1
        int bufferSize = 3*620;
        BigInt e = new BigInt.fromInt(0x4f, bufferSize);
        BigInt d = new BigInt.fromInt(0x3fb, bufferSize);
        BigInt n = new BigInt.fromInt(0xd09, bufferSize);
        BigInt m1 = new BigInt.fromInt(0x2b0, bufferSize);

        // encrypt
        BigInt c = RSA.compute(m1, e, n);
        test.expect("${c}","${new BigInt.fromInt(1570,bufferSize)}");

        // decrypt
        BigInt m2 = RSA.compute(c, d, n);
        test.expect("${m2}","${new BigInt.fromInt(688,bufferSize)}");
      }

    });


    test.test("compute 002", () {
      {
        // p = 3
        // q = 5
        // n = 15
        // sigma = 8
        // e = 13 : 1<e<n
        // ed = 3 % sigma
        // c = m**e % n
        // m = c**d % n
        int bufferSize = 20;
        BigInt e = new BigInt.fromInt(11, bufferSize);
        BigInt d = new BigInt.fromInt(3, bufferSize);
        BigInt n = new BigInt.fromInt(15, bufferSize);
        BigInt m1 = new BigInt.fromInt(9, bufferSize);

        // 33 8
        // encrypt
        BigInt c = RSA.compute(m1, e, n);
      //  int cc = RSA.computeA(0x2, 11, 15);
      //  test.expect("${c}","${new BigInt.fromInt(1570,bufferSize)}");

        // decrypt
        BigInt m2 = RSA.compute(c, d, n);
      //  int mm2 = RSA.computeA(cc, 3, 15);
      //  print("${m2} A=${mm2} ");
        test.expect("${m2}","${m1}");
      }
    });

  });
}

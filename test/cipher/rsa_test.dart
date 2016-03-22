import 'package:tetorica/cipher/bigint.dart';
import 'package:tetorica/cipher/rsa.dart';
import 'package:test/test.dart' as test;

main() {
  test.group("rsa", () {
    test.test("compute 001", () {
      {
        //
        // n = pq
        // c = m**e % n
        // m = c**d % n
        // sigma = (p-1)(q-1)
        // e := (ex 2**16+1)
        // ed % sigma = 1
        int bufferSize = 10*620;
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

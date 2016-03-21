library bigint;

import 'dart:typed_data';
import 'hex.dart';

// uint
class BigInt implements Comparable<BigInt> {
  int get lengthPerByte => binary.length;
  List<int> binary;

  bool get isNegative => (binary[0] & 0x80) != 0;

  BigInt.fromInt(int value, int length) {
    binary = new Uint8List((length > 8) ? length : 8);
    int _len = binary.length;
    if (value >= 0) {
      binary[_len - 8] = (value >> 56 & 0xff);
      binary[_len - 7] = (value >> 48 & 0xff);
      binary[_len - 6] = (value >> 40 & 0xff);
      binary[_len - 5] = (value >> 32 & 0xff);
      binary[_len - 4] = (value >> 24 & 0xff);
      binary[_len - 3] = (value >> 16 & 0xff);
      binary[_len - 2] = (value >> 8 & 0xff);
      binary[_len - 1] = (value >> 0 & 0xff);
    } else {
      value *= -1;
      binary[_len - 8] = (value >> 56 & 0xff);
      binary[_len - 7] = (value >> 48 & 0xff);
      binary[_len - 6] = (value >> 40 & 0xff);
      binary[_len - 5] = (value >> 32 & 0xff);
      binary[_len - 4] = (value >> 24 & 0xff);
      binary[_len - 3] = (value >> 16 & 0xff);
      binary[_len - 2] = (value >> 8 & 0xff);
      binary[_len - 1] = (value >> 0 & 0xff);
      mutableMinusOne();
    }
  }

  BigInt.fromLength(int length) {
    binary = new Uint8List(length);
  }

  BigInt.fromBytes(List<int> value) {
    binary = new Uint8List.fromList(value);
  }

  BigInt operator +(BigInt other) {
    if (this.lengthPerByte != other.lengthPerByte) {
      throw {"message": "need same length ${lengthPerByte} ${other.lengthPerByte}"};
    }

    BigInt result = new BigInt.fromLength(this.lengthPerByte);
    int tmp = 0;
    for (int i = binary.length - 1; i >= 0; i--) {
      tmp = binary[i] + other.binary[i] + (tmp >> 8);
      result.binary[i] = tmp & 0xff;
    }
    return result;
  }

  BigInt operator -() {
    return new BigInt.fromBytes(binary)..mutableMinusOne();
  }

  BigInt operator -(BigInt other) {
    if (this.lengthPerByte != other.lengthPerByte) {
      throw {"message": "need same length ${lengthPerByte} ${other.lengthPerByte}"};
    }

    BigInt result = new BigInt.fromLength(this.lengthPerByte);
    int tmp = 0;
    for (int i = binary.length - 1; i >= 0; i--) {
      tmp = binary[i] - other.binary[i] + (tmp >> 8);
      result.binary[i] = tmp & 0xff;
    }
    return result;
  }

  void mutableMinusOne() {
    int tmp = 0;
    for (int i = binary.length - 1; i >= 0; i--) {
      tmp = 0 - binary[i] + (tmp >> 8);
      binary[i] = tmp & 0xff;
    }
  }

  void clearZero() {
    for (int i = binary.length - 1; i >= 0; i--) {
      binary[i] = 0;
    }
  }

  BigInt operator *(BigInt other) {
    if (this.lengthPerByte != other.lengthPerByte) {
      throw {"message": "need same length ${lengthPerByte} ${other.lengthPerByte}"};
    }

    BigInt a = this;
    BigInt b = other;
    int minus = (((a.isNegative == true ? 1 : 0) ^ (b.isNegative == true ? 1 : 0)) == 1 ? -1 : 1);

    if (b.isNegative) {
      b = -b;
    }
    if (a.isNegative) {
      a = -a;
    }
    if (a < b) {
      var t = a;
      a = b;
      b = t;
    }
    BigInt result = new BigInt.fromLength(a.lengthPerByte);
    BigInt t = new BigInt.fromLength(this.lengthPerByte);
    for (int i = binary.length - 1, tmp = 0; i >= 0; i--) {
      t.clearZero();
      for (int j = i; j >= 0; j--) {
        tmp = a.binary[j] * b.binary[i] + (tmp >> 8);
        t.binary[j] = tmp & 0xff;
      }
      //print("#[${i}]# ${t}");
      result = result + t;
    }
    if (minus == -1) {
      result.mutableMinusOne();
    }
    return result;
  }

  BigInt operator %(BigInt other) {
    BigInt a = this;
    BigInt b = other;
    if (b.isNegative) {
      b = -b;
    }
    if (a.isNegative) {
      a = -a;
    }
    return (other.isNegative == false ? a - (a ~/ b) * b : -(a - (a ~/ b) * b));
  }

  BigInt operator ~/(BigInt other) {
    if (this.lengthPerByte != other.lengthPerByte) {
      throw {"message": "need same length ${lengthPerByte} ${other.lengthPerByte}"};
    }
    int minus = (((this.isNegative == true ? 1 : 0) ^ (other.isNegative == true ? 1 : 0)) == 1 ? -1 : 1);

    BigInt a = (this.isNegative==false?this:-this);
    BigInt b = (other.isNegative==false?new BigInt.fromBytes(other.binary):-(new BigInt.fromBytes(other.binary)));
    BigInt r = new BigInt.fromLength(lengthPerByte);

    for(int i=0,len=binary.length;i<len;i++) {
      r.binary[i] = 0x01;
      if(a < (b+r)) {
        r.binary[i] = 0;
        continue;
      }
      int p = 1;
      for(int j=2,len=(i==0?0x80:0xff);j<len;j++) {
        r.binary[i] = j;
        if(a < (b*r)) {
          r.binary[i] = p;
          continue;
        }
        p=j;
      }
    }

    if (minus == -1) {
      r.mutableMinusOne();
    }
    return r;
  }

  bool operator <(BigInt other) => this.compareTo(other) < 0;

  bool operator <=(BigInt other) => this.compareTo(other) <= 0;

  bool operator >(BigInt other) => this.compareTo(other) > 0;

  bool operator >=(BigInt other) => this.compareTo(other) >= 0;

  bool operator ==(BigInt other) => this.compareTo(other) == 0;

  int compareTo(BigInt other) {
    BigInt a = this;
    BigInt b = new BigInt.fromBytes(other.binary);
    if (a.isNegative != other.isNegative) {
      return (a.isNegative == false ? 1 : -1);
    }
    if (a.isNegative) {
      a = -a;
    }
    if (b.isNegative) {
      b = -b;
    }

    for (int i = 0, len = binary.length; i < len; i++) {
      if (a.binary[i] != b.binary[i]) {
        return (a.binary[i] > b.binary[i] ? (a.isNegative == false ? 1 : -1) : (a.isNegative == false ? -1 : 1));
      }
    }
    return 0;
  }

  int get hashCode {
    int h = 0;
    for (int i = 0, len = binary.length; i < len; i++) {
      h = h * 31 + binary[i].hashCode;
    }
    return h;
  }

  @override
  String toString() {
    return Hex.encodeWithNew(binary);
  }
//  BigInt operator -() => new BigInt(value, isNegative);

}

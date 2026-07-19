import 'dart:typed_data';

/// پیاده‌سازی Bloom Filter برای جستجوی O(1) در لیست بارکدهای مجاز
/// با ظرفیت ۱,۰۰۰,۰۰۰ رکورد و نرخ false-positive ۰.۱٪
class BloomFilter {
  final int bitSize;
  final int hashFunctionCount;
  late final Uint8List _bits;

  /// پارامترهای بهینه برای n=1,000,000 و p=0.001:
  /// - bitSize (m) = 14,377,587 bits ≈ 1.77 MB
  /// - hashFunctionCount (k) = 10
  BloomFilter({
    this.bitSize = 14377587,
    this.hashFunctionCount = 10,
  }) {
    _bits = Uint8List(bitSize ~/ 8 + 1);
  }

  /// ساخت BloomFilter از داده باینری ذخیره‌شده
  BloomFilter.fromBytes(
    Uint8List bytes, {
    this.bitSize = 14377587,
    this.hashFunctionCount = 10,
  }) : _bits = bytes;

  /// افزودن یک عنصر به فیلتر
  void add(String element) {
    final hashes = _generateHashes(element);
    for (final hash in hashes) {
      _setBit(hash % bitSize);
    }
  }

  /// افزودن چند عنصر به‌صورت batch
  void addAll(Iterable<String> elements) {
    for (final e in elements) {
      add(e);
    }
  }

  /// بررسی وجود عنصر در فیلتر
  /// اگر false باشد، قطعاً وجود ندارد
  /// اگر true باشد، احتمالاً وجود دارد (با نرخ FP)
  bool contains(String element) {
    final hashes = _generateHashes(element);
    for (final hash in hashes) {
      if (!_getBit(hash % bitSize)) {
        return false;
      }
    }
    return true;
  }

  /// پاک کردن فیلتر
  void clear() {
    _bits.fillRange(0, _bits.length, 0);
  }

  /// دریافت بایت‌های فیلتر برای ذخیره
  Uint8List toBytes() => _bits;

  /// تنظیم بیت در موقعیت مشخص
  void _setBit(int position) {
    final byteIndex = position ~/ 8;
    final bitIndex = position % 8;
    _bits[byteIndex] |= (1 << bitIndex);
  }

  /// دریافت بیت در موقعیت مشخص
  bool _getBit(int position) {
    final byteIndex = position ~/ 8;
    final bitIndex = position % 8;
    return (_bits[byteIndex] & (1 << bitIndex)) != 0;
  }

  /// تولید k تابع hash با استفاده از double hashing
  /// h_i(x) = (h1(x) + i * h2(x)) % m
  List<int> _generateHashes(String element) {
    final bytes = element.codeUnits;
    final h1 = _murmurHash3(bytes, 0);
    final h2 = _murmurHash3(bytes, h1);

    final hashes = <int>[];
    for (int i = 0; i < hashFunctionCount; i++) {
      // Combine h1 and h2 using double hashing
      final combined = (h1 + i * h2).abs();
      hashes.add(combined);
    }
    return hashes;
  }

  /// الگوریتم MurmurHash3 برای تولید hash
  int _murmurHash3(List<int> key, int seed) {
    const int c1 = 0xcc9e2d51;
    const int c2 = 0x1b873593;

    int h1 = seed;
    final int len = key.length;

    for (int i = 0; i < len; i++) {
      int k1 = key[i];
      k1 = _multiply(k1, c1);
      k1 = _rotateLeft(k1, 15);
      k1 = _multiply(k1, c2);

      h1 ^= k1;
      h1 = _rotateLeft(h1, 13);
      h1 = _multiply(h1, 5) + 0xe6546b64;
    }

    h1 ^= len;
    h1 ^= h1 >>> 16;
    h1 = _multiply(h1, 0x85ebca6b);
    h1 ^= h1 >>> 13;
    h1 = _multiply(h1, 0xc2b2ae35);
    h1 ^= h1 >>> 16;

    return h1;
  }

  int _rotateLeft(int value, int count) {
    return (value << count) | (value >>> (32 - count));
  }

  int _multiply(int a, int b) {
    // Simulate 32-bit multiplication
    return (a * b) & 0xFFFFFFFF;
  }

  /// تخمین تعداد عناصر اضافه‌شده (تقریبی)
  int estimateCount() {
    int setBits = 0;
    for (final byte in _bits) {
      setBits += _countSetBits(byte);
    }
    if (setBits == 0) return 0;
    // n = -(m/k) * ln(1 - X/m)
    final ratio = 1 - (setBits / bitSize);
    if (ratio <= 0) return bitSize;
    return (-(bitSize / hashFunctionCount) * _ln(ratio)).round();
  }

  int _countSetBits(int n) {
    int count = 0;
    while (n != 0) {
      count += n & 1;
      n >>>= 1;
    }
    return count;
  }

  double _ln(double x) {
    // Taylor series approximation for ln(x) where x close to 1
    if (x > 0.99) {
      // For x close to 1, ln(1-y) ≈ -y - y²/2 - y³/3 ...
      final y = 1 - x;
      return -(y + y * y / 2 + y * y * y / 3);
    }
    // General case
    return _log(x);
  }

  double _log(double x) {
    if (x <= 0) return double.nan;
    // Change of base: log(x) = log2(x) * ln(2)
    int exp = 0;
    while (x >= 2) {
      x /= 2;
      exp++;
    }
    while (x < 1) {
      x *= 2;
      exp--;
    }
    // ln(1+y) ≈ y - y²/2 + y³/3 - ...  for -1 < y <= 1
    final y = x - 1;
    double result = 0;
    for (int i = 1; i <= 20; i++) {
      final term = (i.isOdd ? 1 : -1) * _pow(y, i) / i;
      result += term;
    }
    return result + exp * 0.6931471805599453; // ln(2)
  }

  double _pow(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}

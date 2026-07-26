import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

/// سرویس پخش صدای واقعی و قابل‌شنیدن برای تایید/رد بارکد.
/// به‌جای SystemSound (که به تنظیمات "صدای لمس" گوشی وابسته و اغلب شنیده نمی‌شود)،
/// یک تن کوتاه با فرکانس مشخص در لحظه ساخته و با بلندگوی مدیا پخش می‌شود.
/// هیچ فایل صوتی اضافه‌ای به اپ اضافه نمی‌شود؛ موج صدا در حافظه تولید می‌شود.
class SoundService {
  final AudioPlayer _player = AudioPlayer();

  SoundService() {
    _player.setReleaseMode(ReleaseMode.stop);
  }

  /// صدای تایید (بارکد درست/موجود اسکن شد) - تن زوج و کوتاه
  Future<void> playSuccess() => _playChime([1050, 1400], durationMs: 90);

  /// صدای رد (بارکد در لیست نیست) - تن بم و کمی بلندتر
  Future<void> playError() => _playChime([320], durationMs: 260);

  Future<void> _playChime(List<double> frequencies, {required int durationMs}) async {
    try {
      final bytes = _buildToneWav(frequencies: frequencies, durationMs: durationMs);
      await _player.stop();
      await _player.play(BytesSource(bytes), mode: PlayerMode.lowLatency);
    } catch (_) {
      // اگر پخش صدا با خطا مواجه شد، اپ نباید کرش کند؛ فقط بی‌صدا رد شو
    }
  }

  /// ساخت یک فایل WAV کوتاه (16-bit PCM Mono) در حافظه، شامل یک یا چند تن پشت سر هم
  Uint8List _buildToneWav({required List<double> frequencies, required int durationMs}) {
    const sampleRate = 44100;
    final perToneMs = durationMs;
    final samplesPerTone = (sampleRate * perToneMs / 1000).round();
    final totalSamples = samplesPerTone * frequencies.length;

    final header = 44;
    final data = ByteData(header + totalSamples * 2);

    void writeString(int offset, String s) {
      for (int i = 0; i < s.length; i++) {
        data.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    final byteRate = sampleRate * 2;
    writeString(0, 'RIFF');
    data.setUint32(4, 36 + totalSamples * 2, Endian.little);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little); // PCM
    data.setUint16(22, 1, Endian.little); // mono
    data.setUint32(24, sampleRate, Endian.little);
    data.setUint32(28, byteRate, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    writeString(36, 'data');
    data.setUint32(40, totalSamples * 2, Endian.little);

    const fadeSamples = 250;
    int offset = header;
    for (final freq in frequencies) {
      for (int i = 0; i < samplesPerTone; i++) {
        final t = i / sampleRate;
        double envelope = 1.0;
        if (i < fadeSamples) envelope = i / fadeSamples;
        if (i > samplesPerTone - fadeSamples) {
          envelope = (samplesPerTone - i) / fadeSamples;
        }
        final sample =
            (32000 * 0.6 * envelope * math.sin(2 * math.pi * freq * t)).round();
        data.setInt16(offset, sample, Endian.little);
        offset += 2;
      }
    }

    return data.buffer.asUint8List();
  }

  void dispose() {
    _player.dispose();
  }
}

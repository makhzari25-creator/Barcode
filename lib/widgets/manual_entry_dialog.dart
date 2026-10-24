import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../theme/app_colors.dart';

/// کادر ورود دستی بارکد که هم تایپ دستی و هم ورود صوتی (گفتار به متن) را
/// پشتیبانی می‌کند. برای بارکدهایی که دوربین قادر به خواندنشان نیست.
/// کد واردشده (یا null در صورت انصراف) برگردانده می‌شود.
Future<String?> showManualEntryDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _ManualEntryDialog(),
  );
}

class _ManualEntryDialog extends StatefulWidget {
  const _ManualEntryDialog();

  @override
  State<_ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<_ManualEntryDialog> {
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _speechAvailable = false;
  bool _isListening = false;
  String _statusText = 'برای گفتن کد، روی میکروفن بزنید';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// راه‌اندازی موتور تشخیص گفتار (همین‌جا دسترسی میکروفن از کاربر پرسیده می‌شود)
  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          setState(() => _isListening = status == 'listening');
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            _statusText = 'خطا در تشخیص گفتار، لطفاً دستی وارد کنید';
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _speechAvailable = available;
        if (!available) {
          _statusText = 'دسترسی به میکروفن/تشخیص گفتار ممکن نشد';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _speechAvailable = false;
        _statusText = 'دسترسی به میکروفن/تشخیص گفتار ممکن نشد';
      });
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() => _isListening = false);
      return;
    }

    if (!_speechAvailable) {
      await _initSpeech();
      if (!_speechAvailable) return;
    }

    setState(() => _statusText = 'در حال شنیدن... کد را بگویید');

    await _speech.listen(
      localeId: 'fa_IR',
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _controller.text = result.recognizedWords;
          _controller.selection =
              TextSelection.collapsed(offset: _controller.text.length);
        });
      },
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: const Text('ورود دستی یا صوتی بارکد'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'کد بارکد را وارد کنید',
              hintTextDirection: TextDirection.rtl,
              filled: true,
              fillColor: AppColors.surfaceAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (v) => Navigator.of(context).pop(v),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening ? AppColors.danger : AppColors.primary,
                boxShadow: _isListening
                    ? [
                        BoxShadow(
                          color: AppColors.danger.withValues(alpha: 0.35),
                          blurRadius: 18,
                          spreadRadius: 4,
                        ),
                      ]
                    : const [],
              ),
              child: Icon(
                _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _statusText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('انصراف'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
          child: const Text('ثبت'),
        ),
      ],
    );
  }
}

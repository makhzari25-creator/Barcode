from pathlib import Path

def patch_file(path, mode, accent_expr, state_type):
    p = Path(path)
    t = p.read_text()
    if 'PaperImportScreen' in t:
        print(path, 'already patched')
        return False
    if "import 'paper_import_screen.dart';" not in t:
        t = t.replace(
            "import '../widgets/scanner_panel.dart';",
            "import '../widgets/scanner_panel.dart';\nimport 'paper_import_screen.dart';",
        )
    method = f"""
  Future<void> _importPaper() async {{
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaperImportScreen(mode: {mode}, accent: {accent_expr}),
      ),
    );
    if (!mounted) return;
    if (ok == true && context.read<{state_type}>().hasFile) {{
      setState(() {{
        _feedback = null;
        _query = '';
        scanPaused = false;
      }});
      if (scannerController == null) {{
        initScanner();
      }} else {{
        await resumeScanner();
      }}
    }}
  }}

"""
    if '_importPaper' not in t:
        t = t.replace(
            '  @override\n  Future<void> handleCode(String code) async {',
            method + '  @override\n  Future<void> handleCode(String code) async {',
        )
    if 'onPaper:' not in t:
        t = t.replace(
            "          onPick: _pickExcelFile,\n        ),",
            "          onPick: _pickExcelFile,\n          onPaper: _importPaper,\n        ),",
        )
    if "case 'paper':" not in t:
        t = t.replace(
            "                case 'replace':\n                  _confirmReplace();\n              }",
            "                case 'replace':\n                  _confirmReplace();\n                case 'paper':\n                  _importPaper();\n              }",
        )
        t = t.replace(
            "              PopupMenuItem(value: 'replace', child: Text('جایگزینی فایل اکسل')),\n            ],",
            "              PopupMenuItem(value: 'replace', child: Text('جایگزینی فایل اکسل')),\n              PopupMenuItem(value: 'paper', child: Text('ورود از عکس کاغذ')),\n            ],",
        )
    p.write_text(t)
    print(path, 'patched')
    return True

if __name__ == '__main__':
    patch_file('lib/screens/check_charge_screen.dart', 0, '_accent', 'AppState')
    patch_file('lib/screens/charge_hall_screen.dart', 1, '_accent', 'HallChargeState')

from pathlib import Path

def add_appbar_icons(path, empty_title):
    p = Path(path)
    t = p.read_text()
    changed = False
    old = f"        appBar: AppBar(title: const Text('{empty_title}')),"
    new = f"""        appBar: AppBar(
          title: const Text('{empty_title}'),
          actions: [
            IconButton(
              tooltip: 'ورود از عکس کاغذ',
              onPressed: _importPaper,
              icon: const Icon(Icons.document_scanner_rounded),
            ),
          ],
        ),"""
    if old in t:
        t = t.replace(old, new, 1)
        changed = True
        print(path, 'empty appbar')
    marker = "        actions: [\n          PopupMenuButton<String>("
    if marker in t and t.count('document_scanner_rounded') < 2:
        rep = """        actions: [
          IconButton(
            tooltip: 'ورود از عکس کاغذ',
            onPressed: _importPaper,
            icon: const Icon(Icons.document_scanner_rounded),
          ),
          PopupMenuButton<String>("""
        t = t.replace(marker, rep, 1)
        changed = True
        print(path, 'loaded appbar')
    if changed:
        p.write_text(t)
    else:
        print(path, 'no change')
    return changed

if __name__ == '__main__':
    add_appbar_icons('lib/screens/check_charge_screen.dart', 'چک کردن شارژ')
    add_appbar_icons('lib/screens/charge_hall_screen.dart', 'شارژ سالن')

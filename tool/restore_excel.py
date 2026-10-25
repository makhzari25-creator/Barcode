#!/usr/bin/env python3
"""Reconstruct lib/services/excel_service.dart from base64 parts."""
from pathlib import Path
import base64
import sys

root = Path(__file__).resolve().parents[1]
parts_dir = root / 'tool' / 'excel_parts'
out = root / 'lib' / 'services' / 'excel_service.dart'

chunks = sorted(parts_dir.glob('part_*.b64'))
if not chunks:
    print('No parts found', file=sys.stderr)
    sys.exit(1)

b64 = ''.join(p.read_text().strip() for p in chunks)
data = base64.b64decode(b64)
out.write_bytes(data)
print(f'Wrote {out} ({len(data)} bytes)')
if b'ZipDecoder' not in data:
    print('ERROR: ZipDecoder missing', file=sys.stderr)
    sys.exit(2)

from pathlib import Path
import csv, json, re, sys

ROOT = Path(__file__).resolve().parents[1]
errors=[]

# Basic JSON validation.
for p in [ROOT/'config.demo.json', ROOT/'config.example.json']:
    try:
        json.loads(p.read_text(encoding='utf-8'))
    except Exception as e:
        errors.append(f'{p.name}: invalid json: {e}')

# Outbound CSV contract.
with (ROOT/'samples/source/purchase_orders.csv').open(encoding='utf-8', newline='') as f:
    rows=list(csv.DictReader(f))
required={'PURCHASE_ORDER_NO','LINE_NO','ORDER_DATE','PRODUCT_CODE','QUANTITY','UNIT_PRICE','DELIVERY_DATE'}
if not rows or set(rows[0]) != required:
    errors.append('purchase_orders.csv: unexpected columns')

# Inbound contract.
lines=(ROOT/'samples/inbound/PRODUCT_MASTER_20260929_140000.txt').read_text(encoding='utf-8').splitlines()
if not lines or lines[0] != 'PRODUCT_CODE|PRODUCT_NAME|REPLACEMENT_CODE|ACTIVE':
    errors.append('product master sample: unexpected header')

# Public repo must not contain private IPv4 addresses or obvious literal passwords.
# Documentation can mention localhost only.
private_ip = re.compile(r'\b(?:10\.\d{1,3}\.\d{1,3}\.\d{1,3}|192\.168\.\d{1,3}\.\d{1,3}|172\.(?:1[6-9]|2\d|3[01])\.\d{1,3}\.\d{1,3})\b')
password_literal = re.compile(r'(?i)(password|pass)\s*[=:]\s*["\'](?!\$|%|\{|<|example)[^"\']{4,}["\']')
for p in ROOT.rglob('*'):
    if not p.is_file() or '.git' in p.parts or p.suffix.lower() in {'.zip','.png','.jpg','.jpeg'}:
        continue
    try: text=p.read_text(encoding='utf-8')
    except UnicodeDecodeError: continue
    if private_ip.search(text): errors.append(f'{p.relative_to(ROOT)}: private IP found')
    if password_literal.search(text): errors.append(f'{p.relative_to(ROOT)}: possible literal password found')

if errors:
    print('Validation failed:')
    for e in errors: print(' -', e)
    sys.exit(1)
print('Public repository validation passed.')

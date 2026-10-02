"""P-57: Fix 6 shifted/misplaced rows in CHECKLIST-GLOBAL.md (byte-exact EOL)."""
import sys, os

sys.stdout.reconfigure(encoding='utf-8')

PATH = 'CHECKLIST-GLOBAL.md'
data = open(PATH, 'rb').read()
text = data.decode('utf-8')

# Verify pre-state
crlf_count = text.count('\r\n')
lf_only = text.replace('\r\n', '').count('\n')
cr_only = text.replace('\r\n', '').count('\r')
nul_count = text.count('\x00')
print(f'PRE: CRLF={crlf_count} LF={lf_only} CR={cr_only} NUL={nul_count}')
assert crlf_count == 231 and lf_only == 0 and cr_only == 219 and nul_count == 1

segs = text.split('\r\n')
assert len(segs) == 232

def fix_row(idx, old_middle, new_middle):
    """Replace the middle fields of segment `idx`, preserving leading `| ID |` and trailing `| Notas...|`.
    old_middle / new_middle are the full pipe-delimited sequence between Estado and the Notas section."""
    seg = segs[idx]
    # Find where the 3rd pipe field starts (after `| ID | Módulo | Estado |`)
    # and where the Notas section starts. We'll do a surgical find-and-replace.
    old_str = old_middle
    if old_str not in seg:
        print(f'  seg {idx}: WARNING - old_middle not found exactly, trying lenient match...')
        # Try to find it
        return False
    new_str = new_middle
    segs[idx] = seg.replace(old_str, new_str, 1)
    print(f'  seg {idx}: patched ({len(seg)} -> {len(segs[idx])} chars)')
    return True

# ===== ROW 22 (seg 123) =====
# Remove two spurious fields between Progreso and Prioridad:
#   ` **🟡 Reclamado por agnes-2.5-flash** | 37/100 `
print('Fixing row 22...')
ok = fix_row(123,
    ' | **\U0001f7e1 Reclamado por agnes-2.5-flash** | 37/100 | Alta',
    ' | Alta'
)
assert ok, 'Row 22 patch failed'

# ===== ROW 26 (seg 127) =====
# Agente actual holds "DeepSeek-V4.1-Flash" but module is Liberado -> should be "—"
print('Fixing row 26...')
seg26 = segs[127]
# The agent field is between the Recom "—" and the UltAct date
# Pattern: ` | — | DeepSeek-V4.1-Flash | 2026-09-14 |`
ok = fix_row(127,
    ' | — | DeepSeek-V4.1-Flash | 2026-09-14 |',
    ' | — | — | 2026-09-14 |'
)
assert ok, 'Row 26 patch failed'

# ===== ROW 67 (seg 172) =====
# Remove three spurious fields: ` agnes-2.5-flash | 2026-09-04 02:45 | **🟡 Reclamado por agnes-2.5-flash** `
# and add Prioridad "—" (missing)
print('Fixing row 67...')
ok = fix_row(172,
    ' | 19/131 | agnes-2.5-flash | 2026-09-04 02:45 | **\U0001f7e1 Reclamado por agnes-2.5-flash** | 3 | 28 | GLM-5.3 Flash | — | 2026-09-02 07:40 |',
    ' | 19/131 | — | 3 | 28 | GLM-5.3 Flash | — | 2026-09-02 07:40 |'
)
assert ok, 'Row 67 patch failed'

# ===== ROW 68 (seg 173) =====
# Agente actual holds "DeepSeek-V4.1-Flash" but module is Liberado -> should be "—"
print('Fixing row 68...')
ok = fix_row(173,
    ' | — | DeepSeek-V4.1-Flash | 2026-09-15 02:06 |',
    ' | — | — | 2026-09-15 02:06 |'
)
assert ok, 'Row 68 patch failed'

# ===== ROW 76 (seg 182) =====
# Remove 5 spurious fields, add missing Dependencias "—", use more recent date
print('Fixing row 76...')
ok = fix_row(182,
    ' | 4/130 | Baja | 5 | agnes-2.5-flash | 2026-09-03 08:35 | Sin asignar | — | — | 2026-08-17 12:05 |',
    ' | 4/130 | Baja | 5 | — | agnes-2.5-flash | — | 2026-09-03 08:35 |'
)
assert ok, 'Row 76 patch failed'

# ===== ROW 77 (seg 183) =====
# Remove three spurious fields, add missing Prioridad "—"
print('Fixing row 77...')
ok = fix_row(183,
    ' | 4/130 | agnes-2.5-flash | 2026-09-03 08:35 | **\U0001f7e1 Reclamado por agnes-2.5-flash** | 5 | 76 | GLM-5.3 Flash | — | 2026-08-17 12:35 |',
    ' | 4/130 | — | 5 | 76 | GLM-5.3 Flash | — | 2026-08-17 12:35 |'
)
assert ok, 'Row 77 patch failed'

# Write back
new_text = '\r\n'.join(segs)
out_bytes = new_text.encode('utf-8')

# Verify post-state
crlf_count2 = new_text.count('\r\n')
lf_only2 = new_text.replace('\r\n', '').count('\n')
cr_only2 = new_text.replace('\r\n', '').count('\r')
nul_count2 = new_text.count('\x00')
print(f'POST: CRLF={crlf_count2} LF={lf_only2} CR={cr_only2} NUL={nul_count2}')
assert crlf_count2 == 231, f'CRLF changed: {crlf_count2}'
assert lf_only2 == 0, f'LF appeared: {lf_only2}'
assert cr_only2 == 219, f'CR changed: {cr_only2} (was 219)'
assert nul_count2 == 1, f'NUL changed: {nul_count2}'

open(PATH, 'wb').write(out_bytes)
print(f'Written {len(out_bytes)} bytes to {PATH}')
print('DONE - EOL signature preserved: 231/0/219/1')

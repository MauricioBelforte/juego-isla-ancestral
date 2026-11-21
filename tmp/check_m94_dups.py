import os, re

fpath = 'DOCUMENTACION/94-Retencion-Sin-FOMO/plan-actual/05-Checklist.md'
text = open(fpath, encoding='utf-8').read()
lines = text.splitlines()

x_texts = []
q_texts = []
for i, line in enumerate(lines, 1):
    m = re.search(r'\[x\]\s*(.+)', line)
    if m:
        x_texts.append((i, m.group(1).strip()[:60]))
    m = re.search(r'\[\?\]\s*(.+)', line)
    if m:
        q_texts.append((i, m.group(1).strip()[:60]))

print('Total [x]:', len(x_texts))
print('Total [?]:', len(q_texts))
print()
print('=== [?] items ===')
dup_count = 0
for qi, qtext in q_texts:
    is_dup = False
    for xi, xtext in x_texts:
        qnorm = re.sub(r'\[[SMC]\]', '', qtext).split('--')[0].split('→')[0].strip().lower()
        xnorm = re.sub(r'\[[SMC]\]', '', xtext).split('--')[0].split('→')[0].strip().lower()
        if qnorm and xnorm and (qnorm in xnorm or xnorm in qnorm):
            is_dup = True
            break
    if is_dup:
        dup_count += 1
    status = 'DUP' if is_dup else '---'
    print('  L' + str(qi) + ': ' + status + ' ' + qtext[:80])
print()
print('Duplicates found:', dup_count, 'of', len(q_texts))
PYEOF
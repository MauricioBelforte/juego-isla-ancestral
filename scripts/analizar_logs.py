import os
import re
from datetime import datetime

logs_dir = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\Logs"

logs = [f for f in os.listdir(logs_dir) if f.endswith('.md')]
numbers = {}
for f in logs:
    m = re.match(r'^(\d+)-', f)
    if m:
        num = int(m.group(1))
        numbers.setdefault(num, []).append(f)

dups = {n: fs for n, fs in numbers.items() if len(fs) > 1}

print("=== DUPLICADOS ===")
for n in sorted(dups):
    print(f"#{n}:")
    for f in dups[n]:
        print(f"  {f}")
    print()

print(f"Total logs: {len(logs)}")
print(f"Total numeros unicos: {len(numbers)}")
print(f"Total duplicados: {len(dups)}")

# Analizar cual es el mas reciente para cada duplicado
print("\n=== MAS RECIENTE POR DUPLICADO ===")
for n in sorted(dups):
    fs = dups[n]
    dated = []
    for f in fs:
        m = re.search(r'(\d{4}-\d{2}-\d{2})_(\d{2}-\d{2})', f)
        if m:
            date_str = m.group(1) + m.group(2).replace('-', '')
            dated.append((date_str, f))
    dated.sort(reverse=True)
    print(f"#{n}: {dated[0][1]} (mas reciente)")
    for d, f in dated[1:]:
        print(f"   -> {f} (a renombrar)")

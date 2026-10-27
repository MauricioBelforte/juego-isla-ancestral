import os, subprocess, datetime
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
os.chdir(root)
out = subprocess.run(["git", "status", "--porcelain"], capture_output=True, text=True).stdout.strip()
lines = out.splitlines()
now = datetime.datetime.now()

def age_min(p):
    try:
        return int((now - datetime.datetime.fromtimestamp(os.path.getmtime(p))).total_seconds() // 60)
    except OSError:
        return None

inc, inq = [], []
for l in lines:
    if len(l) < 4:
        continue
    code = l[:2]
    path = l[3:].strip()
    # unquote if git quoted the path (rare; spaces are fine in porcelain v1 unquoted)
    if path.startswith('"') and path.endswith('"'):
        path = path[1:-1]
    fp = os.path.join(root, path)
    a = age_min(fp)
    if a is not None and a < 15:
        inq.append((a, path))
        continue
    inc.append(path)

print("TOTAL porcelaine lines:", len(lines))
print("IN-FLIGHT (<15m, excluir):")
for a, p in sorted(inq):
    print("   %3dm  %s" % (a, p[:70]))
print("TO COMMIT: %d" % len(inc))
for p in inc[:60]:
    print("   ", p[:70])

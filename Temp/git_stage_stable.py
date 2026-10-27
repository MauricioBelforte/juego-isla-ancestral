import os, subprocess, datetime
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
os.chdir(root)
out = subprocess.run(["git", "status", "--porcelain"], capture_output=True, text=True).stdout
now = datetime.datetime.now()

def age(p):
    try:
        return int((now - datetime.datetime.fromtimestamp(os.path.getmtime(p))).total_seconds() // 60)
    except OSError:
        return 9999

stage = []
for l in out.splitlines():
    if len(l) < 4:
        continue
    path = l[3:].strip()
    if path.startswith('"') and path.endswith('"'):
        path = path[1:-1]
    fp = os.path.join(root, path)
    if os.path.isdir(fp):
        stage.append(path.rstrip("/"))
    elif os.path.exists(fp) and age(fp) < 15:
        continue
    else:
        stage.append(path.rstrip("/"))

print("staging %d paths" % len(stage))
r = subprocess.run(["git", "add"] + [s.replace("\\", "/") for s in stage], capture_output=True, text=True)
if r.stderr.strip():
    print("warn:", r.stderr.strip()[:150])
print(subprocess.run(["git", "diff", "--cached", "--stat"], capture_output=True, text=True).stdout[-400:])

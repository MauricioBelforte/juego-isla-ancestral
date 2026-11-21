import io, json
p = "Logs/estado_director.json"
d = json.load(io.open(p, encoding="utf-8"))
print("CLAVES_TOTAL:", len(d))
for k in ["ling", "pt", "go", "bug152", "gemelos", "nemotron", "hy3", "ling-3.1-flash", "Ling-3.1-Flash"]:
    if k in d:
        v = d[k]
        s = json.dumps(v, ensure_ascii=False)
        print("CAMPO", k, "=", s[:400])
print("HEAD_COMITIS:", d.get("ultimo_commit"), d.get("head"), d.get("HEAD"))
ks = sorted(d.keys())
print("PRIMERAS10:", ks[:10])
print("ULTIMAS10:", ks[-10:])

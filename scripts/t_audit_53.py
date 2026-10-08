# -*- coding: utf-8 -*-
import re, glob, subprocess
for rid in ["77", "45"]:
    g = glob.glob("DOCUMENTACION/%s-*" % rid)[0] + "/plan-actual/05-Checklist.md"
    d = open(g, "rb").read()
    print("M%s 05-Checklist: CRLF=%d CR-suelto=%d loneLF=%d NUL=%d" % (
        rid, d.count(b"\r\n"), d.count(b"\r") - d.count(b"\r\n"),
        d.count(b"\n") - d.count(b"\r\n"), d.count(b"\x00")))
    print("   [x]=%d [?]=%d" % (
        sum(1 for m in re.findall(r"(?m)^\s*[-*]\s*\[(x|X)\]", d.decode("utf-8"))),
        sum(1 for m in re.findall(r"(?m)^\s*[-*]\s*\[\?\]", d.decode("utf-8")))))
    st = subprocess.run(["git", "diff", "--stat", "--", g], capture_output=True, text=True).stdout.strip()
    print("   git stat:", st.splitlines()[-1] if st else "(clean)")

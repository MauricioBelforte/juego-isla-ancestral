#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Auditoría de copyright de .glb (dueños M166/M09 — pipeline de exportación).

Clausura la verificación empírica del claim M127 (Log 1022, 2026-09-18):
"434 .glb sin asset.copyright" (techo de deuda en tools/legal/asset_metadata_scope.json).

Para cada .glb del repo determina evidencia de atribución en 4 fuentes:
  1. Sidecar de licencia en el mismo directorio (LICENSE*, COPYRIGHT*, CREDITS*,
     NOTICE*, attribution*, licencias sidecar por carpeta).
  2. Extras GLB (asset.copyright / asset.license + "extras" anidados con
     copyright/author/license/source/credit/attribution/polypizza_*).
  3. Catálogo de data/legal (licencias.json, creditos.json, modelos_3d.json):
     solo hay entradas por CATEGORÍA — se reporta como señal de contexto.
  4. git (commit que añadió el .glb + mensaje del commit: origen conocido).

Clasificación:
  CON      — evidencia por-archivo: sidecar de licencia en el mismo directorio,
             o extras GLB con licencia/autor declarada, o catálogo por-archivo.
  AMBIGUO  — señal de procedencia sin licencia declarada: asset.generator,
             nombre con patrón de terceros (kenney/opengameart/poly/sketchfab/
             hyper3d/rodin/hunyuan), commit git que lo añade con origen, o
             señal de categoría en creditos.json.
  SIN      — cero señales.

ORIGEN inferido (para SIN/AMBIGUO):
  propio (pipeline Blender MCP V5), poly-pizza, poly-haven, sketchfab,
  hyper3d/hunyuan, kenney, opengameart, desconocido.

Uso:
  python scripts/auditar_copyright_glb.py            # resumen en stdout
  python scripts/auditar_copyright_glb.py --json     # + escribe tools/legal/auditoria_copyright_glb.json
  python scripts/auditar_copyright_glb.py --estricto # incluye carpetas excluidas (Obsoletos/tools) en el conteo
"""
import argparse
import collections
import json
import os
import re
import struct
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
OUT_JSON = os.path.join(ROOT, 'tools', 'legal', 'auditoria_copyright_glb.json')

# Mismas exclusiones de tools/legal/asset_metadata_scope.json (+ dirs de build)
EXCLUDE_DIRS = {
    '.git', '.kilo', 'PAPELERA', 'Obsoletos', 'node_modules',
    '__pycache__', '.import', 'build', '.venv', 'dist', 'archive',
    'staging', 'fichas',
}
# Modo --repo: solo las exclusiones de infraestructura (el reporte cubre TODOS
# los .glb versionados, incluidos Obsoletos/archive/staging/fichas)
EXCLUDE_DIRS_REPO = {'.git', '.kilo', 'node_modules', '__pycache__', '.venv', 'build', 'dist', '.import', 'PAPELERA'}

SIDE_CAR = re.compile(
    r'^(license|licence|copyright|credits?|notice|attribution_\w*|'
    r'atribuci\w*|licencia\w*|credit\w*|third[-_ ]party\w*)\.(txt|md|json|rst|licen[cs]e)$|'
    r'.*\.license$|.*\.copyright$',
    re.IGNORECASE,
)

AUTH_KEYS = {
    'copyright', 'author', 'license', 'licence', 'license_uri', 'source',
    'credit', 'credits', 'attribution', 'polypizza_attribution', 'polypizza_id',
    'polypizza_licence', 'artist', 'creator',
}

# Patrones de nombre de terceros (alto sinal, bajo riesgo de falso positivo)
NAME_HINTS = [
    (r'(?i)kenney', 'kenney'),
    (r'(?i)opengameart|openart', 'opengameart'),
    (r'(?i)polypizza|poly[_-]?pizza|poly\.pizza', 'poly-pizza'),
    (r'(?i)polyhaven', 'poly-haven'),
    (r'(?i)sketchfab', 'sketchfab'),
    (r'(?i)hyper3d|rodin|hunyuan', 'hyper3d/hunyuan'),
    (r'(?i)cc0|cc[- ]by', 'licencia-creativa-en-nombre'),
]


def glb_json(path):
    """Devuelve (json_dict|None, version|'not-glTF')."""
    try:
        with open(path, 'rb') as f:
            data = f.read()
    except OSError as e:
        return None, 'read-error:%s' % e
    if len(data) < 12 or data[:4] != b'glTF':
        return None, 'not-glTF'
    ver, total = struct.unpack('<II', data[4:12])
    pos = 12
    while pos + 8 <= total and pos + 8 <= len(data):
        clen, ctype = struct.unpack('<II', data[pos:pos + 8])
        if ctype == 0x4E4F534A:  # JSON
            try:
                return json.loads(data[pos + 8:pos + 8 + clen].decode('utf-8')), ver
            except Exception:
                return None, 'json-error'
        pos += 8 + clen
    return None, 'no-json-chunk'


def extras_found(obj, found):
    if isinstance(obj, dict):
        for k, v in obj.items():
            if k in AUTH_KEYS and v not in (None, '', {}, []):
                found[k] = str(v)[:200]
            extras_found(v, found)
    elif isinstance(obj, list):
        for it in obj:
            extras_found(it, found)


def git_add_map(paths):
    """Primer commit que añade cada .glb + mensaje del commit (pathspec '*.glb')."""
    if not paths:
        return {}
    try:
        out = subprocess.run(
            ['git', 'log', '--all', '--diff-filter=A', '--name-only',
             '--pretty=format:@@@%H %an %s', '--', '*.glb'],
            capture_output=True, text=True, cwd=ROOT, timeout=300)
    except Exception:
        return {}
    lines = out.stdout.splitlines()
    by_file = {}
    cur = None
    for ln in lines:
        ln = ln.rstrip()
        if ln.startswith('@@@'):
            cur = ln[3:].strip()
        elif ln.strip() and cur:
            key = ln.strip()
            by_file[key] = cur  # git log va de más nuevo a más antiguo: sobrescribir queda el más viejo
    return by_file


def main():
    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(encoding='utf-8', errors='replace')
        except Exception:
            pass
    ap = argparse.ArgumentParser()
    ap.add_argument('--json', action='store_true', help='escribe %s' % OUT_JSON)
    ap.add_argument('--estricto', action='store_true',
                    help='incluye carpetas EXCLUDE_DIRS en el conteo (solo contexto)')
    ap.add_argument('--repo', action='store_true',
                    help='reporte canónico: TODOS los .glb versionados en git '
                         '(incluye Obsoletos/archive/staging/fichas, excluye .kilo/worktrees)')
    args = ap.parse_args()

    if args.estricto:
        excl_dirs = set()          # nada excluido (incluye .kilo worktrees)
    elif args.repo:
        excl_dirs = EXCLUDE_DIRS_REPO
    else:
        excl_dirs = EXCLUDE_DIRS

    # 1) Enumerar .glb en disco (con exclusión) y versionados en git
    tracked = set()
    try:
        out = subprocess.run(['git', 'ls-files', '*.glb'], capture_output=True,
                             text=True, cwd=ROOT, timeout=60).stdout
        tracked = set(out.split())
    except Exception:
        pass

    disk = []
    for dp, dn, fn in os.walk(ROOT):
        dn[:] = [d for d in dn if d not in excl_dirs]
        for f in fn:
            if f.lower().endswith('.glb'):
                disk.append(os.path.relpath(os.path.join(dp, f), ROOT).replace('\\', '/'))
    disk.sort()
    if args.repo:
        disk = [p for p in disk if p in tracked]

    git_map = git_add_map(disk)

    # 2) Catálogos de data/legal (señal de categoría)
    leg_dir = os.path.join(ROOT, 'game', 'isla-ancestral', 'data', 'legal')
    cat_seals = {}
    for fn in ('licencias.json', 'creditos.json', 'modelos_3d.json'):
        p = os.path.join(leg_dir, fn)
        if os.path.exists(p):
            try:
                cat_seals[fn] = json.load(open(p, encoding='utf-8'))
            except Exception:
                cat_seals[fn] = None
    creditos_raw = json.dumps(cat_seals.get('creditos.json') or {}, ensure_ascii=False)

    records = []
    for rel in disk:
        full = os.path.join(ROOT, rel)
        j, glb_state = glb_json(full)

        evidence = []   # por-archivo (CON)
        signals = []    # contexto (AMBIGUO)
        origen = None

        # (a) sidecars en el mismo directorio
        d = os.path.dirname(full)
        sidecars = []
        if os.path.isdir(d):
            for f in os.listdir(d):
                if SIDE_CAR.match(f) and os.path.isfile(os.path.join(d, f)):
                    sidecars.append(f)
        if sidecars:
            evidence.append('sidecar:' + ';'.join(sidecars))

        # (b) extras GLB
        asset_meta = {}
        generator = ''
        if j:
            asset_meta = j.get('asset') or {}
            generator = asset_meta.get('generator') or ''
            if asset_meta.get('copyright'):
                evidence.append('asset.copyright=%s' % str(asset_meta['copyright'])[:120])
            if asset_meta.get('license'):
                evidence.append('asset.license=%s' % str(asset_meta['license'])[:120])
            found = {}
            extras_found(j, found)
            auth_extras = {k: v for k, v in found.items()
                           if k in ('copyright', 'author', 'license', 'licence', 'license_uri',
                                    'source', 'credit', 'credits', 'attribution',
                                    'polypizza_attribution', 'polypizza_id', 'polypizza_licence',
                                    'artist', 'creator')}
            if auth_extras:
                evidence.append('extras:%s' % json.dumps(auth_extras, ensure_ascii=False)[:300])
            if generator:
                signals.append('asset.generator=%s' % generator)
        else:
            signals.append('glb-ilegible:%s' % glb_state)
        polypizza_no_licencia = any('polypizza' in e for e in evidence) \
            and not any('polypizza_licence' in e for e in evidence)

        # (c) patrones de nombre de terceros
        base = os.path.basename(rel)
        nombre_tag = None
        for pat, tag in NAME_HINTS:
            if re.search(pat, base):
                nombre_tag = tag
                break

        # (d) git: commit que lo añadió (origen, no evidencia de licencia)
        commit = git_map.get(rel)
        git_author = ''
        git_subject = ''
        if commit:
            parts = commit.split(' ', 2)
            sha = parts[0]
            git_author = parts[1] if len(parts) >= 3 else ''
            git_subject = parts[2] if len(parts) >= 3 else ''
            signals.append('git-add:%s (%s)' % (git_subject[:60], git_author))

        # Clasificación
        ext_origin = None  # origen externo/AI → riesgo de licencia real
        gen_low = generator.lower()
        if polypizza_no_licencia:
            ext_origin = 'poly-pizza(extras-sin-licencia)'
        elif any('polypizza' in e for e in ' '.join(evidence)):
            ext_origin = None  # polypizza completo (con licencia) → queda CON por evidence
        if nombre_tag and nombre_tag not in ('propio',):
            ext_origin = nombre_tag
        if 'hyper3d' in gen_low or 'hunyuan' in gen_low or 'rodin' in gen_low:
            ext_origin = 'AI(%s)' % generator
        if commit and any(w in git_subject.lower() for w in ('poly', 'sketchfab', 'hyper3d', 'hunyuan')):
            ext_origin = ext_origin or 'tercero(via-git)'

        if evidence:
            cls = 'CON'
            origen = ext_origin or 'propio(evidencia-explícita)'
        elif ext_origin:
            cls = 'AMBIGUO'
            origen = ext_origin
        else:
            cls = 'SIN'
            if 'blender' in gen_low or generator:
                origen = 'propio(pipeline-Blender-MCP)'
            elif commit:
                origen = 'propio(pipeline-proyecto,git:%s)' % git_author
            else:
                origen = 'desconocido'

        records.append({
            'archivo': rel,
            'clasificacion': cls,
            'evidencia_con': evidence,
            'senales_ambiguo': signals,
            'origen': origen,
            'generator': generator,
            'commit_add': commit,
            'versionado_git': rel in tracked,
            'glb_state': glb_state if j is None else 'ok',
        })

    # 3) Agrupar por scope
    def scope_of(rel):
        if rel.startswith('game/isla-ancestral/assets/'):
            return 'assets'
        if rel.startswith('game/Obsoletos/'):
            return 'obsoletos'
        if rel.startswith('tools/'):
            return 'tools(blender-mcp)'
        return 'otro'

    scopes = collections.defaultdict(list)
    for r in records:
        scopes[scope_of(r['archivo'])].append(r)

    total_con = sum(1 for r in records if r['clasificacion'] == 'CON')
    total_sin = sum(1 for r in records if r['clasificacion'] == 'SIN')
    total_amb = sum(1 for r in records if r['clasificacion'] == 'AMBIGUO')

    modo = 'ESTRICTO (todo en disco)' if args.estricto else (
        'REPO (todos los .glb versionados)' if args.repo else
        'M127 (scope validator: excluye Obsoletos/archive/staging/fichas)')
    print('AUDITORIA DE COPYRIGHT DE .GLB — %s' % ROOT)
    print('Modo: %s' % modo)
    print('Total .glb auditados: %d' % len(records))
    for sc in ('assets', 'obsoletos', 'tools(blender-mcp)', 'otro'):
        rs = scopes.get(sc, [])
        c = sum(1 for r in rs if r['clasificacion'] == 'CON')
        s = sum(1 for r in rs if r['clasificacion'] == 'SIN')
        a = sum(1 for r in rs if r['clasificacion'] == 'AMBIGUO')
        print('  %-20s %4d glb | CON %d | SIN %d | AMBIGUO %d' % (sc, len(rs), c, s, a))
    print('-' * 78)
    print('TOTales: CON %d · SIN %d · AMBIGUO %d' % (total_con, total_sin, total_amb))
    print()

    # Origen de SIN
    sin_origen = collections.Counter(r['origen'] for r in records if r['clasificacion'] == 'SIN')
    amb_origen = collections.Counter(r['origen'] for r in records if r['clasificacion'] == 'AMBIGUO')
    print('SIN — origen inferido:', dict(sin_origen))
    print('AMBIGUO — origen inferido:', dict(amb_origen))
    gens = collections.Counter(r.get('generator') or '(sin asset.generator)' for r in records)
    print('asset.generator (top 8):')
    for g, c in gens.most_common(8):
        print('  %4d  %s' % (c, g))
    amb = [r for r in records if r['clasificacion'] == 'AMBIGUO']
    if amb:
        print()
        print('LISTA .GLB AMBIGUOS (%d) — origen externo/AI sin licencia declarada:' % len(amb))
        for r in amb:
            print('  %-28s | %s | %s' % (scope_of(r['archivo']), r['archivo'], r['origen']))
    # histograma de commits que añaden glb (scope assets)
    subj = collections.Counter()
    for r in records:
        if scope_of(r['archivo']) == 'assets' and r.get('commit_add'):
            parts = r['commit_add'].split(' ', 2)
            subj[parts[2][:50] if len(parts) >= 3 else parts[0][:12]] += 1
    print()
    print('Commits que añaden .glb en assets/ (top 12):')
    for s, c in subj.most_common(12):
        print('  %4d  %s' % (c, s))
    print()

    print('LISTA DE .GLB SIN COPYRIGHT (%d):' % total_sin)
    for r in records:
        if r['clasificacion'] == 'SIN':
            print('  %-28s | %-70s | %s' % (scope_of(r['archivo']), r['archivo'][:70], r['origen']))
    if any(r['clasificacion'] == 'CON' for r in records):
        print()
        print('LISTA .GLB CON COPYRIGHT (%d):' % total_con)
        for r in records:
            if r['clasificacion'] == 'CON':
                print('  %s | %s' % (r['archivo'], ';'.join(r['evidencia_con'])[:100]))

    if args.json:
        os.makedirs(os.path.dirname(OUT_JSON), exist_ok=True)
        payload = {
            'fecha': '2026-09-18',
            'agente': 'agnes-3-flash (Sapiens AI) / Kilo Code',
            'claim': 'M127 Log 1022: 434 .glb sin copyright (techo asset_metadata_scope.json=418)',
            'conteos': {
                'total': len(records), 'CON': total_con, 'SIN': total_sin, 'AMBIGUO': total_amb,
            },
            'por_scope': {sc: {
                'total': len(rs),
                'CON': sum(1 for r in rs if r['clasificacion'] == 'CON'),
                'SIN': sum(1 for r in rs if r['clasificacion'] == 'SIN'),
                'AMBIGUO': sum(1 for r in rs if r['clasificacion'] == 'AMBIGUO'),
            } for sc, rs in scopes.items()},
            'registro': records,
        }
        with open(OUT_JSON, 'w', encoding='utf-8') as f:
            json.dump(payload, f, ensure_ascii=False, indent=1)
        print()
        print('JSON escrito: %s' % OUT_JSON)


if __name__ == '__main__':
    main()

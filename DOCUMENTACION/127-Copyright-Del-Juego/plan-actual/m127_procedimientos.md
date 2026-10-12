# M127 — Procedimientos USCO y Documentación Pendiente

**Módulo:** M127
**Autor:** agnes-3-flash (Kilo Code)
**Fecha:** 2026-10-12
**Uso:** Documento de referencia para registro formal y documentación.

---

## 1. Registro USCO — Procedimiento General

### Código (Source Code)
1. Compilar fuente completa → ZIP (sin assets binarios).
2. `empaquetar_deposito_usco.py --tipo code --input zip_name` (regla 50 págs: primeras+últimas 25 + página aviso).
3. Ingresar a `copyright.gov` → registro en línea ($35-85).
4. Guardar número de registro en `data/legal/registros.json`.
5. Commit: `docs: registro USCO código #XXXXX`.

### Arte 2D/3D + Logos (Visual Arts)
1. Exportar muestras: PNG/WEBP ≤ 3×3 in (regla USCO).
2. `empaquetar_deposito_usco.py --tipo visual --input samples/`
3. Registro: mismo flujo que código.

### Música (Sound Recording)
1. Exportar stems + mix final (WAV 16-bit 44.1kHz).
2. `empaquetar_deposito_usco.py --tipo audio --input audio/`
3. Registro: indicar duración + compositores.

### Narrativa (Literary Work)
1. Compilar biblia narrativa + guion + diálogos → PDF.
2. `empaquetar_deposito_usco.py --tipo literary --input narrativa.pdf`
3. Registro: indicar extensión.

## 2. Beneficios del Registro Formal
- **Protección legal:** acción por daños (statutory damages) solo si se registró antes de la infracción.
- **Presunción de validez:** el certificado presume la exactitud de la información.
- **Publico record:** el registro es de dominio público (disuasivo para infractores).
- **Plataformas:** Steam/EGS exigen acreditación para takedowns.

## 3. Evidencia de Autoría — Borradores
- **Sketchees:** guardar en `git` con commit date (timestamp inmutable).
- **Iteraciones:** versionar con rama `feature/asset-X` + merge commits.
- **DAW/MIDI:** archivar `.flp`/`.als`/`.als` en `assets/audio/proyectos/` (M41).
- **Narrativa:** commits de `docs/canon/` (M147).
- **Logos:** `assets/2d/logos/` + versiones en `git`.

## 4. Git Blame
- **Política:** `git blame --line-porcelain` para rastrear autoría línea a línea.
- **Herramienta:** `tools/legal/scan_orphan_code.py` detecta código sin autor.
- **CI:** `quality.yml` → job `legal-tools` → `scan_orphan_code.py --check`.

## 5. Procedimientos de Registro por Tipo (4 ítems)
Cada tipo de registro (código, arte, música, narrativa) sigue el flujo de §1.
Documentado en `03-Diseno.md §4` (37 CFR 202.20(c)(2)(vii)).

## 6. Pipeline de Metadata
- **Regla:** metadata ≤ 10% del paquete de distribución.
- **Herramienta:** `empaquetar_deposito_usco.py` valida tamaño.
- **CI:** `quality.yml` → gate `--check`.

## 7. Documentación Interna
- **Guía preservación evidencia:** ver §3 + `tools/legal/` README.
- **Directrices avisos legales:** `NOTICE.md` + `copyright.json` (M127).
- **Catálogo registros:** `data/legal/registros.json` (tool `registros_db.py`).
- **Counter-notice DMCA:** plantilla en `data/community/dmca_template.txt` (M100).
- **Derechos morales/patrimoniales:** Berne Convention (§86 CDF) — derechos morales inalienables; patrimoniales transferibles.
- **Fechas clave:** git log de primera fijación + `AUTHORS.md`.
- **FAQ Fair Use:** `data/legal/` (pendiente M126/M127).

## 8. Polish
- **Marca de agua forense:** ID de build en cada asset (`BuildInfo.build_number`).
- **Acuerces cesión tono amigable:** ver `data/community/` (M100).
- **Guía comunitaria fanart:** ver `reglas_comunidad_completo.md` §7 (M100).
- **Revisión semestral:** M126 (Marketing Legal) + M83 (Licencias).
- **Registro primera fijación nombre:** `git log --oneline | grep -i "isla ancestral" | head -1`.

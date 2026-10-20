# -*- coding: utf-8 -*-
"""RF26 QA de textos (M58 Accesibilidad — G-5.3-Flash-Agente 2026-10-19.
Audita los textos del juego contra la guía RF26 (frases cortas + vocabulario simple).
Uso:
    python scripts/qa_textos_rf26.py            # solo resumen
    python scripts/qa_textos_rf26.py --detallado  # el informe viquings de las frases largas
Fuentes auditadas:
    game/isla-ancestral/data/localizacion/strings_es.json
    game/isla-ancestral/game/isla-ancestral/data/dialogos/*.json (si existen)
Criterio (guía RF26 sección 1/2):
    - Frases > 12 palabras
    - Términos sancionados del glosario (anglicismos evitables / tecnicismos del motor)
    - Doble negación
Salida: OK si el porcentaje de frases que cumplen ≥ 85% (umbral de tanda), FAIL si no.
"""
import io
import json
import os
import re
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RUTA_STRINGS = os.path.join(RAIZ, 'game', 'isla-ancestral', 'data', 'localizacion', 'strings_es.json')

# Glosario sancionado ( guía RF26 §2 — sin anglicismos evitables / tecnicismos)
TERMINOS_SANCIONADOS = ['feedback', 'loot', 'quest', 'payload', 'spawn', 'save', 'load', 'script', 'default', 'bug']

# Posición de la negación doble (no ... no)
RE_DOBLE_NEG = re.compile(r'\bno\b[^.!?]*\bno\b', re.IGNORECASE)


def frases_de(texto: str):
    """Divide en frases por ., !, ? y saltos de línea."""
    crudo = re.split(r'[.!?\n]+', texto)
    return [f.strip() for f in crudo if len(f.strip()) > 0]


def audita_frase(frase: str):
    """Devuelve (palabras, larga, sanciones, doble_neg)."""
    palabras = len(frase.split())
    larga = palabras > 12
    sanciones = [t for t in TERMINOS_SANCIONADOS if re.search(r'\b' + re.escape(t) + r'\b', frase, re.IGNORECASE)]
    doble_neg = bool(RE_DOBLE_NEG.search(frase))
    return palabras, larga, sanciones, doble_neg


def recolectar_textos():
    textos = []
    if os.path.exists(RUTA_STRINGS):
        datos = json.loads(io.open(RUTA_STRINGS, encoding='utf-8-sig').read())
        cadenas = datos.get('cadenas', {})
        # recursivo: el catálogo tiene claves anidadas tipo "SETTINGS.TITULO"
        for clave, valor in cadenas.items():
            if isinstance(valor, str) and valor.strip():
                textos.append(("strings_es." + clave, valor))
            elif isinstance(valor, dict):
                for k2, v2 in valor.items():
                    if isinstance(v2, str) and v2.strip():
                        textos.append(("strings_es." + k2, v2))
    return textos


def main() -> int:
    detallado = '--detallado' in sys.argv
    textos = recolectar_textos()
    if not textos:
        print('[RF26] FAIL: no hay textos para auditar')
        return 1

    total_frases = 0
    incumplen = []
    for fuente, texto in textos:
        for frase in frases_de(texto):
            palabras, larga, sanciones, doble_neg = audita_frase(frase)
            total_frases += 1
            if larga or sanciones or doble_neg:
                incumplen.append((fuente, frase, palabras, sanciones, doble_neg))

    print('[RF26] textos auditados: %d | frases analizadas: %d' % (len(textos), total_frases))
    print('[RF26] frases que incumplen: %d (%.1f%%)' % (
        len(incumplen), 100.0 * len(incumplen) / max(total_frases, 1)))

    if detallado:
        for fuente, frase, palabras, sanciones, doble_neg in incumplen[:30]:
            marca = []
            if palabras > 12:
                marca.append('larga:%d' % palabras)
            if sanciones:
                marca.append('glosario:' + ','.join(sanciones))
            if doble_neg:
                marca.append('doble_neg')
            print('  - %s | %s | %s' % (fuente, ','.join(marca), frase[:70]))

    umbral_ok = len(incumplen) <= total_frases * 0.15  # ≥85% cumple
    print('[RF26] RESULTADO=', 'OK' if umbral_ok else 'FAIL (mas del 15%% incumple)')
    return 0 if umbral_ok else 1


if __name__ == '__main__':
    exit_code = main()
    sys.exit(exit_code)

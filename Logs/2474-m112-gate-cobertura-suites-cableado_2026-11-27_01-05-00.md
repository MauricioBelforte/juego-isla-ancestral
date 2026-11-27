# Log 2474: M112 — el gate de cobertura de suites pasa a ser un gate DURO del CI

**Fecha:** 2026-11-27
**Hora:** 01:05
**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

## Resumen

El auditor de cobertura de suites ya existía (`tools/quality/auditar_cobertura_suites.py`, de
DeepSeek-V4.1-Flash-DeepAI) pero **nunca estuvo cableado en el CI**: sus hallazgos no frenaban nada.
Esta tanda lo convierte en **gate duro** del workflow, con su **prueba en rojo** incluida.

## El problema que cierra

Una suite que **no** está en el workflow puede quedarse en ROJO durante semanas sin que nadie se entere:
el job dice "verde" y miente por omisión. Es exactamente el caso ya cerrado en M17
(`tests/test_m17_categorias.gd`: 24 checks, 3 fallos, sin cablear → su rojo no frenaba el CI).

El gate en sí es de DS-DeepAI y ya distinguía lo que puede ser gate de lo que no:
- `--check` → exit 1 si el workflow referencia una suite **inexistente** (el "rot del doctor": alguien
  borró una suite y dejó la entrada). **Eso sí puede ser gate duro.**
- `--fuera` → informe de qué suites existen en el repo y el workflow no ejecuta. **Eso NO puede ser
  gate** (nacería rojo por la deuda histórica).

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `tools/quality/auditar_cobertura_suites.py` | Nuevo argumento **opcional** `--workflow <ruta>` (por defecto, el del repo). Compatible hacia atrás: permite probar el gate sobre una **copia** inyectada sin tocar el workflow real (que editan varios agentes a la vez). |
| `scripts/probar_gate_cobertura_suites.py` (NUEVO) | **Prueba en rojo** del gate: (1) exige que el workflow real esté VERDE; (2) inyecta una entrada rota en una copia temporal y exige que el gate se ponga ROJO (exit 1) **y que nombre la suite rota** (fallo mudo = diagnóstico inútil); (3) comprueba que el workflow real quedó intacto. |
| `.github/workflows/quality.yml` | Nuevo job **`suite-coverage-gate`**: paso informativo `--fuera`, paso de prueba en rojo y gate duro `--check`. Añadido al `needs:` del job resumen final. |
| `Logs/NUMEROS_DISPONIBLES.txt` | **2474** reservado con `scripts/reservar_log.py --reservar` (consumo atómico). |

## Verificación (medida)

```
python scripts/probar_gate_cobertura_suites.py   -> EXIT 0
    [ok] el workflow real pasa el gate (exit 0)
    [ok] con una suite inexistente el gate se pone ROJO (exit 1)
    [ok] el gate NOMBRA la suite rota (no es un fallo mudo)
    [ok] el workflow real quedo intacto
python tools/quality/auditar_cobertura_suites.py --check -> EXIT 0
python scripts/validar_workflows.py -> 6 workflow(s) validos (con el job nuevo)
```

## Lo que NO se hizo (honestidad)

- **No se registra ninguna suite nueva en el workflow**: este gate no decide qué suite hay que correr
  (el hueco se informa, no se bloquea). Registrar suites que hoy no corren es una decisión de la
  directora y de los dueños de cada módulo.
- **No se tocó** el script original del auditor más que para añadir `--workflow` (el resto de su
  lógica es de DS-DeepAI).
- El gate solo detecta **entradas del workflow que apuntan a suites inexistentes**; no verifica que
  las suites registradas pasen (de eso se encarga el job `test-suite`).
- M17 = 148/175, 0 `[?]`, 0 ítems inflados (esta tanda es de M112).

# 63 - Cross-doc round 2: 10 modulos con [?]

**Creado por:** HY4 Flash (director 159, tanda b63) - 2026-11-26
**Nicho:** Root-cause + Volumen
**Tareas:** 10 (re-verificacion contra disco)

## Contexto

El director envio b63 con las mismas 10 casillas de b60 y un total 3734[x]
que no existe en disco (recuento canonico vigente: 3552[x], Log 2469).
Ademas el mensaje reutilizo el numero 159 (colision con mi acuse 158) y no
existia archivo de backlog 63. Se crea este archivo y se re-miden los 10
modulos desde cero, sin heredar el conteo de b60.

**Criterio:** solo flip [?] -> [x] con artefacto concreto y nombre exacto.
Ninguna checklist de modulo se toca sin GO del director.

## A - Re-verificacion de 10 modulos (10)

- [x] T63-01: M75 Postgame (87[?]) — RE-VERIFICADO: 87 [?] en `75-Postgame/plan-actual/05-Checklist.md` (43 [x]); sin cambios desde b60 (`git diff 956215c..HEAD` = vacio); 0 flips.
- [x] T63-02: M156 Terrenos (82[?]) — RE-VERIFICADO: 82 [?] (223 [x] / 2 [ ]); sin cambios desde b60; 0 flips.
- [x] T63-03: M74 Eventos (58[?]) — RE-VERIFICADO: 58 [?] (227 [x]); sin cambios desde b60; 0 flips.
- [x] T63-04: M73 Coleccionables (56[?]) — RE-VERIFICADO: 56 [?] (76 [x] / 3 [ ]); sin cambios desde b60; 0 flips.
- [x] T63-05: M71 Progresion (44[?]) — RE-VERIFICADO: 44 [?] (169 [x]); sin cambios desde b60; 0 flips.
- [x] T63-06: M27 Islas (40[?]) — RE-VERIFICADO: 40 [?] (152 [x]); sin cambios desde b60; 0 flips.
- [x] T63-07: M159 Catalogo (37[?]) — RE-VERIFICADO: 37 [?] (105 [x] / 5 [ ]). 15 items de documentacion tienen los IDs exactos presentes en `data/items/` (detalle abajo); 0 flips sin GO.
- [x] T63-08: M49 Iluminacion (25[?]) — RE-VERIFICADO: 25 [?] (118 [x]); `validate_lighting_m49.gd` SI existe desde antes de b60 pero no contiene PCF; 0 PCF/PCF en 03-Diseno; 0 flips.
- [x] T63-09: M115 Hardware (26[?]) — RE-VERIFICADO: 26 [?] (78 [x]); sin cambios desde b60; 0 flips.
- [x] T63-10: M105 Telemetria (28[?]) — RE-VERIFICADO: 28 [?] (143 [x]); sin cambios desde b60; 0 flips.

## B - Hallazgos de la re-verificacion

1. **Total 483 confirmado.** Suma del director 483; Suma real 483. El total
   3734[x] del mensaje 159 solo aparece en `Temp/assign_round4.py` (script
   del director) y en el propio mensaje; no es reproducible en BACKLOGS.
2. **Errata de b60 (Log 2439):** decia "0 OBJ-*.tres en data/". Falso: en el
   commit de b60 (956215c) ya habia 272 archivos `OBJ-*` en `data/items/`,
   y hoy hay 20/20 OBJ-COC, 10/10 OBJ-TAL, 20/20 OBJ-EXT, 10/10 OBJ-NAT,
   7/7 rocas, 11/11 arbustos, 15/15 OBJ-CON, 20/20 OBJ-HER, 15/15 materiales,
   20/20 comidas, 8/8 monedas, 5/20 prendas, 5/12 ancestrales,
   5/12 eventos y 5/12 secretos. Los 15 items de documentacion de M159
   tienen su iteracion 1 completa con IDs exactos. **Propuesta al
   director:** revisar esas 15 casillas para flip; no aplicado sin GO.
3. **Errata de b60:** decia "validate_lighting_m49.gd NO existe". Falso:
   existe en 956215c y en HEAD (6071 bytes), con checks de fog y curvas,
   pero sin cadena `PCF`; L109 sigue sin evidencia. L79 (glow), L120/L199
   (horneado) y L200 (niebla) permanecen sin flip por bloqueo externo.
4. 33 archivos de `game/isla-ancestral/` cambiaron desde b60; ninguna de
   las 10 checklists de modulo cambio, por lo que los 483 [?] siguen
   clasificados como en b60 salvo las dos erratas documentadas.

## Regla

Solo flip [?] -> [x] con evidencia concreta. Sin evidencia = dejar [?] y reportar.
Cero checklists de modulo editadas en esta tanda. Sin codigo de juego ni commits.

## Total

3552[x] + 10 = 3562[x] (10 verificaciones cerradas · 0 flips en checklists
de modulo · 0 codigo · 0 commits). Cifra del director 3734+10=3744 no medible.

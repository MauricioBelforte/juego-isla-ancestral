**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 149-Nombres-Y-Nomenclatura
**Estado:** Implementación operativa (entregable M149)

---

# Guía de Nombres de NPCs (`npc-names`) — Módulo 149

> **Frontera:** los nombres de los 23 NPCs del canon viven en **M161** (Diseño Visual de NPCs) y su narrativa en **M22/M23/M21**. Este módulo define el **sistema de nombres** (categorías, reglas, validación) y una tabla de candidatos; cualquier nombre nuevo se crea con este sistema y se registra en M147 (World Building) para entrar al canon.

## 1. Sistema de nombres (reglas por categoría)

Reglas generales (todas las categorías):
1. **Nombre propio + epíteto natural:** `Nombre` + apellido-epíteto de naturaleza/oficio (precedente canónico: **Catalina Oso**, **Finneas**). El epíteto se traduce por idioma; el nombre propio nunca se traduce (H-localización).
2. **2-4 sílabas en total**, pronunciables en los 6 idiomas de lanzamiento (M87), sin diéresis/ñ/acentos en la forma base.
3. **Sin nombres religiosos sagrados, de marcas, de personas reales reconocibles ni cargas políticas.**
4. El epíteto siempre es **cálido o neutro** (Oso, Brisa, Cardo) — nunca menacing (Lobo está permitido solo si el NPC es amable "contra-tipo").
5. Los NPCs de cada isla comparten un **matiz fonético** sutil (Aurora: terminaciones en vocal abierta; Raíz: nombres cortos y terráqueos; Coral: vocales suaves y líquidas; Ceniza: consonantes secas).

Categorías (con candidatos — **canon** = ya citado en documentación del proyecto; resto = **PROPUESTA** a adoptar por M161/M22):

| Categoría | Nombre (epíteto) | Significado/intención | Estado |
|---|---|---|---|
| Sabios/Ancianos | Abuela Mora | "mora" = mora silvestre; sabiduría dulce | PROPUESTA |
| Sabios/Ancianos | Don Aurelio Viento | aureo/dorado; sabio de Aurora | PROPUESTA |
| Sabios/Ancianos | Sabio Raudo | raudo = que conoce rápido | PROPUESTA |
| Artesanos | Catalina Oso | fuerza amable; carpintera | **CANON** (M19) |
| Artesanos | Mateo Cardo | cardo = resistente; herrero | PROPUESTA |
| Artesanos | Clara Tejón | tejón = manos trabajadoras | PROPUESTA |
| Exploradores | Finneas | canon, viajero/misión inicial | **CANON** (M137/M138) |
| Exploradores | Río Vela | viajero del agua; navegante | PROPUESTA |
| Exploradores | Alba Faro | quien va primero; guía | PROPUESTA |
| Jóvenes | Sofía Brisa | sabiduría ligera | PROPUESTA |
| Jóvenes | Bruno Playa | pardo, amigable; pescador joven | PROPUESTA |
| Jóvenes | Mila Coral | "querida"; del archipiélago Coral | PROPUESTA |
| Niños | Lila Piedra | pequeña pero firme | PROPUESTA |
| Niños | Zaid Bruma | "aumentar/próspero" (árabe); travieso de la bruma | PROPUESTA |
| Niños | Noor Alga | "luz" (árabe); colección de conchillas | PROPUESTA |
| Especial | Viajero Misterioso | arco narrativo propio (M162) — nombre real reservado | **CANON** (rol) |

## 2. Guía de pronunciación (base es/es + fonética simple)

| Nombre | Pronunciación aproximada | Acento tónico |
|---|---|---|
| Catalina Oso | ka-ta-LI-na Ó-so | "li" |
| Finneas | FI-neas | "fi" |
| Abuela Mora | a-BWE-la MO-ra | "mo" |
| Don Aurelio Viento | don au-RE-lio BIEN-to | "re" |
| Mateo Cardo | ma-TE-o KAR-do | "te" |
| Clara Tejón | KLA-ra te-JON | "cla" |
| Río Vela | RI-o VE-la | "ri" |
| Alba Faro | AL-ba FA-ro | "al" |
| Sofía Brisa | so-FÍ-a BRI-sa | "fí" |
| Bruno Playa | BRU-no PLA-ya | "bru" |
| Mila Coral | MI-la ko-RAL | "mi" |
| Lila Piedra | LI-la PIE-dra | "li" |
| Zaid Bruma | ZA-id BRU-ma | "za" |
| Noor Alga | NO-or AL-ga | "no" |

Regla: ningún nombre requiere sonidos ausentes del inglés/es (para voz "murmura" de M21 y locuciones M87).

## 3. Validación cultural y multilingüe

- **Chequeo de significado:** cada nombre documenta su origen/ significado (tabla §1); se descartan nombres con significado ofensivo, humorístico-negativo o religioso sensible en es/en/fr/de/pt/it (chequeo básico documentado aquí; la revisión final con hablantes nativos queda para la fase de beta — item de validación pendiente).
- **Chequeo de colisión:** no repetir nombres de marcas/personajes protegidos; verificación simple en buscador al proponer (proceso en `validation-process.md`).
- **Registro:** todo nombre adoptado pasa al canon de **M147/M161** con su ficha (quién es, oficio, isla).

## 4. Template para proponer un nuevo NPC

```markdown
### [Nombre + Epíteto] — [categoría] — [isla]
- Significado/intención: {…}
- Pronunciación: {…}
- Oficio/rol: {…}
- Chequeo multilingüe: {OK por qué}
- Chequeo de colisión: {OK}
- Estado: PROPUESTA → CANON (fecha, decidido por M161/M22)
```

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo

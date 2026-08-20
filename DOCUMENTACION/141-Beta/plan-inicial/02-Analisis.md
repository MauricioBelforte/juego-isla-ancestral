**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 141: Beta

## 1. Análisis del dominio
Beta es la fase de **estabilización y completitud**: todo lo prometido debe existir, funcionar, estar pulido y medido. Los frentes de trabajo:

1. **Completitud de contenido**: inventarios formales contra las listas maestras (M73, M16, M28, M24, M36, M23, M74). Gaps = bugs de contenido.
2. **Historia/Acto 3**: script completado (M153), cadenas finitas, epílogo único; la rama de 3 órdenes de sellos (M66) se valida jugando las 3 rutas.
3. **Calidad certificable**: no-bug es la definición de "listo"; QA (M101) mide severidades hasta llegar a cero P0/P1.
4. **Performance trending**: regresión de builds semanales con 20 min de ruta fija (M61).
5. **Comercial**: store page + tráiler no bloquean gameplay, pero ocupan equipo — deadline explícito (W2-W4).

## 2. Alternativas consideradas y decisiones

### D1: Orden de frentes (contenido → calidad → comercial)
- **A1 (contenido primero)**: cerrar inventarios antes de pulir. Riesgo: pulido tardío.
- **A2 (calidad continua, contenido por oleadas)**: cada semana se cierra un frente completo + correcciones del anterior. Mejor balance para hitos fijos.
- **Decisión:** **A2** — 3 oleadas de contenido+QA + semana de estabilización + semana de comercial/certificación (W1-W6).

### D2: Cómo se mide "cero bugs" (RF9)
- **A1 (cero bugs totales)**: imposible; bugs de bajo impacto siempre existirán.
- **A2 (cero P0/P1; P2 con workaround y dueño)**: definición realista usada en la industria.
- **Decisión:** **A2** — P0 = crash/bloqueo total, P1 = pérdida de progreso o bloqueo de contenido mayor, P2 = menor con workaround.

### D3: Localización (RF6)
- **A1 (subcontratar todo)**: costoso y lento para 6 idiomas.
- **A2 (interno + community con revisión)**: M87 con glosario central y TO comunitario con supervisión.
- **Decisión:** **A2** para los 6 idiomas objetivo con revisión de voces por idioma.

### D4: Tráiler (RF12)
- **A1 (tráiler con captura de dev)**: rápido, barato.
- **A2 (tráiler con herramientas oficiales + versiones por plataforma)**: calidad de tapa de store.
- **Decisión:** **A2** para el tráiler final 90s, con variante corta 15s para redes (M149).

### D5: Candidato a RC (RF13)
- **A1 (Beta abierta larga)**: más datos, más riesgo de deriva de contenido.
- **A2 (Beta con fecha fija de corte, RC inmediato, hotfix como loop)**: el candidato es RC si pasa el keep-or-drop.
- **Decisión:** **A2** — el candidato RC se congela al final de W6 y solo recibe hotfixes P0/P1 (M142).

## 3. Riesgos y mitigaciones
| Riesgo | Prob | Impacto | Mitigación |
|--------|------|---------|------------|
| Contenido no cierra a tiempo (sprints de arte/script) | Alta | Alta | Inventarios medianos semanales; contenido reutilizado de M108 |
| Regresión de performance con contenido final | Media | Alta | Builds semanales con ruta fija; rollback de zona (M61) |
| Traducciones incompletas de 6 idiomas | Media | Media | Glosario central + hito de traducción en W3 |
| Certificación rechazada (platform policy) | Baja | Alta | Checklist M149 revisado 2 semanas antes |
| QA crónico de código nuevo | Media | Media | Feature freeze inmediato tras el cierre de contenido |

## 4. Plan de ejecución (6 semanas)
| Semana | Frente |
|--------|--------|
| **W1** | Oleada 1: contenido completo (inventarios, 6 islas, templos, coleccionables); freeze de features y contenido; audio 100% |
| **W2** | Oleada 2: historia completa (Acto 3, epílogo, 3 rutas); localización W3+; accesibilidad 100% (M58) |
| **W3** | Oleada 3: puzzles finales, balance final de dificultad (M93), rendimiento objetivo (M61-M63) |
| **W4** | Semana de estabilización: QA intensivo (M101), entrenamientos de bugs a cero P0/P1, cloud saves y logros (M59/M60/M149) |
| **W5** | Comercial: store page final (textos, capturas, tags), tráiler 90s, requisitos, material de prensa (M149) |
| **W6** | Certificación: checklist de plataforma, build estable final, candidato a RC congelado; acta de cierre Beta |

## 5. Métricas de éxito del módulo
1. Inventario de contenido: 100% de ítems/recetas/coleccionables/eventos/misiones presentes al cierre de W1.
2. Historia: 3 rutas de sellos jugables sin softlock; Acto 3 y epílogo verificados.
3. Bugs: 0 abiertos P0/P1 en el último día de W4.
4. Rendimiento: presupuestos M61-M63 en mínimo y recomendado en build W6 (informe M61).
5. Localización: 6 idiomas con glosario (M87) verificados por checklist.
6. Accesibilidad: 100% de M58 verificado en build final.
7. Comercial: store page + tráiler + requisitos aprobados por el equipo.
8. Certificación: checklist M149 completo; candidato a RC congelado y etiquetado.

## 6. Notas para RC (M142)
- El candidato de Beta (build W6) se congela: solo hotfixes P0/P1 (M142).
- Todos los datos de telemetría/analytics quedan funcionando en la build Beta (M104/M105).
- La firma del acta de cierre Beta autoriza el RC.
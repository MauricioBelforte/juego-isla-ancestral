**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 82: Clasificación por Edades

## Sistemas de Clasificación Mundial

### 1. IARC (International Age Rating Coalition)
- **Alcance**: Sistema global que genera ratings para múltiples jurisdicciones
- **Plataformas que lo aceptan**: Steam, Google Play, Microsoft Store, Nintendo eShop, Meta Quest
- **Proceso**: Cuestionario online → generación automática de ratings regionales
- **Costo**: Gratuito para desarrolladores indie
- **网址**: https://www.globalratings.com/
- **Ventajas**: Un solo proceso, múltiples ratings generados automáticamente
- **Limitaciones**: No aceptado por PlayStation (requiere clasificación propia)

### 2. ESRB (Entertainment Software Rating Board)
- **Alcance**: EE.UU. y Canadá
- **Ratings relevantes**: E (Everyone), E10+ (Everyone 10+), T (Teen)
- **Proceso**: Submission a ESRB portal + evaluación por clasificadores
- **Costo**: Variable según tamaño del juego ($800-$4,000+)
- **Requisito**: Obligatorio para PlayStation (EE.UU./Canadá)
- **PlayStation**: Acepta ESRB directamente

### 3. PEGI (Pan European Game Information)
- **Alcance**: Europa (30+ países)
- **Ratings relevantes**: PEGI 3, PEGI 7, PEGI 12, PEGI 16
- **Proceso**: Cuestionario online + evaluación
- **Costo**: Gratuito para juegos digitales
- **Steam**: Acepta PEGI directamente
- **Consolas**: PlayStation, Xbox, Nintendo aceptan PEGI en Europa

### 4. CERO (Computer Entertainment Rating Organization)
- **Alcance**: Japón
- **Ratings**: A (todos), B (12+), C (15+), D (17+), Z (18+)
- **Proceso**: Submission a CERO + evaluación presencial
- **Costo**: Variable, generalmenterequiere representante local
- **Nintendo**: Acepta CERO para Japón

### 5. GRAC (Game Rating and Administration Committee)
- **Alcance**: Corea del Sur
- **Ratings**: All, 12+, 15+, 18+, Restricted
- **Proceso**: Submission a GRAC + evaluación
- **Costo**: Variable
- **Requisito**: Obligatorio para Steam en Corea

### 6. ACB (Australian Classification Board)
- **Alcance**: Australia
- **Ratings**: G, PG, M, MA15+, R18+, X18+
- **Proceso**: Submission a ACB + evaluación
- **Costo**: Variable
- **Steam**: Acepta ACB para Australia

### 7. USK (Unterhaltungssoftware Selbstkontrolle)
- **Alcance**: Alemania
- **Ratings**: 0, 6, 12, 16, 18
- **Proceso**: Submission a USK + evaluación
- **Costo**: Variable
- **Steam**: Acepta USK para Alemania

### 8. ClassInd (Classificação Indicativa)
- **Alcance**: Brasil
- **Ratings**: L (Libre), 10, 12, 14, 16, 18
- **Proceso**: Submission a ClassInd + evaluación
- **Steam**: Acepta ClassInd para Brasil

## Descriptores de Contenido Aplicables al Juego

| Descriptor | Aplica | Notas |
|------------|--------|-------|
| Violence | No | Sin combate, sin daño a personajes |
| Blood | No | Sin sangre |
| Language | No | Sin lenguaje ofensivo |
| Sexual Content | No | Sin contenido sexual |
| Nudity | No | Sin desnudez |
| Fear | Parcial | Algunos templos pueden generar tensión leve |
| Drug Reference | No | Sin referencias a drogas |
| Gambling | No | Sin gambling real |
| Crude Humor | No | Sin humor crudo |
| Interactive Elements | Sí | Interacción con otros jugadores (si M76 multiplayer futuro) |
| Users Interact | Sí | Si hay features online |
| In-Game Purchases | Sí | Si hay DLC/Expansiones (M120) |

## Rating Objetivo

Dado el contenido del juego (cozy voxel, sin combate, sin violencia, sin contenido adulto):
- **Rating objetivo**: **Everyone (ESRB)** / **PEGI 3** / **IARC Everyone**
- **Contenido que puede elevar el rating**: Templos con atmósfera tensa (miedo leve), possiblesome enemies en templos (si se implementa combate opcional en M11)
- **Recomendación**: Mantener contenido compatible con "Everyone" o máximo "Everyone 10+" / "PEGI 7"

## Dependencias con Otros Módulos

| Módulo | Dependencia | Tipo |
|--------|-------------|------|
| M78 | Legal — Propiedad Intelectual | Base legal para submissions |
| M81 | Legal — Menores | IARC Validator, age gating |
| M96 | Plataformas | Ratings por plataforma |
| M97 | Steam Store Page | Rating en página de Steam |
| M98 | Trailer | Contenido del tráiler compatible con rating |
| M99 | Marketing | Materials compatibles con rating |
| M117 | Build System | Gates de validación pre-build |
| M134 | Presupuesto | Costos de certificación |
| M151 | Control Final | Verificación de rating en auditoría |
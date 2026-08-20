**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 03-Diseno.md — Módulo 126: Marketing Legal

## 1. Estructura del módulo

```
Marketing Legal (revisión legal de marketing)
├── Derechos de screenshots
│   ├── Screenshots creados in-house
│   ├── Propiedad del desarrollador
│   ├── Legal para usar en marketing
│   └── Excepciones (mods, UGC, plataformas)
├── Derechos de música
│   ├── Música original (propiedad del desarrollador)
│   ├── Música de terceros (licencias específicas)
│   ├── Licencias de uso comercial
│   └── Atribución requerida
├── Derechos de terceros
│   ├── Assets originales (propiedad del desarrollador)
│   ├── Fonts (licencias de uso comercial)
│   ├── Software (Godot, Blender, GIMP)
│   └── Assets de stock (licencias específicas)
├── Branding
│   ├── Nombre (verificar marcas registradas)
│   ├── Logos (creados in-house)
│   ├── Registro de marca (opcional)
│   └── Logos de plataformas (permiso y guidelines)
├── Influencers
│   ├── Contratos con influencers
│   ├── Disclosure (FTC Guidelines)
│   ├── Pagos documentados
│   └── Uso de assets autorizado
├── Contratos promocionales
│   ├── Contratos con prensa
│   ├── Contratos con plataformas
│   ├── Exclusividad (opcional)
│   └── Licencias de uso de contenido
└── Giveaways
    ├── Normativas locales (FTC, GDPR, CAP)
    ├── Restricciones (edad, jurisdicción, impuestos)
    ├── Reglas claras
    └── Exención de responsabilidad
```

## 2. Sistema de revisión legal

**Archivo: legal/marketing_legal_review.md**

**Estructura:**
```markdown
# Revisión Legal de Marketing - Isla Ancestral

## 1. Derechos de Screenshots
- Screenshots creados in-house: ✅ Legal para usar
- Screenshots de mods/UGC: ❌ Requiere permiso del creador
- Screenshots de plataformas: ✅ Compliance con guidelines

## 2. Derechos de Música
- Música original: ✅ Legal para usar en marketing
- Música de terceros: ❌ Requiere licencias específicas
- Música de dominio público: ✅ Atribución opcional

## 3. Derechos de Terceros
- Assets originales: ✅ Propiedad del desarrollador
- Fonts: ✅ Licencias de uso comercial verificadas
- Software: ✅ Godot (MIT), Blender (GPL), GIMP (GPL)

## 4. Branding
- Nombre "Isla Ancestral": ✅ Verificado, no infringe marcas registradas
- Logos: ✅ Creados in-house, propiedad del desarrollador
- Registro de marca: ⏳ Opcional, recomendado

## 5. Influencers
- Disclosure: ✅ FTC Guidelines (#ad, #sponsored)
- Contratos: ✅ Contrato de servicios
- Pagos: ✅ Documentados

## 6. Contratos Promocionales
- Prensa: ✅ Contratos con exclusividad opcional
- Plataformas: ✅ Compliance con Steamworks, Xbox, PlayStation

## 7. Giveaways
- Normativas: ✅ FTC, GDPR, CAP Code
- Restricciones: ✅ Edad 18+, jurisdicción específica
- Reglas: ✅ Claras, no engañosas
```

## 3. Pruebas de marketing legal

**Pruebas manuales:**
- Probar que screenshots sean legales para usar en marketing
- Probar que música sea legal para usar en trailers
- Probar que branding no infrinja marcas registradas
- Probar que influencers disclosure cumpla FTC Guidelines
- Probar que giveaways cumplan normativas locales

**Pruebas automáticas:**
- Tests de verificación de licencias (fonts, software)
- Tests de verificación de marcas registradas (USPTO, EUIPO)

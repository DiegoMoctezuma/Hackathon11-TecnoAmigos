# ARGOS 🏛️👁️

> App iOS para estudiantes con discapacidad visual que convierte cualquier imagen de pizarrón o material de clase en texto, audio y cuestionarios mediante IA.  
> **Hackathon 11 · FES Acatlán** — Clasificación a fase nacional 2026.

---

## ¿Qué hace?

El estudiante apunta la cámara al pizarrón (o sube una foto/documento). ARGOS extrae el texto con OCR, detecta los temas automáticamente, genera resúmenes y los convierte en audio. Desde ahí puede hacer preguntas por voz o tomar un quiz oral sobre el material, todo sin necesidad de leer una pantalla.

---

## Pipeline de procesamiento

```
Imagen → OCR (Vision) → Análisis estructural → Extracción de temas → Resúmenes → Audio
```

1. **OCR** — Apple Vision framework en nivel `.accurate`, soporte español/inglés, post-procesamiento para limpiar artefactos y unir líneas cortadas
2. **Extracción de temas** — análisis del texto para detectar temas y subtemas con nivel de confianza
3. **Generación de resúmenes** — versión corta y versión completa por tema
4. **RAG** — el asistente de voz consulta los materiales del estudiante para responder preguntas en contexto

---

## Funcionalidades principales

**🎙️ Asistente de voz** — la voz es el canal primario, no el texto. FloatingVoiceButton accesible desde cualquier pantalla, con retroalimentación de onda en tiempo real.

**📝 Quiz oral** — cuestionarios generados desde el material del estudiante, con tres niveles de dificultad (Básico, Intermedio, Avanzado). Operables completamente por voz.

**🧠 IA Centrada en el Humano (HCAI)** — cada resultado incluye un card "¿Cómo se generó esto?" con el nivel de confianza, los factores considerados y la fuente. El usuario puede corregir a la IA y gestionar el consentimiento de sus datos.

**♿ Accesibilidad como núcleo** — configuración inicial de contraste, tamaño de fuente y velocidad de voz; calibración del motor de reconocimiento en onboarding.

---

## Tech Stack

- **Swift 5.9 + SwiftUI**
- **iOS 17+** — `@Observable`, `@MainActor`
- **SwiftData** — persistencia de materiales y sesiones
- **Apple Vision** — OCR
- **AVFoundation** — síntesis y reconocimiento de voz
- Arquitectura MVVM con feature-based folder structure

---

## Correr el proyecto

```bash
git clone https://github.com/DiegoMoctezuma/Hackathon11-TecnoAmigos.git
cd Hackathon11-TecnoAmigos
open ARGOS.xcodeproj
```

Requiere Xcode 15+ e iOS 17. Sin dependencias externas — cero SPM, cero CocoaPods.

> El pipeline de IA tiene un toggle `useMockData` en `AIServiceManager` para correr en modo demo sin necesidad de conectarse a un LLM externo.

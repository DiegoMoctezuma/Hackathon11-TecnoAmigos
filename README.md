# ARGOS 🏛️👁️

## 🎯 Objetivo Principal
Acortar la distancia entre los estudiantes con discapacidad visual y la vida académica. Con ARGOS, el estudiante tiene la capacidad de "ver" qué hay en el pizarrón o acceder a los recursos gráficos de cualquier materia de forma autónoma.

## 💡 Solución del Problema
Con la ayuda de modelos de *machine learning* y visión computacional, es posible analizar y comprender la imagen del pizarrón o cualquier otro recurso gráfico que pueda llegar a ser usado en clase. 

En conjunto con tecnología de modelos de lenguaje (LLM/LMM), podemos crear resúmenes tanto generales como específicos acerca de la sesión. Estos textos, a su vez, son convertidos a archivos de audio que el estudiante puede escuchar en tiempo real. 

Yendo un paso más allá, la tecnología permite al estudiante hablar directamente con la aplicación mediante comandos de voz. De esta manera, el usuario puede interactuar con el asistente, discutir los tópicos y subtemas que la app clasifica automáticamente, y preguntar dudas específicas acerca del material de estudio.

---

## 📱 Secciones de la Aplicación

A continuación se detalla la arquitectura de vistas y las funcionalidades principales de cada sección de la app:

### 🚀 Onboarding (Configuración Inicial)
* **OnboardingView:** Pantalla de bienvenida que introduce al usuario a las capacidades de ARGOS.
* **AccessibilitySetupView:** Configuración inicial para adaptar la interfaz a las necesidades visuales o de interacción del usuario.
* **VoiceCalibrationView:** Calibración del motor de reconocimiento y síntesis de voz para asegurar una interacción óptima con el asistente.

### 🏠 Home (Inicio)
* **HomeView:** El panel principal de la aplicación. Muestra un resumen general del progreso del usuario.
* **RecentActivityRow:** Un historial rápido para retomar las últimas sesiones de estudio o cuestionarios.
* **SubjectCardView / QuickUploadButton:** Accesos directos e intuitivos para explorar las materias guardadas o cargar nuevos documentos al instante.

### 📚 Subjects & Topics (Gestión de Estudio)
* **SubjectDetailView & SubjectConversationsView:** Vistas dedicadas a mostrar el contenido específico de una materia y las interacciones/consultas previas que el usuario ha tenido con la IA sobre esa materia.
* **TopicDetailView:** Desglose detallado de temas y subtemas generados a partir del material de estudio, facilitando la lectura estructurada.
* **NewSubjectSheet:** Interfaz rápida para registrar y categorizar nuevas áreas de estudio.

### 🎙️ Voice Assistant (Asistente de Voz)
* **VoiceAssistantView:** La interfaz conversacional principal donde el usuario interactúa mediante voz con la aplicación.
* **VoiceWaveformView:** Retroalimentación visual en tiempo real que indica cuando el sistema está escuchando o procesando audio.
* **FloatingVoiceButton:** Un botón de acceso global para invocar al asistente desde cualquier parte de la aplicación.

### 📝 Oral Quiz (Repaso y Cuestionarios)
* **QuizSetupView:** Permite al usuario configurar un examen de práctica sobre un tema específico.
* **QuizSessionView:** La vista activa del cuestionario, diseñada para ser operada de forma interactiva y, si se requiere, enteramente por voz.
* **QuizFeedbackView & QuizResultsView:** Proporcionan retroalimentación inmediata sobre las respuestas dadas, explicando los aciertos y las áreas de mejora mediante IA.

### 📤 Upload Material (Carga y Procesamiento)
* **UploadMaterialView:** Centro de digitalización. Permite al usuario subir imágenes, documentos o texto plano. Detrás de escena, se apoya en servicios OCR y análisis estructural para convertir imágenes en texto estructurado y comprensible.
* **ProcessingStepsView:** Muestra al usuario el progreso del análisis de la IA (extracción de texto, generación de resúmenes, creación de cuestionarios) para que nunca se quede en la incertidumbre.

### 🧠 Human-Centered AI (Transparencia y Control)
* Esta sección es el núcleo ético de la app. Incluye vistas como **AITransparencyCard**, **AIExplanationSheet** y **ConfidenceIndicator**, las cuales le explican al usuario *por qué* la IA le está dando una respuesta específica o qué tanta "seguridad" tiene sobre un dato.
* **HumanOverrideView & DataConsentView:** Otorgan el control total al usuario, permitiéndole corregir a la IA si se equivoca y gestionar el consentimiento de sus datos, asegurando que la tecnología trabaje para el humano y no al revés.

### ⚙️ Settings (Ajustes)
* **SettingsView:** Panel de configuración general.
* **AccessibilitySettingsView & VoiceSettingsView:** Ajustes profundos para personalizar el contraste, tamaños de fuente, velocidad de lectura y comportamiento del motor de voz.
* **DataPrivacyView:** Gestión de la privacidad de la información académica y preferencias del usuario.

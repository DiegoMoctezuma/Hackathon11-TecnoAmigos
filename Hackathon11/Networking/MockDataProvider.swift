// MockDataProvider.swift
// EchoStudy
// Pre-built mock data for 3 subjects: Biology, History, Calculus

import Foundation
import SwiftData

enum MockDataProvider {
    
    // MARK: - Populate Mock Data
    
    @MainActor
    static func populateIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Subject>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }
        
        let biology = createBiologySubject()
        let history = createHistorySubject()
        let calculus = createCalculusSubject()
        
        context.insert(biology)
        context.insert(history)
        context.insert(calculus)
        
        try? context.save()
    }
    
    // MARK: - Biology Subject (5 topics)
    
    static func createBiologySubject() -> Subject {
        let subject = Subject(
            name: "Biología Celular",
            iconName: "leaf.fill",
            colorHex: "#2D6A4F"
        )
        
        let mitosis = Topic(
            title: "Mitosis",
            shortSummary: "División celular que produce dos células hijas idénticas.",
            fullSummary: """
            La mitosis es un proceso de división celular en el que una célula madre se divide para producir \
            dos células hijas genéticamente idénticas. Este proceso es fundamental para el crecimiento, \
            la reparación de tejidos y la reproducción asexual. La mitosis se divide en cuatro fases \
            principales: profase, metafase, anafase y telofase, seguida de la citocinesis.
            """,
            subtopics: [
                Subtopic(title: "Profase", content: "Los cromosomas se condensan y se hacen visibles. La envoltura nuclear comienza a desintegrarse y se forma el huso mitótico.", orderIndex: 0),
                Subtopic(title: "Metafase", content: "Los cromosomas se alinean en el plano ecuatorial de la célula, unidos al huso mitótico por los centrómeros.", orderIndex: 1),
                Subtopic(title: "Anafase", content: "Las cromátidas hermanas se separan y migran hacia polos opuestos de la célula.", orderIndex: 2),
                Subtopic(title: "Telofase", content: "Se forman nuevas envolturas nucleares alrededor de cada grupo de cromosomas y los cromosomas se descondensan.", orderIndex: 3)
            ],
            confidence: 0.89,
            isUserVerified: true,
            subject: subject,
            orderIndex: 0
        )
        
        let meiosis = Topic(
            title: "Meiosis",
            shortSummary: "División celular que produce gametos con la mitad de cromosomas.",
            fullSummary: """
            La meiosis es un tipo especial de división celular que reduce el número de cromosomas a la mitad, \
            produciendo cuatro células haploides llamadas gametos. Este proceso es esencial para la reproducción \
            sexual y permite la variabilidad genética a través del entrecruzamiento y la segregación independiente.
            """,
            subtopics: [
                Subtopic(title: "Meiosis I", content: "Primera división: los cromosomas homólogos se separan. Incluye entrecruzamiento durante la profase I.", orderIndex: 0),
                Subtopic(title: "Meiosis II", content: "Segunda división: las cromátidas hermanas se separan, similar a la mitosis.", orderIndex: 1),
                Subtopic(title: "Entrecruzamiento", content: "Intercambio de segmentos entre cromosomas homólogos que aumenta la variabilidad genética.", orderIndex: 2)
            ],
            confidence: 0.85,
            isUserVerified: false,
            subject: subject,
            orderIndex: 1
        )
        
        let membranaCelular = Topic(
            title: "Membrana Celular",
            shortSummary: "Barrera selectiva que controla el transporte de sustancias.",
            fullSummary: """
            La membrana celular es una estructura dinámica compuesta por una bicapa lipídica con proteínas \
            integradas y periféricas. Funciona como barrera selectiva, controlando qué sustancias entran y \
            salen de la célula. El modelo de mosaico fluido describe su estructura flexible.
            """,
            subtopics: [
                Subtopic(title: "Bicapa lipídica", content: "Formada por fosfolípidos con cabezas hidrofílicas y colas hidrofóbicas que crean una barrera semipermeable.", orderIndex: 0),
                Subtopic(title: "Transporte activo", content: "Movimiento de sustancias contra el gradiente de concentración, requiere energía (ATP).", orderIndex: 1),
                Subtopic(title: "Transporte pasivo", content: "Movimiento de sustancias a favor del gradiente de concentración, no requiere energía. Incluye difusión y ósmosis.", orderIndex: 2)
            ],
            confidence: 0.92,
            isUserVerified: true,
            subject: subject,
            orderIndex: 2
        )
        
        let adn = Topic(
            title: "ADN y Replicación",
            shortSummary: "Estructura del ADN y proceso de duplicación del material genético.",
            fullSummary: """
            El ADN es una molécula de doble hélice compuesta por nucleótidos que almacena la información \
            genética. La replicación del ADN es semiconservativa: cada hebra sirve como molde para sintetizar \
            una nueva hebra complementaria. Este proceso es catalizado por la ADN polimerasa y es esencial \
            para la división celular.
            """,
            subtopics: [
                Subtopic(title: "Estructura de doble hélice", content: "Dos cadenas antiparalelas de nucleótidos unidas por puentes de hidrógeno entre bases complementarias (A-T, G-C).", orderIndex: 0),
                Subtopic(title: "Replicación semiconservativa", content: "Cada molécula hija contiene una hebra original y una nueva, demostrado por el experimento de Meselson-Stahl.", orderIndex: 1)
            ],
            confidence: 0.87,
            isUserVerified: false,
            subject: subject,
            orderIndex: 3
        )
        
        let respiracionCelular = Topic(
            title: "Respiración Celular",
            shortSummary: "Proceso metabólico que convierte glucosa en ATP.",
            fullSummary: """
            La respiración celular es el proceso por el cual las células descomponen la glucosa para obtener \
            energía en forma de ATP. Ocurre en tres etapas principales: glucólisis (en el citoplasma), \
            ciclo de Krebs (en la matriz mitocondrial) y cadena de transporte de electrones (en la membrana \
            interna mitocondrial). Produce un total neto de aproximadamente 36-38 moléculas de ATP por \
            molécula de glucosa.
            """,
            subtopics: [
                Subtopic(title: "Glucólisis", content: "Descomposición de glucosa en dos moléculas de piruvato, produciendo 2 ATP y 2 NADH. Ocurre en el citoplasma.", orderIndex: 0),
                Subtopic(title: "Ciclo de Krebs", content: "Serie de reacciones que oxidan el acetil-CoA, generando CO₂, NADH, FADH₂ y GTP.", orderIndex: 1),
                Subtopic(title: "Cadena de electrones", content: "Transferencia de electrones a través de complejos proteicos que genera un gradiente de protones para la síntesis de ATP.", orderIndex: 2)
            ],
            confidence: 0.78,
            isUserVerified: false,
            subject: subject,
            orderIndex: 4
        )
        
        subject.topics = [mitosis, meiosis, membranaCelular, adn, respiracionCelular]
        
        // Add sample conversation
        let bioConversation = Conversation(
            title: "Dudas sobre mitosis",
            messages: [
                ChatMessage(role: .user, content: "¿Cuál es la diferencia entre mitosis y meiosis?"),
                ChatMessage(role: .assistant, content: "La mitosis produce dos células hijas idénticas con el mismo número de cromosomas que la célula madre. La meiosis, en cambio, produce cuatro células haploides con la mitad de cromosomas. La meiosis es exclusiva de células reproductoras, mientras que la mitosis ocurre en células somáticas."),
                ChatMessage(role: .user, content: "¿Y el entrecruzamiento solo pasa en meiosis?"),
                ChatMessage(role: .assistant, content: "Correcto. El entrecruzamiento ocurre durante la profase I de la meiosis, cuando los cromosomas homólogos intercambian segmentos de ADN. Esto no sucede en la mitosis porque no hay apareamiento de cromosomas homólogos.")
            ],
            subject: subject,
            topic: mitosis
        )
        subject.conversations = [bioConversation]
        
        return subject
    }
    
    // MARK: - History Subject (3 topics)
    
    static func createHistorySubject() -> Subject {
        let subject = Subject(
            name: "Historia de México",
            iconName: "building.columns.fill",
            colorHex: "#E63946"
        )
        
        let independencia = Topic(
            title: "Independencia de México",
            shortSummary: "Movimiento que liberó a México del dominio español (1810-1821).",
            fullSummary: """
            La Independencia de México fue un movimiento armado y político que puso fin al dominio español \
            sobre el territorio mexicano. Inició con el Grito de Dolores el 16 de septiembre de 1810 \
            por Miguel Hidalgo y culminó con la entrada del Ejército Trigarante a la Ciudad de México \
            el 27 de septiembre de 1821.
            """,
            subtopics: [
                Subtopic(title: "Grito de Dolores", content: "El 16 de septiembre de 1810, el cura Miguel Hidalgo convocó al pueblo de Dolores a levantarse contra el gobierno español.", orderIndex: 0),
                Subtopic(title: "Morelos y los Sentimientos de la Nación", content: "José María Morelos continuó la lucha y redactó los Sentimientos de la Nación, estableciendo principios de soberanía popular.", orderIndex: 1),
                Subtopic(title: "Consumación", content: "Agustín de Iturbide y Vicente Guerrero firmaron el Plan de Iguala en 1821, uniendo fuerzas para lograr la independencia.", orderIndex: 2)
            ],
            confidence: 0.91,
            isUserVerified: true,
            subject: subject,
            orderIndex: 0
        )
        
        let revolucion = Topic(
            title: "Revolución Mexicana",
            shortSummary: "Conflicto armado que transformó la estructura social de México (1910-1920).",
            fullSummary: """
            La Revolución Mexicana fue un conflicto armado que inició en 1910 contra la dictadura de \
            Porfirio Díaz. Involucró a múltiples facciones con ideales diferentes: maderistas, zapatistas, \
            villistas y carrancistas. Resultó en la Constitución de 1917, que incluyó reformas agrarias, \
            laborales y educativas fundamentales.
            """,
            subtopics: [
                Subtopic(title: "Causas", content: "La dictadura de Porfirio Díaz por más de 30 años, la desigualdad social extrema y la concentración de tierras.", orderIndex: 0),
                Subtopic(title: "Líderes principales", content: "Francisco I. Madero, Emiliano Zapata, Francisco Villa y Venustiano Carranza, cada uno con visiones distintas.", orderIndex: 1)
            ],
            confidence: 0.88,
            isUserVerified: false,
            subject: subject,
            orderIndex: 1
        )
        
        let reformaLiberal = Topic(
            title: "Reforma Liberal",
            shortSummary: "Periodo de reformas que separó la Iglesia del Estado (1855-1863).",
            fullSummary: """
            La Reforma Liberal fue un periodo de transformaciones políticas y sociales liderado por Benito Juárez \
            y otros liberales. Las Leyes de Reforma establecieron la separación entre la Iglesia y el Estado, \
            la nacionalización de bienes eclesiásticos y la libertad de culto. Estos cambios provocaron la \
            Guerra de Reforma entre liberales y conservadores.
            """,
            subtopics: [
                Subtopic(title: "Leyes de Reforma", content: "Conjunto de leyes que separaron la Iglesia del Estado, incluyendo la Ley Juárez, Ley Lerdo y Ley Iglesias.", orderIndex: 0),
                Subtopic(title: "Benito Juárez", content: "Presidente liberal que defendió la República durante la intervención francesa y aplicó las leyes de reforma.", orderIndex: 1)
            ],
            confidence: 0.82,
            isUserVerified: false,
            subject: subject,
            orderIndex: 2
        )
        
        subject.topics = [independencia, revolucion, reformaLiberal]
        
        let histConversation = Conversation(
            title: "Revolución Mexicana",
            messages: [
                ChatMessage(role: .user, content: "¿Por qué empezó la Revolución Mexicana?"),
                ChatMessage(role: .assistant, content: "La Revolución Mexicana inició principalmente por la dictadura de Porfirio Díaz, que duró más de 30 años. Durante el Porfiriato, la riqueza se concentró en pocas manos, los campesinos perdieron sus tierras y no existía democracia real. Francisco I. Madero publicó el Plan de San Luis, convocando al pueblo a levantarse el 20 de noviembre de 1910.")
            ],
            subject: subject,
            topic: revolucion
        )
        subject.conversations = [histConversation]
        
        return subject
    }
    
    // MARK: - Calculus Subject (3 topics)
    
    static func createCalculusSubject() -> Subject {
        let subject = Subject(
            name: "Cálculo Diferencial",
            iconName: "function",
            colorHex: "#1B4965"
        )
        
        let limites = Topic(
            title: "Límites",
            shortSummary: "Concepto fundamental que describe el comportamiento de funciones.",
            fullSummary: """
            Los límites son el concepto fundamental del cálculo que describe el valor al que se aproxima \
            una función cuando su variable se acerca a un punto determinado. Son esenciales para definir \
            derivadas e integrales. Un límite puede existir aunque la función no esté definida en el punto.
            """,
            subtopics: [
                Subtopic(title: "Definición formal", content: "Para todo ε > 0 existe un δ > 0 tal que si 0 < |x - a| < δ entonces |f(x) - L| < ε.", orderIndex: 0),
                Subtopic(title: "Límites laterales", content: "El límite por la izquierda y por la derecha deben coincidir para que el límite exista.", orderIndex: 1),
                Subtopic(title: "Límites al infinito", content: "Describen el comportamiento de la función cuando x crece sin límite, relacionado con asíntotas horizontales.", orderIndex: 2)
            ],
            confidence: 0.86,
            isUserVerified: true,
            subject: subject,
            orderIndex: 0
        )
        
        let derivadas = Topic(
            title: "Derivadas",
            shortSummary: "Tasa de cambio instantánea de una función.",
            fullSummary: """
            La derivada mide la tasa de cambio instantánea de una función en un punto. Geométricamente, \
            representa la pendiente de la recta tangente a la curva. Se calcula como el límite del cociente \
            incremental cuando el incremento tiende a cero. Las reglas de derivación incluyen la regla de \
            la potencia, la regla del producto, la regla del cociente y la regla de la cadena.
            """,
            subtopics: [
                Subtopic(title: "Regla de la potencia", content: "Si f(x) = xⁿ, entonces f'(x) = n·xⁿ⁻¹. La regla más básica y frecuente.", orderIndex: 0),
                Subtopic(title: "Regla de la cadena", content: "Para funciones compuestas: (f∘g)'(x) = f'(g(x)) · g'(x). Esencial para derivar funciones complejas.", orderIndex: 1),
                Subtopic(title: "Aplicaciones", content: "Optimización de funciones, análisis de velocidad y aceleración, y estudio de crecimiento y decrecimiento.", orderIndex: 2)
            ],
            confidence: 0.90,
            isUserVerified: true,
            subject: subject,
            orderIndex: 1
        )
        
        let integrales = Topic(
            title: "Integrales",
            shortSummary: "Proceso inverso de la derivación y cálculo de áreas.",
            fullSummary: """
            La integral es la operación inversa de la derivada. La integral definida calcula el área bajo \
            una curva entre dos puntos. El Teorema Fundamental del Cálculo conecta derivadas e integrales, \
            estableciendo que la integral definida puede calcularse mediante la antiderivada evaluada en \
            los límites de integración.
            """,
            subtopics: [
                Subtopic(title: "Integral indefinida", content: "Familia de antiderivadas de una función, representada como ∫f(x)dx = F(x) + C.", orderIndex: 0),
                Subtopic(title: "Integral definida", content: "Calcula el área neta bajo la curva entre a y b: ∫ₐᵇf(x)dx = F(b) - F(a).", orderIndex: 1),
                Subtopic(title: "Métodos de integración", content: "Sustitución, integración por partes, fracciones parciales y sustitución trigonométrica.", orderIndex: 2)
            ],
            confidence: 0.75,
            isUserVerified: false,
            subject: subject,
            orderIndex: 2
        )
        
        subject.topics = [limites, derivadas, integrales]
        
        let calcConversation = Conversation(
            title: "Ayuda con derivadas",
            messages: [
                ChatMessage(role: .user, content: "No entiendo la regla de la cadena"),
                ChatMessage(role: .assistant, content: "La regla de la cadena se usa cuando tienes una función dentro de otra función. Piénsalo así: si tienes f(g(x)), primero derivas la función de afuera evaluada en lo de adentro, y luego multiplicas por la derivada de lo de adentro. Por ejemplo, si quieres derivar (3x + 1)², primero derivas lo de afuera: 2·(3x + 1)¹, y luego multiplicas por la derivada de adentro: ·3. El resultado es 6·(3x + 1).")
            ],
            subject: subject,
            topic: derivadas
        )
        subject.conversations = [calcConversation]
        
        return subject
    }
    
    // MARK: - Sample Quiz Sessions
    
    static func createSampleQuizSession(subject: Subject, topics: [Topic]) -> QuizSession {
        let questions = [
            QuizQuestion(
                questionText: "¿Cuáles son las cuatro fases de la mitosis?",
                correctAnswer: "Profase, metafase, anafase y telofase",
                userAnswer: "Profase, metafase, anafase y telofase",
                isCorrect: true,
                explanation: "Las cuatro fases de la mitosis son profase, metafase, anafase y telofase, seguidas de la citocinesis."
            ),
            QuizQuestion(
                questionText: "¿Qué enzima cataliza la replicación del ADN?",
                correctAnswer: "La ADN polimerasa",
                userAnswer: "La polimerasa de ADN",
                isCorrect: true,
                explanation: "La ADN polimerasa es la enzima principal que sintetiza nuevas cadenas de ADN."
            ),
            QuizQuestion(
                questionText: "¿Cuántas moléculas de ATP produce la glucólisis?",
                correctAnswer: "2 ATP netos",
                userAnswer: "4 ATP",
                isCorrect: false,
                explanation: "La glucólisis produce 4 ATP brutos, pero consume 2 ATP, resultando en un neto de 2 ATP."
            )
        ]
        
        return QuizSession(
            subject: subject,
            topics: topics,
            questions: questions,
            score: 2,
            totalQuestions: 3,
            completedAt: Date().addingTimeInterval(-86400)
        )
    }
    
    // MARK: - Sample AI Feedback
    
    static func createSampleFeedback() -> [AIFeedback] {
        [
            AIFeedback(
                predictionId: UUID().uuidString,
                predictionType: "topic_extraction",
                userRating: true
            ),
            AIFeedback(
                predictionId: UUID().uuidString,
                predictionType: "summary",
                userRating: true,
                userCorrection: nil,
                voiceCorrection: false
            ),
            AIFeedback(
                predictionId: UUID().uuidString,
                predictionType: "quiz_answer",
                userRating: false,
                userCorrection: "La respuesta correcta debería incluir la citocinesis",
                voiceCorrection: true
            )
        ]
    }
}

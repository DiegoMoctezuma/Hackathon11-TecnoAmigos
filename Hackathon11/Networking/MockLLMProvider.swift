// MockLLMProvider.swift
// EchoStudy
// Complete mock LLM provider with realistic delays, streaming, and pre-written content
// REQUIRES: ProcessingResult.swift, QuizQuestion.swift

import Foundation

// MARK: - Mock Result Types

struct MockSummaryResult {
    var text: String
    var confidence: Float
}

struct MockAssistantResponse {
    var text: String
    var confidence: Float
}

struct MockVisualDescription {
    var description: String
    var nodeCount: Int
    var branches: [String]
}

// MARK: - Mock LLM Provider

actor MockLLMProvider {
    static let shared = MockLLMProvider()
    
    private init() {}
    
    // MARK: - Streaming Helper
    
    /// Simulates LLM streaming: reveals text character by character
    static func simulateStreaming(_ text: String, onCharacter: @escaping @Sendable (String) -> Void) async {
        var accumulated = ""
        for char in text {
            accumulated.append(char)
            onCharacter(accumulated)
            try? await Task.sleep(for: .milliseconds(20))
        }
    }
    
    // MARK: - Legacy API
    
    func generate(prompt: String, systemPrompt: String? = nil) async -> String {
        try? await Task.sleep(for: .seconds(1))
        
        let lowered = prompt.lowercased()
        
        if lowered.contains("resumen") || lowered.contains("summary") {
            return summaries["celula_short"] ?? genericSummary
        } else if lowered.contains("quiz") || lowered.contains("pregunta") {
            return "¿Cuál es la función principal de la mitocondria? La respuesta es: producir ATP mediante la respiración celular."
        } else if lowered.contains("explica") || lowered.contains("explain") {
            return explanations["analogy_celula"] ?? genericExplanation
        } else if lowered.contains("relacion") || lowered.contains("diferencia") {
            return relationships["mitosis_meiosis"] ?? genericRelation
        }
        
        return genericFallback
    }
    
    // MARK: - Topic Extraction (Mock)
    
    func extractTopics(from text: String) async -> [ProcessingResult.DetectedTopic] {
        try? await Task.sleep(for: .seconds(2))
        
        let lowered = text.lowercased()
        
        // Detect keywords to pick relevant mock topics
        if lowered.contains("célula") || lowered.contains("mitocondria") || lowered.contains("membrana") {
            return biologyTopics
        } else if lowered.contains("revolución") || lowered.contains("porfirio") || lowered.contains("independ") {
            return historyTopics
        } else if lowered.contains("límite") || lowered.contains("derivada") || lowered.contains("función") {
            return calculusTopics
        }
        
        // Default: biology topics
        return biologyTopics
    }
    
    // MARK: - Summary Generation (Mock)
    
    func generateSummary(topicTitle: String, length: SummaryLength, style: SummaryStyle = .standard) async -> String {
        let key = topicTitle.lowercased()
        
        if style == .analogy || length == .alternative {
            if key.contains("célula") {
                return "Imagina la célula como una ciudad pequeña. La membrana es la muralla que controla quién entra y sale. El núcleo es el ayuntamiento donde se guardan los planos (ADN). Las mitocondrias son las centrales eléctricas que generan energía. El retículo endoplásmico es la red de carreteras que transporta mercancías. Y los ribosomas son las fábricas que producen las herramientas (proteínas) que la ciudad necesita."
            } else if key.contains("mitosis") {
                return "Piensa en la mitosis como fotocopiar un libro. Primero, el libro se duplica completamente (fase S). Luego, las páginas se organizan en el centro (metafase), se separan en dos pilas iguales (anafase), y finalmente se encuadernan en dos libros idénticos (telofase). Cada libro nuevo tiene exactamente la misma información que el original."
            }
            return "Imagina este concepto como algo de tu vida cotidiana. Es como un proceso donde diferentes partes trabajan juntas para lograr un objetivo. Cada componente tiene su rol específico, y cuando uno falla, todo el sistema se ve afectado."
        }
        
        switch length {
        case .short:
            return summaries[findSummaryKey(key, "short")] ?? genericSummary
        case .medium:
            return summaries[findSummaryKey(key, "medium")] ?? genericSummary
        case .long:
            return summaries[findSummaryKey(key, "long")] ?? genericSummary
        case .alternative:
            return summaries[findSummaryKey(key, "alt")] ?? genericSummary
        }
    }
    
    // MARK: - Assistant Response (Mock)
    
    func assistantResponse(userMessage: String, context: String) async -> String {
        let lowered = userMessage.lowercased()
        
        if lowered.contains("explica") || lowered.contains("explícame") {
            return "Claro, te lo explico de otra forma. Imagina que este proceso es como una cadena de producción en una fábrica. Cada paso transforma el material de entrada en algo más útil. Al final, obtienes el producto terminado: energía que la célula puede usar. ¿Quieres que profundice en algún paso específico?"
        }
        
        if lowered.contains("relación") || lowered.contains("diferencia") {
            if lowered.contains("mitosis") && lowered.contains("meiosis") {
                return "La relación entre mitosis y meiosis es que ambos son procesos de división celular. La diferencia principal es que la mitosis produce 2 células idénticas para crecimiento y reparación, mientras que la meiosis produce 4 células con la mitad de cromosomas para la reproducción sexual. Además, la meiosis incluye el crossing over, que genera variabilidad genética."
            }
            return "Estos dos conceptos están relacionados porque comparten mecanismos fundamentales. La diferencia principal radica en su función y resultado final. ¿Quieres que detalle más algún aspecto?"
        }
        
        if lowered.contains("resumen") || lowered.contains("resume") {
            return "Aquí tienes un resumen breve: este tema trata sobre los procesos fundamentales que permiten a las células funcionar y reproducirse. Los conceptos clave son la estructura celular, los mecanismos de división y la producción de energía. Cada uno está interconectado con los demás."
        }
        
        if lowered.contains("no entiendo") || lowered.contains("no me queda claro") {
            return "Sin problema, vamos más despacio. Piensa en esto como una receta de cocina: hay ingredientes (las moléculas), pasos a seguir (las reacciones) y un resultado final (la energía o las nuevas células). Cada paso depende del anterior. ¿Qué parte específica te resulta confusa? Puedo explicarla con más detalle."
        }
        
        if lowered.contains("quiz") || lowered.contains("pregunta") {
            return "¡Vamos a repasar! Te haré unas preguntas sobre los temas que has estudiado. Primera pregunta: ¿Cuál es la función principal de la mitocondria en la célula? Responde cuando estés listo."
        }
        
        // Fallback contextual
        return "Esa es una buena pregunta. Basándome en tus apuntes, puedo decirte que este concepto se relaciona con los procesos fundamentales estudiados. Los materiales que has subido contienen información relevante que puedo ayudarte a repasar. ¿Quieres que profundice en esto o prefieres que preparemos un quiz?"
    }
    
    // MARK: - Visual Description (Mock)
    
    func describeVisualStructure(imageDescription: String) async -> MockVisualDescription {
        return MockVisualDescription(
            description: "Mapa mental con nodo central 'La Célula' y 5 ramas principales: Membrana Plasmática, Núcleo, Mitocondrias, Retículo Endoplásmico y Aparato de Golgi. Cada rama tiene 2-3 sub-ramas con detalles adicionales.",
            nodeCount: 18,
            branches: ["Membrana Plasmática", "Núcleo", "Mitocondrias", "Retículo Endoplásmico", "Aparato de Golgi"]
        )
    }
    
    // MARK: - Pre-written Data
    
    private let biologyTopics: [ProcessingResult.DetectedTopic] = [
        ProcessingResult.DetectedTopic(
            title: "La Célula: Estructura y Función",
            shortSummary: "La célula es la unidad básica de la vida. Se compone de membrana, citoplasma y material genético.",
            fullSummary: "La célula es la unidad estructural y funcional básica de todos los seres vivos. Existen dos tipos principales: procariotas (sin núcleo definido, como las bacterias) y eucariotas (con núcleo membranoso, como las células animales y vegetales). Las células eucariotas contienen organelos especializados: la membrana plasmática regula el paso de sustancias, el núcleo almacena el ADN, las mitocondrias producen energía (ATP), el retículo endoplásmico participa en la síntesis de proteínas y lípidos, y el aparato de Golgi empaqueta y distribuye moléculas. El citoplasma es el medio acuoso donde ocurren la mayoría de las reacciones celulares.",
            subtopics: [
                ProcessingResult.DetectedSubtopic(title: "Membrana plasmática", content: "Bicapa de fosfolípidos con proteínas que regula el transporte de sustancias."),
                ProcessingResult.DetectedSubtopic(title: "Organelos celulares", content: "Mitocondrias, RE, Golgi, lisosomas y otros organelos con funciones específicas."),
                ProcessingResult.DetectedSubtopic(title: "Núcleo y material genético", content: "Contiene el ADN organizado en cromosomas, controla las funciones celulares.")
            ],
            confidence: 0.88
        ),
        ProcessingResult.DetectedTopic(
            title: "Mitosis: División Celular",
            shortSummary: "La mitosis es el proceso por el cual una célula se divide en dos células hijas idénticas.",
            fullSummary: "La mitosis es un tipo de división celular que produce dos células hijas genéticamente idénticas a la célula madre. Es fundamental para el crecimiento, la reparación de tejidos y la reproducción asexual. El proceso se divide en cuatro fases: Profase (los cromosomas se condensan y la envoltura nuclear se desintegra), Metafase (los cromosomas se alinean en el ecuador celular), Anafase (las cromátidas hermanas se separan hacia los polos) y Telofase (se forman nuevas envolturas nucleares). La citocinesis, que divide el citoplasma, ocurre al final. El ciclo celular está regulado por ciclinas y quinasas dependientes de ciclinas (CDK), con puntos de control que aseguran la correcta replicación del ADN.",
            subtopics: [
                ProcessingResult.DetectedSubtopic(title: "Fases de la mitosis", content: "Profase, metafase, anafase y telofase son las cuatro fases principales."),
                ProcessingResult.DetectedSubtopic(title: "Citocinesis", content: "División del citoplasma que completa la separación de las células hijas."),
                ProcessingResult.DetectedSubtopic(title: "Control del ciclo celular", content: "Ciclinas y CDK regulan los puntos de control del ciclo celular.")
            ],
            confidence: 0.82
        ),
        ProcessingResult.DetectedTopic(
            title: "Meiosis y Reproducción",
            shortSummary: "La meiosis produce células con la mitad de cromosomas, esenciales para la reproducción sexual.",
            fullSummary: "La meiosis es un tipo especial de división celular que reduce el número de cromosomas a la mitad, produciendo cuatro células haploides (gametos) a partir de una célula diploide. Se divide en dos etapas: Meiosis I (división reduccional, donde los cromosomas homólogos se separan) y Meiosis II (similar a la mitosis, separa cromátidas hermanas). Durante la Profase I ocurre el crossing over o entrecruzamiento, donde segmentos de cromosomas homólogos se intercambian, generando variabilidad genética. La gametogénesis comprende la espermatogénesis (formación de espermatozoides) y la ovogénesis (formación de óvulos).",
            subtopics: [
                ProcessingResult.DetectedSubtopic(title: "Meiosis I y II", content: "Meiosis I es reduccional, meiosis II es ecuacional como la mitosis."),
                ProcessingResult.DetectedSubtopic(title: "Entrecruzamiento y recombinación", content: "El crossing over en profase I intercambia material genético entre homólogos."),
                ProcessingResult.DetectedSubtopic(title: "Gametogénesis", content: "Proceso de formación de gametos: espermatogénesis y ovogénesis.")
            ],
            confidence: 0.75
        ),
        ProcessingResult.DetectedTopic(
            title: "Respiración Celular",
            shortSummary: "La respiración celular convierte glucosa en ATP, la moneda energética de la célula.",
            fullSummary: "La respiración celular es el proceso metabólico mediante el cual las células convierten glucosa y oxígeno en ATP (adenosín trifosfato), la principal molécula de energía. Consta de tres etapas: Glucólisis (en el citoplasma, convierte glucosa en 2 moléculas de piruvato, produciendo 2 ATP y 2 NADH), Ciclo de Krebs (en la matriz mitocondrial, oxida el acetil-CoA produciendo CO2, NADH, FADH2 y GTP), y Cadena de Transporte de Electrones (en la membrana interna mitocondrial, genera la mayoría del ATP mediante fosforilación oxidativa). En total, una molécula de glucosa produce aproximadamente 36-38 ATP.",
            subtopics: [],
            confidence: 0.91
        ),
        ProcessingResult.DetectedTopic(
            title: "Fotosíntesis",
            shortSummary: "La fotosíntesis transforma energía luminosa en energía química almacenada en glucosa.",
            fullSummary: "La fotosíntesis es el proceso mediante el cual los organismos fotoautótrofos convierten energía luminosa en energía química almacenada en glucosa. Ocurre en los cloroplastos y se divide en dos fases: la Fase Lumínica (en los tilacoides, donde la clorofila absorbe luz para producir ATP y NADPH, liberando O2 por fotólisis del agua) y el Ciclo de Calvin (en el estroma, donde se fija CO2 usando ATP y NADPH para sintetizar glucosa). La ecuación general es: 6CO2 + 6H2O + luz → C6H12O6 + 6O2.",
            subtopics: [],
            confidence: 0.68
        )
    ]
    
    private let historyTopics: [ProcessingResult.DetectedTopic] = [
        ProcessingResult.DetectedTopic(
            title: "Revolución Mexicana",
            shortSummary: "Conflicto armado iniciado en 1910 que transformó la estructura política y social de México.",
            fullSummary: "La Revolución Mexicana fue un conflicto armado que inició en 1910 contra la dictadura de Porfirio Díaz. Francisco I. Madero proclamó el Plan de San Luis, llamando al levantamiento. Líderes como Emiliano Zapata (Plan de Ayala, reforma agraria), Pancho Villa (División del Norte) y Venustiano Carranza jugaron roles clave. Culminó con la Constitución de 1917, una de las más avanzadas de su época, que incluyó derechos laborales, reforma agraria y separación Iglesia-Estado.",
            subtopics: [],
            confidence: 0.85
        ),
        ProcessingResult.DetectedTopic(
            title: "El Porfiriato",
            shortSummary: "Periodo de gobierno de Porfirio Díaz (1876-1911) caracterizado por modernización y desigualdad.",
            fullSummary: "El Porfiriato fue el periodo de gobierno de Porfirio Díaz que duró más de 30 años. Se caracterizó por la modernización económica (ferrocarriles, industria, inversión extranjera) pero también por una enorme desigualdad social, represión política y concentración de tierras. La frase 'orden y progreso' definió su gobierno. La desigualdad y el descontento eventualmente llevaron a la Revolución Mexicana.",
            subtopics: [],
            confidence: 0.80
        ),
        ProcessingResult.DetectedTopic(
            title: "México Independiente",
            shortSummary: "Periodo posterior a 1821 marcado por inestabilidad política y la búsqueda de identidad nacional.",
            fullSummary: "Tras la independencia en 1821, México enfrentó décadas de inestabilidad: el breve imperio de Iturbide, la república federal vs centralista, la pérdida de Texas y la guerra con Estados Unidos (1846-1848). La Reforma liberal de Juárez y la intervención francesa marcaron el siglo XIX.",
            subtopics: [],
            confidence: 0.77
        )
    ]
    
    private let calculusTopics: [ProcessingResult.DetectedTopic] = [
        ProcessingResult.DetectedTopic(
            title: "Límites",
            shortSummary: "El concepto de límite describe el comportamiento de una función al acercarse a un punto.",
            fullSummary: "El límite de una función f(x) cuando x tiende a un valor 'a' es el valor al que se aproxima f(x) conforme x se acerca a 'a'. Es el concepto fundamental del cálculo. Propiedades: el límite de una suma es la suma de los límites, el límite de un producto es el producto de los límites. Los límites laterales (por la izquierda y por la derecha) deben coincidir para que el límite exista.",
            subtopics: [],
            confidence: 0.86
        ),
        ProcessingResult.DetectedTopic(
            title: "Derivadas",
            shortSummary: "La derivada mide la tasa de cambio instantánea de una función.",
            fullSummary: "La derivada de una función f(x) se define como el límite del cociente diferencial cuando el incremento tiende a cero. Geométricamente, es la pendiente de la recta tangente a la curva. Reglas básicas: potencia (d/dx x^n = nx^(n-1)), producto, cociente y cadena. Las derivadas se aplican en optimización, tasas relacionadas y análisis de funciones.",
            subtopics: [],
            confidence: 0.89
        ),
        ProcessingResult.DetectedTopic(
            title: "Aplicaciones de la Derivada",
            shortSummary: "Las derivadas se usan para encontrar máximos, mínimos y analizar el comportamiento de funciones.",
            fullSummary: "Las aplicaciones principales incluyen: encontrar máximos y mínimos (igualando la derivada a cero), determinar intervalos de crecimiento y decrecimiento, analizar concavidad (con la segunda derivada), resolver problemas de optimización y calcular tasas de cambio relacionadas.",
            subtopics: [],
            confidence: 0.83
        )
    ]
    
    // MARK: - Summary Bank
    
    private let summaries: [String: String] = [
        "celula_short": "La célula es la unidad básica de la vida. Se compone de membrana, citoplasma y material genético.",
        "celula_medium": "La célula es la unidad estructural y funcional de todos los seres vivos. Las células eucariotas contienen organelos especializados como mitocondrias, retículo endoplásmico y núcleo. Cada organelo cumple funciones específicas para mantener la vida celular.",
        "celula_long": "La célula es la unidad estructural y funcional básica de todos los seres vivos. Existen dos tipos principales: procariotas y eucariotas. Las células eucariotas contienen organelos membranosos especializados. La membrana plasmática regula el transporte, el núcleo contiene el ADN, las mitocondrias producen ATP, y el retículo endoplásmico sintetiza proteínas y lípidos.",
        "mitosis_short": "La mitosis produce dos células hijas genéticamente idénticas para crecimiento y reparación.",
        "mitosis_medium": "La mitosis es la división celular que genera dos células idénticas. Pasa por profase, metafase, anafase y telofase, seguida de citocinesis. Es esencial para el crecimiento y la reparación de tejidos.",
        "respiracion_short": "La respiración celular convierte glucosa en ATP a través de glucólisis, ciclo de Krebs y cadena de electrones.",
        "fotosintesis_short": "La fotosíntesis transforma energía luminosa en glucosa usando CO2 y agua, liberando oxígeno."
    ]
    
    private let explanations: [String: String] = [
        "analogy_celula": "Imagina la célula como una ciudad. La membrana es la muralla que controla el acceso. El núcleo es el ayuntamiento con los planos. Las mitocondrias son las centrales eléctricas. El RE son las carreteras de transporte. Y los ribosomas son las fábricas de herramientas."
    ]
    
    private let relationships: [String: String] = [
        "mitosis_meiosis": "Ambos son procesos de división celular, pero la mitosis produce 2 células idénticas para crecimiento, mientras que la meiosis produce 4 células haploides para reproducción. La meiosis incluye crossing over para variabilidad genética.",
        "respiracion_fotosintesis": "Son procesos complementarios: la fotosíntesis produce glucosa y O2 usando luz y CO2, mientras que la respiración celular consume glucosa y O2 para producir ATP y CO2. Juntos forman un ciclo energético."
    ]
    
    private let genericSummary = "Este tema aborda conceptos fundamentales. Los puntos principales incluyen definiciones, características clave y aplicaciones prácticas que se interrelacionan para formar una comprensión completa."
    
    private let genericExplanation = "Imagina este concepto como una máquina con engranajes. Cada parte cumple una función específica, y cuando todas trabajan juntas, el resultado es mayor que la suma de las partes."
    
    private let genericRelation = "Estos conceptos están conectados porque comparten mecanismos fundamentales. La diferencia principal radica en su función y resultado final."
    
    private let genericFallback = "Basándome en tus apuntes, puedo ayudarte con este tema. Este concepto se relaciona con los fundamentos que has estudiado. ¿Quieres que profundice, que genere un resumen, o que prepare un quiz?"
    
    private func findSummaryKey(_ topic: String, _ length: String) -> String {
        if topic.contains("célula") || topic.contains("estructura") { return "celula_\(length)" }
        if topic.contains("mitosis") { return "mitosis_\(length)" }
        if topic.contains("respiración") { return "respiracion_\(length)" }
        if topic.contains("fotosíntesis") { return "fotosintesis_\(length)" }
        return "celula_\(length)"
    }
}

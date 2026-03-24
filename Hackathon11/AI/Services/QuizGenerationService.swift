// QuizGenerationService.swift
// EchoStudy
// Generates quiz questions with 15+ pre-written questions for demo
// REQUIRES: QuizQuestion.swift, OralQuizViewModel.swift (QuizDifficulty)

import Foundation

actor QuizGenerationService {
    static let shared = QuizGenerationService()
    
    private init() {}
    
    // MARK: - Pre-written Questions (Biology)
    
    private let biologyQuestions: [(q: String, a: String, e: String)] = [
        (
            "¿Cuál es la función principal de la mitocondria?",
            "Producir ATP mediante la respiración celular",
            "La mitocondria es conocida como la central energética de la célula porque convierte glucosa y oxígeno en ATP, la principal molécula de energía celular."
        ),
        (
            "¿Qué diferencia hay entre mitosis y meiosis?",
            "La mitosis produce 2 células idénticas, la meiosis produce 4 células con la mitad de cromosomas",
            "La mitosis es para crecimiento y reparación de tejidos, mientras que la meiosis es para la producción de gametos en la reproducción sexual."
        ),
        (
            "¿En qué fase de la mitosis los cromosomas se alinean en el centro de la célula?",
            "En la metafase",
            "Durante la metafase, los cromosomas se alinean en el plano ecuatorial de la célula, unidos a las fibras del huso mitótico por sus centrómeros."
        ),
        (
            "¿Cuál es la función de la membrana plasmática?",
            "Regular el paso de sustancias hacia dentro y fuera de la célula",
            "La membrana plasmática es una barrera selectivamente permeable compuesta de una bicapa de fosfolípidos con proteínas incrustadas."
        ),
        (
            "¿Qué organelo se encarga de la síntesis de proteínas?",
            "El ribosoma",
            "Los ribosomas traducen el ARN mensajero en cadenas de aminoácidos. Pueden estar libres en el citoplasma o adheridos al retículo endoplásmico rugoso."
        ),
        (
            "¿Cuáles son los productos finales de la glucólisis?",
            "Dos moléculas de piruvato, 2 ATP y 2 NADH",
            "La glucólisis ocurre en el citoplasma y es la primera etapa de la respiración celular. No requiere oxígeno."
        ),
        (
            "¿Dónde ocurre el ciclo de Krebs?",
            "En la matriz mitocondrial",
            "El ciclo de Krebs, también llamado ciclo del ácido cítrico, ocurre en la matriz de la mitocondria y genera CO2, NADH, FADH2 y GTP."
        ),
        (
            "¿Qué es el crossing over y en qué fase ocurre?",
            "Es el intercambio de segmentos entre cromosomas homólogos, ocurre en la profase I de la meiosis",
            "El crossing over aumenta la variabilidad genética al intercambiar material entre cromátidas no hermanas de cromosomas homólogos."
        ),
        (
            "¿Cuál es la diferencia entre células procariotas y eucariotas?",
            "Las eucariotas tienen núcleo definido con membrana, las procariotas no",
            "Las células eucariotas también tienen organelos membranosos como mitocondrias y retículo endoplásmico, mientras las procariotas tienen una organización más simple."
        ),
        (
            "¿Qué pigmento es esencial para la fotosíntesis?",
            "La clorofila",
            "La clorofila absorbe luz roja y azul, reflejando el verde. Se encuentra en los tilacoides de los cloroplastos y es clave en la fase lumínica."
        ),
        (
            "¿En qué consiste la fase lumínica de la fotosíntesis?",
            "Convierte energía luminosa en ATP y NADPH, liberando oxígeno",
            "La fase lumínica ocurre en los tilacoides del cloroplasto. El agua se descompone (fotólisis) liberando oxígeno como subproducto."
        ),
        (
            "¿Qué es la citocinesis?",
            "La división del citoplasma que separa físicamente las dos células hijas",
            "La citocinesis ocurre después de la telofase. En células animales se forma un surco de división; en vegetales, una placa celular."
        ),
        (
            "¿Cuántas moléculas de ATP se producen en la respiración celular completa?",
            "Aproximadamente 36 a 38 moléculas de ATP por glucosa",
            "La glucólisis produce 2 ATP, el ciclo de Krebs 2 GTP, y la cadena de transporte de electrones produce la mayoría: 32-34 ATP."
        ),
        (
            "¿Qué función tiene el retículo endoplásmico liso?",
            "Síntesis de lípidos y detoxificación",
            "El retículo endoplásmico liso carece de ribosomas y está involucrado en la síntesis de lípidos, el metabolismo de carbohidratos y la detoxificación de sustancias."
        ),
        (
            "¿Qué es la gametogénesis?",
            "El proceso de formación de gametos (óvulos y espermatozoides) mediante meiosis",
            "La gametogénesis incluye la espermatogénesis en hombres y la ovogénesis en mujeres. Ambos procesos usan meiosis para producir células haploides."
        )
    ]
    
    // MARK: - History Questions
    
    private let historyQuestions: [(q: String, a: String, e: String)] = [
        (
            "¿En qué año inició la Revolución Mexicana?",
            "En 1910",
            "La Revolución Mexicana comenzó el 20 de noviembre de 1910 con el Plan de San Luis proclamado por Francisco I. Madero contra la reelección de Porfirio Díaz."
        ),
        (
            "¿Quién fue el principal líder del movimiento zapatista?",
            "Emiliano Zapata",
            "Emiliano Zapata lideró el movimiento agrario del sur de México con el lema 'Tierra y Libertad' y el Plan de Ayala que demandaba la restitución de tierras."
        ),
        (
            "¿Cuántos años duró el Porfiriato?",
            "Más de 30 años, de 1876 a 1911",
            "El periodo de Porfirio Díaz se caracterizó por modernización económica pero gran desigualdad social, lo que eventualmente desencadenó la Revolución."
        )
    ]
    
    // MARK: - Calculus Questions
    
    private let calculusQuestions: [(q: String, a: String, e: String)] = [
        (
            "¿Qué es un límite en cálculo?",
            "El valor al que se aproxima una función cuando la variable se acerca a un punto determinado",
            "El límite describe el comportamiento de una función cerca de un punto, aunque la función no esté definida en ese punto exacto."
        ),
        (
            "¿Cuál es la derivada de x al cuadrado?",
            "2x",
            "Aplicando la regla de la potencia: la derivada de x^n es n·x^(n-1). Para x², la derivada es 2·x^1 = 2x."
        ),
        (
            "¿Qué representa geométricamente la derivada de una función en un punto?",
            "La pendiente de la recta tangente a la curva en ese punto",
            "La derivada nos da la tasa de cambio instantánea de la función, que geométricamente es la inclinación de la tangente."
        )
    ]
    
    // MARK: - Public API
    
    /// Generates quiz questions from a topic with realistic delay
    func generateQuestions(from topic: Topic, count: Int = 5, difficulty: QuizDifficulty = .intermediate) async -> [QuizQuestion] {
        // Realistic delay
        try? await Task.sleep(for: .seconds(2.5))
        
        let title = topic.title.lowercased()
        
        // Select appropriate question bank
        var bank: [(q: String, a: String, e: String)]
        if title.contains("célula") || title.contains("mitosis") || title.contains("meiosis")
            || title.contains("respiración") || title.contains("fotosíntesis")
            || title.contains("biología") {
            bank = biologyQuestions
        } else if title.contains("revolución") || title.contains("porfiriato") || title.contains("historia") || title.contains("independ") {
            bank = historyQuestions
        } else if title.contains("límite") || title.contains("derivada") || title.contains("cálculo") {
            bank = calculusQuestions
        } else {
            // Default: biology
            bank = biologyQuestions
        }
        
        bank.shuffle()
        let selected = Array(bank.prefix(count))
        
        return selected.map { item in
            QuizQuestion(
                questionText: item.q,
                correctAnswer: item.a,
                explanation: item.e
            )
        }
    }
    
    /// Evaluates a user answer against the correct answer using keyword matching
    func evaluateAnswer(userAnswer: String, correctAnswer: String) -> (isCorrect: Bool, score: Float) {
        let userWords = Set(userAnswer.lowercased().components(separatedBy: .whitespaces).filter { $0.count > 3 })
        let correctWords = Set(correctAnswer.lowercased().components(separatedBy: .whitespaces).filter { $0.count > 3 })
        
        guard !correctWords.isEmpty else { return (false, 0) }
        
        let matches = userWords.intersection(correctWords).count
        let score = Float(matches) / Float(correctWords.count)
        
        return (score >= 0.6, score)
    }
}

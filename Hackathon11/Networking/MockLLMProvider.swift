// MockLLMProvider.swift
// EchoStudy
// Mock LLM responses for development

import Foundation

actor MockLLMProvider {
    static let shared = MockLLMProvider()
    
    private init() {}
    
    func generate(prompt: String, systemPrompt: String? = nil) async -> String {
        // Simulate network delay
        try? await Task.sleep(for: .seconds(1))
        
        let lowered = prompt.lowercased()
        
        if lowered.contains("resumen") || lowered.contains("summary") {
            return mockSummary()
        } else if lowered.contains("quiz") || lowered.contains("pregunta") {
            return mockQuizQuestion()
        } else if lowered.contains("explica") || lowered.contains("explain") {
            return mockExplanation()
        } else if lowered.contains("relaciona") || lowered.contains("relate") {
            return mockRelation()
        }
        
        return mockGenericResponse()
    }
    
    private func mockSummary() -> String {
        "Este tema aborda los conceptos fundamentales de la materia. Los puntos principales incluyen la definición, las características clave y las aplicaciones prácticas. Es importante comprender cómo estos elementos se relacionan entre sí para tener una visión completa del tema."
    }
    
    private func mockQuizQuestion() -> String {
        "¿Cuál es la función principal del proceso descrito en el material? La respuesta correcta se relaciona con la transformación y regulación de los componentes celulares."
    }
    
    private func mockExplanation() -> String {
        "Imagina que este concepto es como una fábrica. Cada parte tiene una función específica: algunas partes producen energía, otras transportan materiales, y otras controlan qué entra y qué sale. Todo trabaja en conjunto para mantener el sistema funcionando correctamente."
    }
    
    private func mockRelation() -> String {
        "Estos dos temas están conectados porque ambos involucran procesos de transformación de energía. El primer tema describe cómo se captura la energía, mientras que el segundo explica cómo se utiliza. Juntos, forman un ciclo completo."
    }
    
    private func mockGenericResponse() -> String {
        "Basándome en el material disponible, puedo ayudarte con este tema. ¿Te gustaría que profundice en algún aspecto específico, que genere un resumen, o que prepare preguntas de repaso?"
    }
}

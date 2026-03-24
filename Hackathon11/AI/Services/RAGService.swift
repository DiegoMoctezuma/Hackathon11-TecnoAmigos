// RAGService.swift
// EchoStudy
// Retrieval-Augmented Generation over student materials
// REQUIRES: MockLLMProvider.swift

import Foundation
import SwiftData

// MARK: - RAG Types

enum RAGScope {
    case subject(Subject)
    case topic(Topic)
    case allMaterials
}

struct RAGResponse {
    var answer: String
    var relevantFragments: [String]
    var confidence: Float
    var sourceDescriptions: [String]
}

// MARK: - Service

actor RAGService {
    static let shared = RAGService()
    
    private init() {}
    
    /// Queries student materials and generates a grounded response
    func query(_ question: String, scope: RAGScope) async throws -> RAGResponse {
        // Realistic delay
        try await Task.sleep(for: .seconds(1.5))
        
        // Use MockLLMProvider for response
        let context = buildContext(for: scope)
        let response = await MockLLMProvider.shared.assistantResponse(
            userMessage: question,
            context: context
        )
        
        return RAGResponse(
            answer: response,
            relevantFragments: extractRelevantFragments(question: question, scope: scope),
            confidence: Float.random(in: 0.72...0.91),
            sourceDescriptions: sourceDescriptions(for: scope)
        )
    }
    
    /// Searches for relevant content in student notes
    func searchInNotes(query: String, scope: RAGScope) async throws -> [String] {
        try await Task.sleep(for: .seconds(1.0))
        return extractRelevantFragments(question: query, scope: scope)
    }
    
    // MARK: - Private
    
    private func buildContext(for scope: RAGScope) -> String {
        switch scope {
        case .subject(let subject):
            return "materia:\(subject.name)"
        case .topic(let topic):
            return "tema:\(topic.title)"
        case .allMaterials:
            return "general"
        }
    }
    
    private func extractRelevantFragments(question: String, scope: RAGScope) -> [String] {
        // Mock fragments based on question keywords
        let lowered = question.lowercased()
        
        if lowered.contains("célula") || lowered.contains("celular") {
            return [
                "La célula es la unidad básica de la vida, compuesta por membrana, citoplasma y material genético.",
                "Las células eucariotas tienen organelos membranosos como mitocondrias, retículo endoplásmico y aparato de Golgi."
            ]
        } else if lowered.contains("mitosis") {
            return [
                "La mitosis consta de cuatro fases: profase, metafase, anafase y telofase.",
                "En la mitosis, una célula madre se divide para producir dos células hijas genéticamente idénticas."
            ]
        } else if lowered.contains("meiosis") {
            return [
                "La meiosis produce cuatro células haploides a partir de una célula diploide.",
                "El crossing over en la profase I permite el intercambio de material genético entre cromosomas homólogos."
            ]
        } else if lowered.contains("respiración") {
            return [
                "La respiración celular convierte glucosa en ATP a través de glucólisis, ciclo de Krebs y cadena de electrones.",
                "Se producen aproximadamente 36-38 ATP por cada molécula de glucosa oxidada completamente."
            ]
        }
        
        return [
            "Basándome en tus apuntes, este concepto se relaciona con los temas principales de la materia.",
            "Los materiales procesados contienen información relevante sobre este tema."
        ]
    }
    
    private func sourceDescriptions(for scope: RAGScope) -> [String] {
        switch scope {
        case .subject(let subject):
            return ["Apuntes de \(subject.name)", "Materiales procesados de \(subject.name)"]
        case .topic(let topic):
            return ["Resumen de \(topic.title)", "Subtemas relacionados"]
        case .allMaterials:
            return ["Todos los materiales del estudiante"]
        }
    }
}

// AIServiceManager.swift
// EchoStudy
// Singleton orchestrating all AI services

import Foundation
import UIKit

@Observable
@MainActor
final class AIServiceManager {
    static let shared = AIServiceManager()
    
    // MARK: - State
    var isProcessing: Bool = false
    var currentStep: ProcessingStep = .idle
    var progress: Float = 0.0
    var errorMessage: String?
    
    enum ProcessingStep: String {
        case idle = "Listo"
        case readingImage = "Leyendo imagen..."
        case extractingText = "Extrayendo texto..."
        case analyzingStructure = "Analizando estructura visual..."
        case detectingTopics = "Detectando temas..."
        case generatingSummaries = "Generando resúmenes..."
        case complete = "¡Procesamiento completado!"
        case error = "Error en el procesamiento"
        
        var accessibilityLabel: String { rawValue }
    }
    
    private init() {}
    
    // MARK: - Full Processing Pipeline
    
    func processImage(_ image: UIImage) async -> ProcessingResult? {
        isProcessing = true
        progress = 0.0
        errorMessage = nil
        
        do {
            // Step 1: OCR
            currentStep = .extractingText
            progress = 0.2
            let extractedText = try await OCRService.shared.extractText(from: image)
            
            guard !extractedText.isEmpty else {
                errorMessage = "No se detectó texto en la imagen"
                currentStep = .error
                isProcessing = false
                return nil
            }
            
            // Step 2: Visual analysis
            currentStep = .analyzingStructure
            progress = 0.4
            let visualDescription = try await ImageDescriptionService.shared.describeImage(image)
            
            // Step 3: Topic extraction
            currentStep = .detectingTopics
            progress = 0.6
            let topics = await TopicExtractionService.shared.extractTopics(from: extractedText)
            
            // Step 4: Summary generation
            currentStep = .generatingSummaries
            progress = 0.8
            var enrichedTopics: [ProcessingResult.DetectedTopic] = []
            for topic in topics {
                let shortSummary = await SummaryGenerationService.shared.generateSummary(from: topic.fullSummary, length: .short)
                let enriched = ProcessingResult.DetectedTopic(
                    title: topic.title,
                    shortSummary: shortSummary,
                    fullSummary: topic.fullSummary,
                    subtopics: topic.subtopics,
                    confidence: topic.confidence
                )
                enrichedTopics.append(enriched)
            }
            
            // Complete
            currentStep = .complete
            progress = 1.0
            isProcessing = false
            
            let overallConfidence = enrichedTopics.isEmpty ? Float(0) :
                enrichedTopics.map(\.confidence).reduce(0, +) / Float(enrichedTopics.count)
            
            return ProcessingResult(
                extractedText: extractedText,
                visualDescription: visualDescription,
                detectedTopics: enrichedTopics,
                overallConfidence: overallConfidence
            )
            
        } catch {
            errorMessage = error.localizedDescription
            currentStep = .error
            isProcessing = false
            return nil
        }
    }
    
    func reset() {
        isProcessing = false
        currentStep = .idle
        progress = 0.0
        errorMessage = nil
    }
}

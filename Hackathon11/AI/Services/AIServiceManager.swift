// AIServiceManager.swift
// EchoStudy
// Singleton orchestrating all AI services with mock/real toggle
// REQUIRES: OCRService.swift, ImageDescriptionService.swift, TopicExtractionService.swift,
//           SummaryGenerationService.swift, MockLLMProvider.swift

import Foundation
import UIKit

@Observable
@MainActor
final class AIServiceManager {
    static let shared = AIServiceManager()
    
    // MARK: - Mock Toggle
    /// true = use mock data (for demo), false = use real pipeline
    var useMockData: Bool = true
    
    // MARK: - State
    var isProcessing: Bool = false
    var currentStep: ProcessingStep = .idle
    var progress: Float = 0.0
    var errorMessage: String?
    var retryCount: Int = 0
    private let maxRetries = 2
    
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
        
        var stepIndex: Int {
            switch self {
            case .idle: return 0
            case .readingImage: return 1
            case .extractingText: return 2
            case .analyzingStructure: return 3
            case .detectingTopics: return 4
            case .generatingSummaries: return 5
            case .complete: return 6
            case .error: return -1
            }
        }
    }
    
    private init() {}
    
    // MARK: - Full Processing Pipeline
    
    func processImage(_ image: UIImage) async -> ProcessingResult? {
        isProcessing = true
        progress = 0.0
        errorMessage = nil
        retryCount = 0
        
        if useMockData {
            return await processMockPipeline(image)
        } else {
            return await processRealPipeline(image)
        }
    }
    
    // MARK: - Mock Pipeline (for demo)
    
    private func processMockPipeline(_ image: UIImage) async -> ProcessingResult? {
        do {
            // Step 1: OCR (REAL - uses Vision framework)
            currentStep = .extractingText
            progress = 0.15
            let extractedText: String
            do {
                extractedText = try await OCRService.shared.extractText(from: image)
            } catch {
                // If OCR fails on the image, use a placeholder
                extractedText = "Contenido del pizarrón procesado"
            }
            
            // Step 2: Visual analysis (real delay simulating analysis)
            currentStep = .analyzingStructure
            progress = 0.35
            try await Task.sleep(for: .seconds(1.5))
            let visualDescription = "Documento con texto manuscrito y diagramas detectados."
            
            // Step 3: Topic extraction (MOCK with delay)
            currentStep = .detectingTopics
            progress = 0.55
            let mockTopics = await MockLLMProvider.shared.extractTopics(from: extractedText)
            
            // Step 4: Summary generation (MOCK with delay)
            currentStep = .generatingSummaries
            progress = 0.80
            try await Task.sleep(for: .seconds(1.5))
            
            // Complete
            currentStep = .complete
            progress = 1.0
            isProcessing = false
            
            let overallConfidence = mockTopics.isEmpty ? Float(0.75) :
                mockTopics.map(\.confidence).reduce(0, +) / Float(mockTopics.count)
            
            return ProcessingResult(
                extractedText: extractedText.isEmpty ? "Texto extraído del material procesado" : extractedText,
                visualDescription: visualDescription,
                detectedTopics: mockTopics,
                overallConfidence: overallConfidence
            )
        } catch {
            errorMessage = error.localizedDescription
            currentStep = .error
            isProcessing = false
            return nil
        }
    }
    
    // MARK: - Real Pipeline (for production)
    
    private func processRealPipeline(_ image: UIImage) async -> ProcessingResult? {
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
                let shortSummary = await SummaryGenerationService.shared.generateLocalSummary(from: topic.fullSummary, length: .short)
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
            // Retry on failure
            if retryCount < maxRetries {
                retryCount += 1
                try? await Task.sleep(for: .seconds(1))
                return await processRealPipeline(image)
            }
            
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
        retryCount = 0
    }
}

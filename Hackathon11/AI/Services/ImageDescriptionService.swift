// ImageDescriptionService.swift
// EchoStudy
// Vision: Describe visual structures (diagrams, maps, graphs)
// REQUIRES: OCRService.swift

import Foundation
import Vision
import UIKit

// MARK: - Visual Description Model

struct VisualDescription {
    var imageType: ImageType
    var overallDescription: String
    var textBlocks: [TextBlock]
    var rectangleCount: Int
    var hasStructuredLayout: Bool
    
    enum ImageType: String {
        case textDocument = "Documento de texto"
        case diagram = "Diagrama"
        case mindMap = "Mapa mental"
        case table = "Tabla"
        case mixedContent = "Contenido mixto"
        case unknown = "Imagen"
    }
    
    struct TextBlock: Identifiable {
        let id = UUID()
        var text: String
        var bounds: CGRect
        var isTitle: Bool
    }
    
    /// Generates a structured accessibility-friendly description
    var accessibleDescription: String {
        var parts: [String] = []
        parts.append("\(imageType.rawValue) detectado.")
        parts.append(overallDescription)
        
        let titles = textBlocks.filter(\.isTitle)
        if !titles.isEmpty {
            parts.append("Títulos encontrados: \(titles.map(\.text).joined(separator: ", ")).")
        }
        
        if rectangleCount > 0 {
            parts.append("\(rectangleCount) elementos rectangulares detectados.")
        }
        
        return parts.joined(separator: " ")
    }
}

// MARK: - Service

actor ImageDescriptionService {
    static let shared = ImageDescriptionService()
    
    private init() {}
    
    /// Analyzes image and returns a structured visual description
    func describeVisualStructure(from image: UIImage) async throws -> VisualDescription {
        guard let cgImage = image.cgImage else {
            throw ImageAnalysisError.invalidImage
        }
        
        // Run analyses in parallel
        async let rectanglesResult = detectRectangles(in: cgImage)
        async let textBlocksResult = detectTextBlocks(in: cgImage)
        
        let rectangles = (try? await rectanglesResult) ?? []
        let textBlocks = (try? await textBlocksResult) ?? []
        
        // Determine image type
        let imageType = classifyImage(rectangleCount: rectangles.count, textBlockCount: textBlocks.count)
        
        // Build description
        let description = buildDescription(imageType: imageType, textBlocks: textBlocks, rectangleCount: rectangles.count)
        
        // Identify titles (larger text blocks at top)
        let processedBlocks = textBlocks.map { block in
            let isTitle = block.bounds.origin.y > 0.7 && block.text.count < 60 // Vision uses flipped Y
            return VisualDescription.TextBlock(text: block.text, bounds: block.bounds, isTitle: isTitle)
        }
        
        return VisualDescription(
            imageType: imageType,
            overallDescription: description,
            textBlocks: processedBlocks,
            rectangleCount: rectangles.count,
            hasStructuredLayout: rectangles.count > 2 || textBlocks.count > 5
        )
    }
    
    /// Simple string description for backward compatibility
    func describeImage(_ image: UIImage) async throws -> String {
        let visual = try await describeVisualStructure(from: image)
        return visual.accessibleDescription
    }
    
    // MARK: - Classification
    
    private func classifyImage(rectangleCount: Int, textBlockCount: Int) -> VisualDescription.ImageType {
        if rectangleCount > 5 && textBlockCount > 5 {
            return .mindMap
        } else if rectangleCount > 3 {
            return .diagram
        } else if textBlockCount > 10 {
            return .textDocument
        } else if rectangleCount > 0 && textBlockCount > 3 {
            return .mixedContent
        }
        return .textDocument
    }
    
    private func buildDescription(imageType: VisualDescription.ImageType, textBlocks: [(text: String, bounds: CGRect)], rectangleCount: Int) -> String {
        var parts: [String] = []
        
        switch imageType {
        case .mindMap:
            // Find central node (closest to center)
            let centerBlocks = textBlocks.sorted { abs($0.bounds.midX - 0.5) + abs($0.bounds.midY - 0.5) < abs($1.bounds.midX - 0.5) + abs($1.bounds.midY - 0.5) }
            if let central = centerBlocks.first {
                parts.append("Mapa mental con nodo central '\(central.text)' y \(rectangleCount - 1) ramas.")
            }
        case .diagram:
            parts.append("Diagrama con \(rectangleCount) elementos conectados y \(textBlocks.count) bloques de texto.")
        case .table:
            parts.append("Tabla con \(textBlocks.count) celdas de texto detectadas.")
        case .textDocument:
            parts.append("Documento con \(textBlocks.count) líneas de texto detectadas.")
        case .mixedContent:
            parts.append("Contenido mixto con \(rectangleCount) elementos gráficos y \(textBlocks.count) bloques de texto.")
        case .unknown:
            parts.append("Imagen analizada con \(textBlocks.count) elementos de texto.")
        }
        
        return parts.joined(separator: " ")
    }
    
    // MARK: - Vision Requests
    
    private func detectRectangles(in cgImage: CGImage) async throws -> [VNRectangleObservation] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectRectanglesRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let results = request.results as? [VNRectangleObservation] ?? []
                continuation.resume(returning: results)
            }
            request.maximumObservations = 20
            request.minimumConfidence = 0.5
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func detectTextBlocks(in cgImage: CGImage) async throws -> [(text: String, bounds: CGRect)] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let results = observations.compactMap { obs -> (String, CGRect)? in
                    guard let text = obs.topCandidates(1).first?.string else { return nil }
                    return (text, obs.boundingBox)
                }
                continuation.resume(returning: results)
            }
            request.recognitionLevel = .fast
            request.recognitionLanguages = ["es", "en"]
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

enum ImageAnalysisError: LocalizedError {
    case invalidImage
    case analysisFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidImage: return "No se pudo analizar la imagen"
        case .analysisFailed: return "Error en el análisis visual"
        }
    }
}

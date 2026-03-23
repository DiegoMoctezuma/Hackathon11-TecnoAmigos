// ImageDescriptionService.swift
// EchoStudy
// Vision: Describe visual structures (diagrams, maps, graphs)

import Foundation
import Vision
import UIKit

actor ImageDescriptionService {
    static let shared = ImageDescriptionService()
    
    private init() {}
    
    /// Analyzes an image and returns a description of its visual structure
    func describeImage(_ image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw ImageAnalysisError.invalidImage
        }
        
        var descriptions: [String] = []
        
        // Detect rectangles (tables, boxes, diagram nodes)
        let rectangles = try await detectRectangles(in: cgImage)
        if !rectangles.isEmpty {
            descriptions.append("Se detectaron \(rectangles.count) elementos rectangulares, posiblemente un diagrama o tabla.")
        }
        
        // Detect text regions for layout analysis
        let textRegions = try await detectTextRegions(in: cgImage)
        if textRegions.count > 5 {
            descriptions.append("Contiene múltiples bloques de texto distribuidos en la imagen.")
        }
        
        // Detect if it has lines/arrows (flowchart indicators)
        let hasStructuredContent = rectangles.count > 2 && textRegions.count > 3
        if hasStructuredContent {
            descriptions.append("La estructura sugiere un diagrama de flujo o mapa conceptual.")
        }
        
        if descriptions.isEmpty {
            descriptions.append("Imagen con contenido textual general.")
        }
        
        return descriptions.joined(separator: " ")
    }
    
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
    
    private func detectTextRegions(in cgImage: CGImage) async throws -> [VNRecognizedTextObservation] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let results = request.results as? [VNRecognizedTextObservation] ?? []
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

// OCRService.swift
// EchoStudy
// Vision framework: Text extraction from images

import Foundation
import Vision
import UIKit

actor OCRService {
    static let shared = OCRService()
    
    private init() {}
    
    /// Extracts text from a UIImage using Vision OCR
    func extractText(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }
                
                let text = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")
                
                continuation.resume(returning: text)
            }
            
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["es", "en"]
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    /// Extracts text from image data
    func extractText(from data: Data) async throws -> String {
        guard let image = UIImage(data: data) else {
            throw OCRError.invalidImage
        }
        return try await extractText(from: image)
    }
}

enum OCRError: LocalizedError {
    case invalidImage
    case recognitionFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidImage: return "No se pudo procesar la imagen"
        case .recognitionFailed: return "Error en el reconocimiento de texto"
        }
    }
}

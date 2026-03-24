// OCRService.swift
// EchoStudy
// Vision framework: Text extraction from images with post-processing

import Foundation
import Vision
import UIKit

actor OCRService {
    static let shared = OCRService()
    
    private init() {}
    
    /// Extracts text from a UIImage using Vision OCR with .accurate level
    /// Supports Spanish and English. Post-processes to clean OCR artifacts.
    func extractText(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }
        
        let rawText = try await performOCR(on: cgImage)
        return postProcess(rawText)
    }
    
    /// Extracts text from image data
    func extractText(from data: Data) async throws -> String {
        guard let image = UIImage(data: data) else {
            throw OCRError.invalidImage
        }
        return try await extractText(from: image)
    }
    
    /// Extracts text with bounding box info for spatial analysis
    func extractTextWithPositions(from image: UIImage) async throws -> [(text: String, bounds: CGRect)] {
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
                    continuation.resume(returning: [])
                    return
                }
                
                let results = observations.compactMap { observation -> (String, CGRect)? in
                    guard let candidate = observation.topCandidates(1).first else { return nil }
                    return (candidate.string, observation.boundingBox)
                }
                
                continuation.resume(returning: results)
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
    
    // MARK: - Private
    
    private func performOCR(on cgImage: CGImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
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
    
    /// Post-processes OCR text: cleans artifacts, joins split lines, normalizes whitespace
    private func postProcess(_ text: String) -> String {
        var lines = text.components(separatedBy: "\n")
        
        // Remove empty lines and trim whitespace
        lines = lines.map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        // Join lines that were likely split mid-sentence
        var joined: [String] = []
        var currentLine = ""
        
        for line in lines {
            if currentLine.isEmpty {
                currentLine = line
            } else if looksLikeContinuation(currentLine: currentLine, nextLine: line) {
                currentLine += " " + line
            } else {
                joined.append(currentLine)
                currentLine = line
            }
        }
        if !currentLine.isEmpty {
            joined.append(currentLine)
        }
        
        // Clean common OCR artifacts
        var result = joined.joined(separator: "\n")
        result = cleanArtifacts(result)
        
        return result
    }
    
    /// Checks if the next line is a continuation of the current line
    private func looksLikeContinuation(currentLine: String, nextLine: String) -> Bool {
        let endsWithSentence = currentLine.hasSuffix(".") || currentLine.hasSuffix(":")
            || currentLine.hasSuffix("?") || currentLine.hasSuffix("!")
        let nextStartsWithUpperOrBullet = nextLine.first?.isUppercase == true
            || nextLine.first?.isNumber == true
            || nextLine.hasPrefix("•") || nextLine.hasPrefix("-")
        
        // If current line doesn't end a sentence AND next doesn't start a new one, join
        if !endsWithSentence && !nextStartsWithUpperOrBullet && currentLine.count < 80 {
            return true
        }
        return false
    }
    
    /// Cleans common OCR artifacts
    private func cleanArtifacts(_ text: String) -> String {
        var cleaned = text
        // Remove stray single characters that are likely noise
        cleaned = cleaned.replacingOccurrences(of: " \\| ", with: " ", options: .regularExpression)
        // Normalize multiple spaces
        cleaned = cleaned.replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
        // Fix common OCR confusions
        cleaned = cleaned.replacingOccurrences(of: "0rganelo", with: "Organelo")
        cleaned = cleaned.replacingOccurrences(of: "ce1ula", with: "célula")
        return cleaned
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

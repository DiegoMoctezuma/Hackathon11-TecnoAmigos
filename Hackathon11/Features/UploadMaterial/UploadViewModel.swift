// UploadViewModel.swift
// EchoStudy

import Foundation
import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers

@Observable
@MainActor
final class UploadViewModel {
    var selectedImage: UIImage?
    var selectedPhotoItem: PhotosPickerItem?
    var showCamera: Bool = false
    var showDocumentPicker: Bool = false
    var processingResult: ProcessingResult?
    var isProcessing: Bool = false
    var showResults: Bool = false
    var showMaterialAssignment: Bool = false
    var confirmedTopics: [ProcessingResult.DetectedTopic]?
    var recentMaterials: [StudyMaterial] = []
    
    func processSelectedImage(using aiManager: AIServiceManager) async {
        guard let image = selectedImage else { return }
        isProcessing = true
        
        let result = await aiManager.processImage(image)
        processingResult = result
        isProcessing = false
        
        if result != nil {
            showResults = true
        }
    }
    
    func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            selectedImage = image
        }
    }
    
    func processDocument(at url: URL, using aiManager: AIServiceManager) async {
        isProcessing = true
        
        // Read text from document
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        if let text = try? String(contentsOf: url, encoding: .utf8) {
            // Create a simple processing result from document text
            let topics = await TopicExtractionService.shared.extractTopics(from: text)
            var enrichedTopics: [ProcessingResult.DetectedTopic] = []
            
            for topic in topics {
                let shortSummary = (try? await SummaryGenerationService.shared.generateSummary(
                    for: topic.fullSummary, length: .short
                )) ?? topic.fullSummary
                enrichedTopics.append(ProcessingResult.DetectedTopic(
                    title: topic.title,
                    shortSummary: shortSummary,
                    fullSummary: topic.fullSummary,
                    subtopics: topic.subtopics,
                    confidence: topic.confidence
                ))
            }
            
            let overallConfidence = enrichedTopics.isEmpty ? Float(0) :
                enrichedTopics.map(\.confidence).reduce(0, +) / Float(enrichedTopics.count)
            
            processingResult = ProcessingResult(
                extractedText: text,
                detectedTopics: enrichedTopics,
                overallConfidence: overallConfidence
            )
            showResults = true
        }
        
        isProcessing = false
    }
}

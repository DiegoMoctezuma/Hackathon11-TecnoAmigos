// StudyMaterial.swift
// EchoStudy
// @Model: Uploaded material (photo, PDF, document)

import Foundation
import SwiftData

enum MaterialType: String, Codable {
    case photo
    case pdf
    case document
}

@Model
class StudyMaterial {
    var id: UUID
    var type: MaterialType
    var fileName: String
    var imageData: Data?
    var fileBookmark: Data?
    var extractedText: String
    var visualDescription: String?
    var processedAt: Date
    @Relationship(deleteRule: .nullify) var topics: [Topic]
    
    init(
        id: UUID = UUID(),
        type: MaterialType = .photo,
        fileName: String = "",
        imageData: Data? = nil,
        fileBookmark: Data? = nil,
        extractedText: String = "",
        visualDescription: String? = nil,
        processedAt: Date = Date(),
        topics: [Topic] = []
    ) {
        self.id = id
        self.type = type
        self.fileName = fileName
        self.imageData = imageData
        self.fileBookmark = fileBookmark
        self.extractedText = extractedText
        self.visualDescription = visualDescription
        self.processedAt = processedAt
        self.topics = topics
    }
}

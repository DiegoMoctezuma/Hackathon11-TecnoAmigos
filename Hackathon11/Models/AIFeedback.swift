// AIFeedback.swift
// EchoStudy
// @Model: Human-centered AI feedback for predictions

import Foundation
import SwiftData

@Model
class AIFeedback {
    var id: UUID
    var predictionId: String
    var predictionType: String
    var userRating: Bool
    var userCorrection: String?
    var voiceCorrection: Bool
    var timestamp: Date
    
    init(
        id: UUID = UUID(),
        predictionId: String,
        predictionType: String,
        userRating: Bool,
        userCorrection: String? = nil,
        voiceCorrection: Bool = false,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.predictionId = predictionId
        self.predictionType = predictionType
        self.userRating = userRating
        self.userCorrection = userCorrection
        self.voiceCorrection = voiceCorrection
        self.timestamp = timestamp
    }
}

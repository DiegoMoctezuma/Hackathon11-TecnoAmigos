// Subtopic.swift
// EchoStudy
// @Model: Subtopic within a topic

import Foundation
import SwiftData

@Model
class Subtopic {
    var id: UUID
    var title: String
    var content: String
    var topic: Topic?
    var orderIndex: Int
    
    init(
        id: UUID = UUID(),
        title: String,
        content: String = "",
        topic: Topic? = nil,
        orderIndex: Int = 0
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.topic = topic
        self.orderIndex = orderIndex
    }
}

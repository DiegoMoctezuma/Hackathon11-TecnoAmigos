// LLMAPIClient.swift
// EchoStudy
// Client for external LLM API (summaries, quiz, RAG)

import Foundation

actor LLMAPIClient {
    static let shared = LLMAPIClient()
    
    private let session: URLSession
    private var apiKey: String = ""
    private var baseURL: String = ""
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    func configure(apiKey: String, baseURL: String) {
        self.apiKey = apiKey
        self.baseURL = baseURL
    }
    
    /// Sends a prompt to the LLM and returns the response
    func complete(prompt: String, systemPrompt: String? = nil) async throws -> String {
        // In production, this would call a real LLM API
        // For now, use the mock provider
        return await MockLLMProvider.shared.generate(prompt: prompt, systemPrompt: systemPrompt)
    }
}

// AIResultView.swift
// EchoStudy
// A11Y: Generic composable view for AI results with confidence + transparency + feedback + override

import SwiftUI
import SwiftData

// MARK: - AIResultDisplayable Protocol

protocol AIResultDisplayable {
    var resultText: String { get }
    var confidence: Float { get }
    var explanation: String { get }
    var factors: [String] { get }
    var sourceDescription: String? { get }
}

// MARK: - Simple Implementation

struct SimpleAIResult: AIResultDisplayable {
    let resultText: String
    let confidence: Float
    let explanation: String
    var factors: [String] = []
    var sourceDescription: String? = nil
}

// MARK: - AI Result View

struct AIResultView<Content: View>: View {
    let result: any AIResultDisplayable
    let predictionId: String
    let predictionType: String
    var showOverride: Bool = true
    @ViewBuilder var content: () -> Content
    
    @State private var displayedText: String = ""
    @State private var isOverridden: Bool = false
    @State private var overriddenText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Main content
            VStack(alignment: .leading, spacing: 8) {
                content()
                
                // Result text with streaming effect
                Text(isOverridden ? overriddenText : displayedText)
                    .font(FontTheme.body)
                    .foregroundStyle(ColorTheme.adaptiveText)
                    .accessibilityLabel(isOverridden ? "Resultado corregido: \(overriddenText)" : displayedText)
                
                if isOverridden {
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill.checkmark")
                            .font(.caption2)
                        Text("Corregido por ti")
                            .font(FontTheme.caption)
                    }
                    .foregroundStyle(ColorTheme.successHex)
                    .accessibilityLabel("Este resultado fue corregido por el usuario")
                }
            }
            
            // Confidence indicator
            HStack {
                ConfidenceIndicator(
                    confidence: result.confidence,
                    showLabel: true,
                    size: 48
                )
                
                Spacer()
            }
            
            // Transparency card
            AITransparencyCard(
                explanation: result.explanation,
                confidence: result.confidence,
                factors: result.factors,
                sourceDescription: result.sourceDescription
            )
            
            // Human override
            if showOverride {
                HumanOverrideView(
                    originalText: result.resultText,
                    predictionId: predictionId,
                    predictionType: predictionType,
                    onOverride: { newText in
                        isOverridden = true
                        overriddenText = newText
                    }
                )
            }
            
            // Feedback collector
            FeedbackCollectorView(
                predictionId: predictionId,
                predictionType: predictionType
            )
        }
        .padding(16)
        .glassEffect(in: .rect(cornerRadius: 16))
        .task {
            await animateText()
        }
    }
    
    // MARK: - Streaming Text Animation
    
    private func animateText() async {
        let fullText = result.resultText
        displayedText = ""
        
        for character in fullText {
            displayedText.append(character)
            try? await Task.sleep(for: .milliseconds(15))
        }
    }
}

// MARK: - Convenience Init without custom content

extension AIResultView where Content == EmptyView {
    init(
        result: any AIResultDisplayable,
        predictionId: String,
        predictionType: String,
        showOverride: Bool = true
    ) {
        self.result = result
        self.predictionId = predictionId
        self.predictionType = predictionType
        self.showOverride = showOverride
        self.content = { EmptyView() }
    }
}

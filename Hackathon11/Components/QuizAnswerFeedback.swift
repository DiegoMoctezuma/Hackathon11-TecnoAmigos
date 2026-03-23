// QuizAnswerFeedback.swift
// EchoStudy
// A11Y: Quiz answer feedback with correct/incorrect + explanation

import SwiftUI

struct QuizAnswerFeedback: View {
    let isCorrect: Bool
    let explanation: String
    let correctAnswer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Result header
            HStack(spacing: 8) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(isCorrect ? ColorTheme.successHex : ColorTheme.errorHex)
                
                Text(isCorrect ? "¡Correcto!" : "Incorrecto")
                    .font(FontTheme.title3)
                    .foregroundStyle(isCorrect ? ColorTheme.successHex : ColorTheme.errorHex)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(isCorrect ? "Respuesta correcta" : "Respuesta incorrecta")
            
            if !isCorrect {
                Text("La respuesta correcta es: \(correctAnswer)")
                    .font(FontTheme.headline)
                    .foregroundStyle(ColorTheme.adaptiveText)
            }
            
            // Explanation
            Text(explanation)
                .font(FontTheme.body)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
        }
        .padding(16)
        .glassEffect(in: .rect(cornerRadius: 16))
        .announceOnAppear(
            isCorrect ?
            "Correcto. \(explanation)" :
            "Incorrecto. La respuesta correcta es \(correctAnswer). \(explanation)"
        )
    }
}

// FeedbackCollectorView.swift
// EchoStudy
// A11Y: HCAI feedback collector (thumbs up/down + voice correction)

import SwiftUI
import SwiftData

struct FeedbackCollectorView: View {
    let predictionId: String
    let predictionType: String
    @Environment(\.modelContext) private var modelContext
    @Environment(VoiceEngine.self) private var voiceEngine
    
    @State private var hasRated: Bool = false
    @State private var rating: Bool? = nil
    @State private var showCorrection: Bool = false
    @State private var correctionText: String = ""
    
    var body: some View {
        VStack(spacing: 8) {
            if !hasRated {
                HStack(spacing: 16) {
                    Text("¿Fue útil este resultado?")
                        .font(FontTheme.subheadline)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    
                    Spacer()
                    
                    Button {
                        submitFeedback(positive: true)
                    } label: {
                        Image(systemName: "hand.thumbsup.fill")
                            .font(.title3)
                            .foregroundStyle(ColorTheme.successHex)
                    }
                    .accessibilityLabel("Resultado útil")
                    .accessibleTapTarget()
                    
                    Button {
                        submitFeedback(positive: false)
                    } label: {
                        Image(systemName: "hand.thumbsdown.fill")
                            .font(.title3)
                            .foregroundStyle(ColorTheme.errorHex)
                    }
                    .accessibilityLabel("Resultado no útil")
                    .accessibleTapTarget()
                }
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(ColorTheme.successHex)
                    Text("Gracias por tu feedback")
                        .font(FontTheme.subheadline)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    
                    Spacer()
                    
                    if rating == false {
                        Button("Corregir") {
                            showCorrection = true
                        }
                        .font(FontTheme.caption)
                        .foregroundStyle(ColorTheme.accentHex)
                        .accessibilityLabel("Corregir el resultado")
                    }
                }
            }
            
            if showCorrection {
                HStack {
                    TextField("¿Cuál es la corrección?", text: $correctionText)
                        .textFieldStyle(GlassTextFieldStyle())
                        .accessibilityLabel("Escribe tu corrección")
                    
                    Button("Enviar") {
                        saveCorrection()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(correctionText.isEmpty)
                }
            }
        }
        .padding(12)
        .glassEffect(in: .rect(cornerRadius: 12))
    }
    
    private func submitFeedback(positive: Bool) {
        rating = positive
        hasRated = true
        HapticService.shared.light()
        
        let feedback = AIFeedback(
            predictionId: predictionId,
            predictionType: predictionType,
            userRating: positive
        )
        modelContext.insert(feedback)
        
        AccessibilityNotification.Announcement(
            positive ? "Marcado como útil. Gracias." : "Marcado como no útil. Puedes corregir el resultado."
        ).post()
    }
    
    private func saveCorrection() {
        let feedback = AIFeedback(
            predictionId: predictionId,
            predictionType: predictionType,
            userRating: false,
            userCorrection: correctionText,
            voiceCorrection: false
        )
        modelContext.insert(feedback)
        showCorrection = false
        HapticService.shared.success()
        
        AccessibilityNotification.Announcement("Corrección guardada. Gracias por mejorar EchoStudy.").post()
    }
}

// FeedbackCollectorView.swift
// EchoStudy
// A11Y: HCAI feedback collector (thumbs up/down + voice correction via microphone)

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
    @State private var isRecordingCorrection: Bool = false
    @State private var showThankYou: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            if !hasRated {
                ratingButtons
            } else if showThankYou && !showCorrection {
                thankYouRow
            }
            
            if showCorrection {
                correctionSection
            }
        }
        .padding(12)
        .glassEffect(in: .rect(cornerRadius: 12))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: hasRated)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showCorrection)
    }
    
    // MARK: - Rating Buttons
    
    private var ratingButtons: some View {
        HStack(spacing: 16) {
            Text("¿Fue útil este resultado?")
                .font(FontTheme.subheadline)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
            
            Spacer()
            
            Button {
                submitFeedback(positive: true)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "hand.thumbsup.fill")
                    Text("Sí")
                        .font(FontTheme.caption)
                }
                .font(.title3)
                .foregroundStyle(ColorTheme.successHex)
            }
            .accessibilityLabel("Resultado útil")
            .accessibleTapTarget()
            
            Button {
                submitFeedback(positive: false)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "hand.thumbsdown.fill")
                    Text("No")
                        .font(FontTheme.caption)
                }
                .font(.title3)
                .foregroundStyle(ColorTheme.errorHex)
            }
            .accessibilityLabel("Resultado no útil")
            .accessibleTapTarget()
        }
    }
    
    // MARK: - Thank You Row
    
    private var thankYouRow: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(ColorTheme.successHex)
            Text("Gracias por tu feedback")
                .font(FontTheme.subheadline)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
            
            Spacer()
            
            if rating == false {
                Button("Corregir") {
                    withAnimation {
                        showCorrection = true
                    }
                }
                .font(FontTheme.caption)
                .foregroundStyle(ColorTheme.accentHex)
                .accessibilityLabel("Corregir el resultado")
                .accessibleTapTarget()
            }
        }
    }
    
    // MARK: - Correction Section (Text + Voice)
    
    private var correctionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Escribe o dicta tu corrección:")
                .font(FontTheme.caption)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
            
            HStack(spacing: 8) {
                TextField("¿Cuál es la corrección?", text: $correctionText)
                    .textFieldStyle(GlassTextFieldStyle())
                    .accessibilityLabel("Escribe tu corrección")
                
                // Voice correction button
                Button {
                    toggleVoiceCorrection()
                } label: {
                    Image(systemName: isRecordingCorrection ? "mic.fill" : "mic")
                        .font(.title3)
                        .foregroundStyle(isRecordingCorrection ? ColorTheme.errorHex : ColorTheme.accentHex)
                        .symbolEffect(.pulse, isActive: isRecordingCorrection)
                }
                .buttonStyle(IconButtonStyle())
                .accessibilityLabel(isRecordingCorrection ? "Detener grabación de voz" : "Dictar corrección por voz")
                .accessibilityHint("Usa el micrófono para dictar tu corrección")
                
                Button("Enviar") {
                    saveCorrection(viaVoice: false)
                }
                .buttonStyle(SecondaryButtonStyle())
                .disabled(correctionText.isEmpty)
            }
            
            if isRecordingCorrection {
                HStack(spacing: 4) {
                    Circle()
                        .fill(ColorTheme.errorHex)
                        .frame(width: 8, height: 8)
                    Text("Escuchando...")
                        .font(FontTheme.caption)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Grabando corrección por voz")
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    // MARK: - Actions
    
    private func submitFeedback(positive: Bool) {
        rating = positive
        hasRated = true
        showThankYou = true
        HapticService.shared.light()
        
        let feedback = AIFeedback(
            predictionId: predictionId,
            predictionType: predictionType,
            userRating: positive
        )
        modelContext.insert(feedback)
        
        let announcement = positive
            ? "Marcado como útil. Gracias."
            : "Marcado como no útil. Puedes corregir el resultado."
        AccessibilityNotification.Announcement(announcement).post()
        
        if !positive {
            withAnimation(.easeInOut(duration: 0.3).delay(0.5)) {
                showCorrection = true
            }
        }
    }
    
    private func toggleVoiceCorrection() {
        if isRecordingCorrection {
            // Stop listening and capture result
            voiceEngine.stopListening()
            isRecordingCorrection = false
            
            // After stopping, save the correction if we got text
            if !correctionText.isEmpty {
                saveCorrection(viaVoice: true)
            }
        } else {
            // Start listening
            isRecordingCorrection = true
            HapticService.shared.medium()
            AccessibilityNotification.Announcement("Escuchando tu corrección. Habla ahora.").post()
            
            voiceEngine.onTranscriptionUpdate = { recognizedText in
                correctionText = recognizedText
            }
            voiceEngine.startListening()
        }
    }
    
    private func saveCorrection(viaVoice: Bool) {
        guard !correctionText.isEmpty else { return }
        
        let feedback = AIFeedback(
            predictionId: predictionId,
            predictionType: predictionType,
            userRating: false,
            userCorrection: correctionText,
            voiceCorrection: viaVoice
        )
        modelContext.insert(feedback)
        
        withAnimation {
            showCorrection = false
            isRecordingCorrection = false
            correctionText = ""
        }
        HapticService.shared.success()
        
        AccessibilityNotification.Announcement("Corrección guardada. Gracias por mejorar EchoStudy.").post()
    }
}

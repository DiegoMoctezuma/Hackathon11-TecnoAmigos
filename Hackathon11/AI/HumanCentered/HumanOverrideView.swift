// HumanOverrideView.swift
// EchoStudy
// A11Y: Allows users to edit or replace AI-generated results

import SwiftUI
import SwiftData

struct HumanOverrideView: View {
    let originalText: String
    let predictionId: String
    let predictionType: String
    var onOverride: ((String) -> Void)? = nil
    
    @Environment(\.modelContext) private var modelContext
    @Environment(VoiceEngine.self) private var voiceEngine
    
    @State private var isEditing: Bool = false
    @State private var editedText: String = ""
    @State private var isRecording: Bool = false
    @State private var hasSaved: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !isEditing && !hasSaved {
                // Show override button
                Button {
                    editedText = originalText
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isEditing = true
                    }
                    HapticService.shared.light()
                    AccessibilityNotification.Announcement("Editor abierto. Puedes modificar el resultado.").post()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "pencil.line")
                            .font(.body)
                        Text("Corregir este resultado")
                            .font(FontTheme.caption)
                    }
                    .foregroundStyle(ColorTheme.accentHex)
                }
                .accessibilityLabel("Corregir este resultado generado por la IA")
                .accessibilityHint("Abre un editor para modificar o reemplazar el texto")
                .accessibleTapTarget()
            } else if isEditing {
                editingView
            } else if hasSaved {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(ColorTheme.successHex)
                    Text("Resultado corregido")
                        .font(FontTheme.caption)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                }
            }
        }
    }
    
    // MARK: - Editing View
    
    private var editingView: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Original text (dimmed)
            VStack(alignment: .leading, spacing: 4) {
                Text("Original:")
                    .font(FontTheme.caption)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                
                Text(originalText)
                    .font(FontTheme.body)
                    .foregroundStyle(ColorTheme.adaptiveText.opacity(0.5))
                    .lineLimit(3)
            }
            
            Divider()
            
            // Editable text
            VStack(alignment: .leading, spacing: 4) {
                Text("Tu versión:")
                    .font(FontTheme.caption)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                
                TextEditor(text: $editedText)
                    .font(FontTheme.body)
                    .foregroundStyle(ColorTheme.adaptiveText)
                    .frame(minHeight: 80, maxHeight: 200)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .glassEffect(in: .rect(cornerRadius: 10))
                    .accessibilityLabel("Texto editado")
            }
            
            // Action buttons
            HStack(spacing: 12) {
                // Voice input button
                Button {
                    toggleVoiceInput()
                } label: {
                    Image(systemName: isRecording ? "mic.fill" : "mic")
                        .foregroundStyle(isRecording ? ColorTheme.errorHex : ColorTheme.accentHex)
                        .symbolEffect(.pulse, isActive: isRecording)
                }
                .buttonStyle(IconButtonStyle())
                .accessibilityLabel(isRecording ? "Detener dictado" : "Dictar por voz")
                
                Spacer()
                
                Button("Cancelar") {
                    withAnimation {
                        isEditing = false
                        isRecording = false
                        voiceEngine.stopListening()
                    }
                }
                .font(FontTheme.caption)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                .accessibleTapTarget()
                
                Button("Guardar") {
                    saveOverride()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(editedText.isEmpty || editedText == originalText)
            }
        }
        .padding(12)
        .glassEffect(in: .rect(cornerRadius: 12))
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    // MARK: - Actions
    
    private func toggleVoiceInput() {
        if isRecording {
            voiceEngine.stopListening()
            isRecording = false
        } else {
            isRecording = true
            HapticService.shared.medium()
            AccessibilityNotification.Announcement("Escuchando. Dicta tu corrección.").post()
            
            voiceEngine.onTranscriptionUpdate = { text in
                editedText = text
            }
            voiceEngine.startListening()
        }
    }
    
    private func saveOverride() {
        guard !editedText.isEmpty, editedText != originalText else { return }
        
        // Save feedback with correction
        let feedback = AIFeedback(
            predictionId: predictionId,
            predictionType: predictionType,
            userRating: false,
            userCorrection: editedText,
            voiceCorrection: isRecording
        )
        modelContext.insert(feedback)
        
        onOverride?(editedText)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isEditing = false
            isRecording = false
            hasSaved = true
        }
        
        voiceEngine.stopListening()
        HapticService.shared.success()
        AccessibilityNotification.Announcement("Corrección guardada exitosamente.").post()
    }
}

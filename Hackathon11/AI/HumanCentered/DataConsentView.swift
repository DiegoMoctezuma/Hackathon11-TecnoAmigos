// DataConsentView.swift
// EchoStudy
// A11Y: Data consent management with category toggles and delete all data

import SwiftUI
import SwiftData

struct DataConsentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage(PreferenceKeys.consentPhotos) private var consentPhotos: Bool = true
    @AppStorage(PreferenceKeys.consentText) private var consentText: Bool = true
    @AppStorage(PreferenceKeys.consentConversations) private var consentConversations: Bool = true
    @AppStorage(PreferenceKeys.consentQuizzes) private var consentQuizzes: Bool = true
    @AppStorage(PreferenceKeys.consentFeedback) private var consentFeedback: Bool = true
    
    @State private var showDeleteConfirmation: Bool = false
    @State private var showDeletedAlert: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                consentToggles
                dataInfo
                deleteSection
            }
            .padding(20)
        }
        .background(ColorTheme.adaptiveBackground)
        .navigationTitle("Datos y Privacidad")
        .announceOnAppear("Configuración de datos y privacidad. Controla qué información almacena EchoStudy.")
        .alert("¿Eliminar todos los datos?", isPresented: $showDeleteConfirmation) {
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar todo", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("Esta acción eliminará todas tus materias, temas, conversaciones, quizzes y feedback. No se puede deshacer.")
        }
        .alert("Datos eliminados", isPresented: $showDeletedAlert) {
            Button("Aceptar") {
                dismiss()
            }
        } message: {
            Text("Todos tus datos han sido eliminados exitosamente.")
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text("Control de datos")
                    .font(FontTheme.title2)
                    .foregroundStyle(ColorTheme.adaptiveText)
            } icon: {
                Image(systemName: "hand.raised.fill")
                    .foregroundStyle(ColorTheme.primaryHex)
            }
            
            Text("Tú decides qué datos almacena EchoStudy en tu dispositivo. Ningún dato sale de tu teléfono.")
                .font(FontTheme.body)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
        }
        .accessibilityElement(children: .combine)
    }
    
    // MARK: - Consent Toggles
    
    private var consentToggles: some View {
        VStack(spacing: 2) {
            consentRow(
                icon: "photo.fill",
                title: "Fotos y materiales",
                description: "Imágenes que subes para procesar con OCR",
                isOn: $consentPhotos
            )
            
            consentRow(
                icon: "doc.text.fill",
                title: "Texto extraído",
                description: "Texto detectado por OCR de tus materiales",
                isOn: $consentText
            )
            
            consentRow(
                icon: "bubble.left.and.bubble.right.fill",
                title: "Conversaciones",
                description: "Historial de conversaciones con el asistente",
                isOn: $consentConversations
            )
            
            consentRow(
                icon: "brain.fill",
                title: "Quizzes y resultados",
                description: "Sesiones de quiz oral y sus calificaciones",
                isOn: $consentQuizzes
            )
            
            consentRow(
                icon: "star.fill",
                title: "Feedback",
                description: "Tus valoraciones y correcciones a resultados de IA",
                isOn: $consentFeedback
            )
        }
        .padding(4)
        .glassEffect(in: .rect(cornerRadius: 16))
    }
    
    private func consentRow(icon: String, title: String, description: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(ColorTheme.primaryHex)
                    .frame(width: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(FontTheme.headline)
                        .foregroundStyle(ColorTheme.adaptiveText)
                    
                    Text(description)
                        .font(FontTheme.caption)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                }
            }
        }
        .tint(ColorTheme.primaryHex)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(description)")
        .accessibilityValue(isOn.wrappedValue ? "Activado" : "Desactivado")
        .accessibilityHint("Toca para \(isOn.wrappedValue ? "desactivar" : "activar")")
    }
    
    // MARK: - Data Info
    
    private var dataInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "lock.shield.fill")
                    .foregroundStyle(ColorTheme.successHex)
                Text("Tus datos son seguros")
                    .font(FontTheme.headline)
                    .foregroundStyle(ColorTheme.adaptiveText)
            }
            
            Text("EchoStudy procesa todo localmente en tu dispositivo. No enviamos datos a servidores externos. Solo el OCR y la detección visual funcionan on-device de verdad; las respuestas del asistente son pre-escritas para la demo.")
                .font(FontTheme.caption)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
        }
        .padding(16)
        .glassEffect(in: .rect(cornerRadius: 12))
        .accessibilityElement(children: .combine)
    }
    
    // MARK: - Delete Section
    
    private var deleteSection: some View {
        VStack(spacing: 12) {
            Button {
                HapticService.shared.warning()
                showDeleteConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Eliminar todos mis datos")
                }
                .font(FontTheme.headline)
                .foregroundStyle(ColorTheme.errorHex)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .glassEffect(in: .rect(cornerRadius: 16))
            }
            .accessibilityLabel("Eliminar todos mis datos")
            .accessibilityHint("Elimina materias, temas, conversaciones, quizzes y feedback. No se puede deshacer.")
            
            Text("Esta acción no se puede deshacer.")
                .font(FontTheme.caption)
                .foregroundStyle(ColorTheme.errorHex.opacity(0.7))
        }
    }
    
    // MARK: - Delete All Data
    
    private func deleteAllData() {
        do {
            try modelContext.delete(model: Subject.self)
            try modelContext.delete(model: Conversation.self)
            try modelContext.delete(model: QuizSession.self)
            try modelContext.delete(model: AIFeedback.self)
            try modelContext.save()
            
            HapticService.shared.success()
            showDeletedAlert = true
            
            AccessibilityNotification.Announcement("Todos los datos han sido eliminados.").post()
        } catch {
            HapticService.shared.error()
            AccessibilityNotification.Announcement("Error al eliminar datos. Intenta de nuevo.").post()
        }
    }
}

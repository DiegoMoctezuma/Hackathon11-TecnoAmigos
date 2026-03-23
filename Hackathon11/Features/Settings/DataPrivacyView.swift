// DataPrivacyView.swift
// EchoStudy
// A11Y: Data privacy and storage info

import SwiftUI
import SwiftData

struct DataPrivacyView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                infoCard(
                    icon: "iphone",
                    title: "Almacenamiento local",
                    description: "Todos tus datos se almacenan únicamente en tu dispositivo. Tus materiales, resúmenes y conversaciones no se envían a ningún servidor."
                )
                
                infoCard(
                    icon: "brain",
                    title: "Procesamiento de IA",
                    description: "El OCR y análisis de temas se realizan en tu dispositivo usando Vision y NaturalLanguage de Apple. No se comparten tus datos."
                )
                
                infoCard(
                    icon: "mic",
                    title: "Reconocimiento de voz",
                    description: "La voz se procesa usando Speech de Apple. Las transcripciones se almacenan localmente."
                )
                
                // Delete all data
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Borrar todos los datos")
                    }
                    .font(FontTheme.headline)
                    .foregroundStyle(ColorTheme.errorHex)
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .glassEffect(in: .rect(cornerRadius: 16))
                }
                .padding(.horizontal)
                .accessibilityLabel("Borrar todos los datos de la aplicación")
                .accessibilityHint("Eliminará todas tus materias, temas y conversaciones")
            }
            .padding(.vertical)
        }
        .background(ColorTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Privacidad")
        .alert("¿Borrar todos los datos?", isPresented: $showDeleteConfirmation) {
            Button("Cancelar", role: .cancel) {}
            Button("Borrar", role: .destructive) {
                // Delete all data
                try? modelContext.delete(model: Subject.self)
                try? modelContext.delete(model: Topic.self)
                try? modelContext.delete(model: Conversation.self)
                try? modelContext.delete(model: QuizSession.self)
                HapticService.shared.warning()
            }
        } message: {
            Text("Esta acción no se puede deshacer. Se eliminarán todas tus materias, temas, conversaciones y quizzes.")
        }
    }
    
    private func infoCard(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(ColorTheme.accentHex)
                .frame(width: 32)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(FontTheme.headline)
                    .foregroundStyle(ColorTheme.adaptiveText)
                Text(description)
                    .font(FontTheme.body)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
            }
        }
        .padding(16)
        .glassEffect(in: .rect(cornerRadius: 16))
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
    }
}

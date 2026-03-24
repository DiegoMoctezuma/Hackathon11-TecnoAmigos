// AIExplanationSheet.swift
// EchoStudy
// A11Y: Explains how EchoStudy works, what data it uses, privacy, and feedback loop

import SwiftUI

struct AIExplanationSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    howItWorksSection
                    whatDataSection
                    feedbackLoopSection
                    privacySection
                }
                .padding(20)
            }
            .background(ColorTheme.adaptiveBackground)
            .navigationTitle("¿Cómo funciona EchoStudy?")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .font(FontTheme.headline)
                    .foregroundStyle(ColorTheme.accentHex)
                    .accessibleTapTarget()
                }
            }
            .announceOnAppear("Pantalla de explicación. Aprende cómo funciona EchoStudy y cómo protege tus datos.")
        }
    }
    
    // MARK: - How It Works
    
    private var howItWorksSection: some View {
        explanationSection(
            icon: "gearshape.2.fill",
            title: "¿Cómo funciona?",
            items: [
                ExplanationItem(
                    icon: "camera.fill",
                    title: "1. Sube tu material",
                    description: "Toma una foto o selecciona un documento. EchoStudy usa tecnología de reconocimiento de texto (OCR) directamente en tu teléfono para extraer el contenido."
                ),
                ExplanationItem(
                    icon: "text.magnifyingglass",
                    title: "2. Análisis inteligente",
                    description: "El texto extraído se analiza para identificar temas, conceptos clave y relaciones entre ideas. Todo ocurre localmente."
                ),
                ExplanationItem(
                    icon: "doc.text.below.ecg",
                    title: "3. Resúmenes y estudio",
                    description: "Se generan resúmenes en diferentes longitudes y preguntas de quiz adaptadas a la dificultad que elijas."
                ),
                ExplanationItem(
                    icon: "mic.fill",
                    title: "4. Interacción por voz",
                    description: "Puedes interactuar con todo usando tu voz. Haz preguntas, responde quizzes y navega la app sin necesidad de ver la pantalla."
                )
            ]
        )
    }
    
    // MARK: - What Data
    
    private var whatDataSection: some View {
        explanationSection(
            icon: "externaldrive.fill",
            title: "¿Qué datos usa?",
            items: [
                ExplanationItem(
                    icon: "photo.fill",
                    title: "Tus materiales",
                    description: "Las fotos y documentos que subes. Se almacenan solo en tu dispositivo."
                ),
                ExplanationItem(
                    icon: "text.alignleft",
                    title: "Texto extraído",
                    description: "El texto que el OCR detecta en tus materiales. Se guarda para que puedas consultarlo después."
                ),
                ExplanationItem(
                    icon: "star.fill",
                    title: "Tu feedback",
                    description: "Tus valoraciones y correcciones ayudan a mejorar la calidad de los resultados futuros."
                )
            ]
        )
    }
    
    // MARK: - Feedback Loop
    
    private var feedbackLoopSection: some View {
        explanationSection(
            icon: "arrow.triangle.2.circlepath",
            title: "Tu feedback importa",
            items: [
                ExplanationItem(
                    icon: "hand.thumbsup.fill",
                    title: "Valora los resultados",
                    description: "Cada vez que marcas un resultado como útil o no útil, EchoStudy aprende a darte mejores resultados."
                ),
                ExplanationItem(
                    icon: "pencil.line",
                    title: "Corrige errores",
                    description: "Si un resultado no es correcto, puedes editarlo. Tu corrección se guarda y mejora futuras respuestas."
                ),
                ExplanationItem(
                    icon: "mic.badge.plus",
                    title: "Correcciones por voz",
                    description: "Puedes dictar correcciones usando tu voz, sin necesidad de escribir."
                )
            ]
        )
    }
    
    // MARK: - Privacy
    
    private var privacySection: some View {
        explanationSection(
            icon: "lock.shield.fill",
            title: "Privacidad y seguridad",
            items: [
                ExplanationItem(
                    icon: "iphone",
                    title: "Todo local",
                    description: "EchoStudy procesa todo en tu dispositivo. Ningún dato se envía a servidores externos ni a Internet."
                ),
                ExplanationItem(
                    icon: "hand.raised.fill",
                    title: "Tú tienes el control",
                    description: "Puedes elegir qué datos almacenar y eliminar toda tu información en cualquier momento desde Configuración."
                ),
                ExplanationItem(
                    icon: "xmark.shield.fill",
                    title: "Sin rastreo",
                    description: "No recopilamos datos de uso, no mostramos anuncios y no compartimos tu información con terceros."
                )
            ]
        )
    }
    
    // MARK: - Explanation Section Builder
    
    private func explanationSection(icon: String, title: String, items: [ExplanationItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(title)
                    .font(FontTheme.title3)
                    .foregroundStyle(ColorTheme.adaptiveText)
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(ColorTheme.primaryHex)
            }
            .accessibleHeader(title)
            
            VStack(spacing: 4) {
                ForEach(items) { item in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: item.icon)
                            .font(.body)
                            .foregroundStyle(ColorTheme.secondaryHex)
                            .frame(width: 28)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(FontTheme.headline)
                                .foregroundStyle(ColorTheme.adaptiveText)
                            
                            Text(item.description)
                                .font(FontTheme.body)
                                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                        }
                    }
                    .padding(12)
                    .accessibilityElement(children: .combine)
                }
            }
            .glassEffect(in: .rect(cornerRadius: 16))
        }
    }
}

// MARK: - Explanation Item

private struct ExplanationItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

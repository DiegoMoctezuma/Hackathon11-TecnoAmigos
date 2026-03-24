// CollaborationOnboarding.swift
// EchoStudy
// Visible companion instructions — designed for sighted users

import SwiftUI

struct CollaborationOnboarding: View {
    @Environment(\.dismiss) private var dismiss
    let studentName: String
    
    init(studentName: String = "tu compañero") {
        self.studentName = studentName
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // MARK: - Hero
                    VStack(spacing: 12) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(ColorTheme.accentHex)
                            .accessibilityHidden(true)
                        
                        Text("Así puedes ayudar")
                            .font(FontTheme.largeTitle)
                            .foregroundStyle(ColorTheme.adaptiveText)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text("Toma una foto clara del pizarrón y compártela con \(studentName) usando ARGOS.")
                            .font(FontTheme.title3)
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Steps
                    VStack(spacing: 16) {
                        stepCard(
                            number: 1,
                            icon: "camera.fill",
                            title: "Toma la foto",
                            description: "Abre la cámara y apunta al pizarrón, documento o apunte que quieras compartir."
                        )
                        
                        stepCard(
                            number: 2,
                            icon: "square.and.arrow.up.fill",
                            title: "Comparte con ARGOS",
                            description: "Usa el botón de compartir y selecciona EchoStudy como destino."
                        )
                        
                        stepCard(
                            number: 3,
                            icon: "wand.and.stars",
                            title: "La IA procesa el contenido",
                            description: "EchoStudy extrae el texto, organiza los temas y genera resúmenes que \(studentName) puede escuchar."
                        )
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Tips
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(ColorTheme.accentHex)
                            Text("Tips para mejores fotos")
                                .font(FontTheme.headline)
                                .foregroundStyle(ColorTheme.adaptiveText)
                        }
                        .accessibilityAddTraits(.isHeader)
                        
                        tipRow(icon: "sun.max.fill", text: "Asegúrate de que haya buena iluminación, sin sombras sobre el texto.")
                        tipRow(icon: "arrow.up.left.and.arrow.down.right", text: "Incluye todo el contenido del pizarrón en la foto.")
                        tipRow(icon: "camera.metering.center.weighted", text: "Mantén la cámara recta y enfocada, evita fotos borrosas.")
                        tipRow(icon: "hand.raised.fill", text: "Espera a que el profesor termine de escribir antes de tomar la foto.")
                        tipRow(icon: "doc.on.doc.fill", text: "Si el pizarrón es muy grande, toma varias fotos por secciones.")
                    }
                    .padding(16)
                    .glassEffect(in: .rect(cornerRadius: 20))
                    .padding(.horizontal)
                    
                    // MARK: - Call to Action
                    Button {
                        dismiss()
                    } label: {
                        Text("¡Entendido!")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(ColorTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Ayuda a tu compañero")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
    
    // MARK: - Step Card
    
    private func stepCard(number: Int, icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(ColorTheme.accentHex)
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Paso \(number): \(title)")
                    .font(FontTheme.headline)
                    .foregroundStyle(ColorTheme.adaptiveText)
                
                Text(description)
                    .font(FontTheme.body)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
            }
        }
        .padding(16)
        .glassEffect(in: .rect(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }
    
    // MARK: - Tip Row
    
    private func tipRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(FontTheme.body)
                .foregroundStyle(ColorTheme.accentHex)
                .frame(width: 24)
                .accessibilityHidden(true)
            
            Text(text)
                .font(FontTheme.body)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
        }
        .accessibilityElement(children: .combine)
    }
}

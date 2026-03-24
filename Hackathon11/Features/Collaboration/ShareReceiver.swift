// ShareReceiver.swift
// EchoStudy
// A11Y: Receives shared images/PDFs from companions

import SwiftUI
import UIKit

struct ShareReceiver: View {
    @Environment(VoiceEngine.self) private var voiceEngine
    @State private var receivedImage: UIImage?
    @State private var showProcessing = false
    @State private var showConfirmation = true
    @State private var senderName: String = "Tu compañero"
    
    var body: some View {
        VStack(spacing: 24) {
            if showConfirmation && receivedImage != nil {
                // MARK: - Confirmation
                confirmationView
            } else if showProcessing {
                // MARK: - Processing
                processingView
            } else {
                // MARK: - Waiting
                waitingView
            }
        }
        .background(ColorTheme.backgroundGradient.ignoresSafeArea())
        .announceOnAppear("\(senderName) te envió una foto. ¿Procesarla?")
    }
    
    // MARK: - Confirmation View
    
    private var confirmationView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "photo.badge.arrow.down.fill")
                .font(.system(size: 64))
                .foregroundStyle(ColorTheme.accentHex)
                .symbolEffect(.bounce)
                .accessibilityHidden(true)
            
            VStack(spacing: 8) {
                Text("\(senderName) te envió una foto")
                    .font(FontTheme.title2)
                    .foregroundStyle(ColorTheme.adaptiveText)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                
                Text("¿Quieres procesarla con la IA para extraer el contenido?")
                    .font(FontTheme.body)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            // Thumbnail
            if let image = receivedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .glassEffect(in: .rect(cornerRadius: 16))
                    .padding(.horizontal)
                    .accessibilityLabel("Foto recibida de \(senderName)")
            }
            
            VStack(spacing: 12) {
                Button {
                    HapticService.shared.heavy()
                    showConfirmation = false
                    showProcessing = true
                    voiceEngine.speak("Procesando la imagen recibida.", priority: .high)
                } label: {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Procesar imagen")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityHint("Procesa la foto con inteligencia artificial")
                
                Button {
                    HapticService.shared.light()
                    receivedImage = nil
                    showConfirmation = false
                } label: {
                    Text("Descartar")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())
                .accessibilityLabel("Descartar la foto recibida")
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // MARK: - Processing View
    
    private var processingView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ProgressView()
                .scaleEffect(1.5)
                .tint(ColorTheme.accentHex)
                .accessibilityHidden(true)
            
            Text("Procesando imagen...")
                .font(FontTheme.title3)
                .foregroundStyle(ColorTheme.adaptiveText)
            
            Text("Extrayendo texto y detectando temas con IA")
                .font(FontTheme.body)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    // MARK: - Waiting View
    
    private var waitingView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            EmptyStateView(
                iconName: "square.and.arrow.down.fill",
                title: "Esperando material",
                message: "Pide a tu compañero que tome una foto del pizarrón y la comparta contigo usando el botón de compartir"
            )
            
            Spacer()
        }
    }
}

// ShareLinkGenerator.swift
// EchoStudy
// A11Y: Generates QR code/link for sighted companions

import SwiftUI
import CoreImage.CIFilterBuiltins

struct ShareLinkGenerator: View {
    @Environment(VoiceEngine.self) private var voiceEngine
    @State private var userName: String = "Estudiante"
    @State private var showShareSheet = false
    
    private var shareURL: URL {
        // Mock URL for hackathon demo
        URL(string: "https://echostudy.app/share/\(UUID().uuidString.prefix(8))")!
    }
    
    private var qrImage: UIImage? {
        generateQRCode(from: shareURL.absoluteString)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Header
                VStack(spacing: 8) {
                    Image(systemName: "qrcode")
                        .font(.system(size: 48))
                        .foregroundStyle(ColorTheme.accentHex)
                        .accessibilityHidden(true)
                    
                    Text("Comparte con tu compañero")
                        .font(FontTheme.title2)
                        .foregroundStyle(ColorTheme.adaptiveText)
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("Tu compañero puede escanear este código QR para enviarte fotos directamente")
                        .font(FontTheme.body)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                // MARK: - QR Code
                if let qrImage {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                        .padding(20)
                        .glassEffect(in: .rect(cornerRadius: 24))
                        .accessibilityLabel("Código QR para compartir. Muestra esta pantalla a tu compañero para que lo escanee.")
                }
                
                // MARK: - Share Button
                Button {
                    HapticService.shared.medium()
                    showShareSheet = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Compartir enlace")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)
                .accessibilityLabel("Compartir enlace con tu compañero")
                .accessibilityHint("Abre las opciones para compartir el enlace por mensaje, correo u otras apps")
                
                // MARK: - Instructions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Instrucciones para tu compañero")
                        .font(FontTheme.headline)
                        .foregroundStyle(ColorTheme.adaptiveText)
                        .accessibilityAddTraits(.isHeader)
                    
                    instructionStep(number: 1, text: "Escanea el código QR o abre el enlace")
                    instructionStep(number: 2, text: "Se abrirá la cámara automáticamente")
                    instructionStep(number: 3, text: "Toma una foto clara del pizarrón o apunte")
                    instructionStep(number: 4, text: "La foto se enviará directamente a EchoStudy")
                }
                .padding(16)
                .glassEffect(in: .rect(cornerRadius: 20))
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(ColorTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Compartir")
        .sheet(isPresented: $showShareSheet) {
            ShareSheetView(items: [shareURL])
        }
        .announceOnAppear("Compartir con tu compañero. Muestra el código QR o envía el enlace.")
    }
    
    private func instructionStep(number: Int, text: String) -> some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(FontTheme.headline)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(ColorTheme.accentHex)
                .clipShape(Circle())
                .accessibilityHidden(true)
            
            Text(text)
                .font(FontTheme.body)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Paso \(number): \(text)")
    }
    
    // MARK: - QR Code Generator
    
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        
        guard let outputImage = filter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)
        
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Share Sheet Wrapper

struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MaterialThumbnail.swift
// EchoStudy
// A11Y: Thumbnail for uploaded materials

import SwiftUI

struct MaterialThumbnail: View {
    let material: StudyMaterial
    let size: CGFloat
    
    init(material: StudyMaterial, size: CGFloat = 60) {
        self.material = material
        self.size = size
    }
    
    var body: some View {
        Group {
            if let imageData = material.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: iconForType)
                    .font(.title2)
                    .foregroundStyle(ColorTheme.secondaryHex)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .glassEffect(in: .rect(cornerRadius: 12))
        // A11Y: Descriptive label
        .accessibilityLabel("\(material.type.rawValue.capitalized): \(material.fileName)")
    }
    
    private var iconForType: String {
        switch material.type {
        case .photo: return "photo"
        case .pdf: return "doc.richtext"
        case .document: return "doc.text"
        }
    }
}

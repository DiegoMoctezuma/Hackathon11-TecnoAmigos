// NewSubjectSheet.swift
// EchoStudy
// A11Y: Create new subject with name, icon, and color

import SwiftUI
import SwiftData

struct NewSubjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name: String = ""
    @State private var selectedIcon: String = "book.fill"
    @State private var selectedColorHex: String = "#1B4965"
    
    private let icons = [
        "book.fill", "leaf.fill", "atom", "function",
        "globe.americas.fill", "heart.fill", "brain.head.profile",
        "paintpalette.fill", "music.note", "flask.fill",
        "building.columns.fill", "hammer.fill"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Preview
                    SubjectIcon(iconName: selectedIcon, colorHex: selectedColorHex, size: 80)
                        .accessibilityLabel("Vista previa del ícono de materia")
                    
                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nombre de la materia")
                            .font(FontTheme.headline)
                            .foregroundStyle(ColorTheme.adaptiveText)
                        
                        TextField("Ej: Biología Celular", text: $name)
                            .textFieldStyle(GlassTextFieldStyle())
                            .accessibilityLabel("Nombre de la materia")
                            .accessibilityHint("Escribe el nombre de tu nueva materia")
                    }
                    .padding(.horizontal)
                    
                    // Icon picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ícono")
                            .font(FontTheme.headline)
                            .foregroundStyle(ColorTheme.adaptiveText)
                            .accessibilityAddTraits(.isHeader)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    HapticService.shared.selection()
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .frame(width: 48, height: 48)
                                        .foregroundStyle(
                                            selectedIcon == icon ? .white : ColorTheme.adaptiveText
                                        )
                                        .background(
                                            selectedIcon == icon ? Color(hex: selectedColorHex) : Color.clear
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .glassEffect(in: .rect(cornerRadius: 12))
                                .accessibilityLabel("Ícono \(icon)")
                                .accessibilityAddTraits(selectedIcon == icon ? .isSelected : [])
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Color picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Color")
                            .font(FontTheme.headline)
                            .foregroundStyle(ColorTheme.adaptiveText)
                            .accessibilityAddTraits(.isHeader)
                        
                        HStack(spacing: 12) {
                            ForEach(ColorTheme.subjectColors.indices, id: \.self) { index in
                                let hex = ["#1B4965", "#2D6A4F", "#E63946", "#F4A261", "#62B6CB", "#6A4C93", "#1982C4", "#FF595E"][index]
                                Button {
                                    HapticService.shared.selection()
                                    selectedColorHex = hex
                                } label: {
                                    Circle()
                                        .fill(ColorTheme.subjectColors[index])
                                        .frame(width: 36, height: 36)
                                        .overlay {
                                            if selectedColorHex == hex {
                                                Image(systemName: "checkmark")
                                                    .font(.caption.bold())
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                }
                                .accessibilityLabel("Color \(index + 1)")
                                .accessibilityAddTraits(selectedColorHex == hex ? .isSelected : [])
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(ColorTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Nueva materia")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .accessibilityLabel("Cancelar creación de materia")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") {
                        createSubject()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityLabel("Crear materia")
                }
            }
        }
        .announceOnAppear("Crear nueva materia. Ingresa un nombre, selecciona un ícono y un color.")
    }
    
    private func createSubject() {
        let subject = Subject(
            name: name.trimmingCharacters(in: .whitespaces),
            iconName: selectedIcon,
            colorHex: selectedColorHex
        )
        modelContext.insert(subject)
        HapticService.shared.success()
        dismiss()
    }
}

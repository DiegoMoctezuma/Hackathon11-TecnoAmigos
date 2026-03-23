// UploadMaterialView.swift
// EchoStudy
// A11Y: Hub for uploading study materials — camera, gallery, documents.
// Full processing pipeline with narrated steps.

import SwiftUI
import SwiftData
import PhotosUI

struct UploadMaterialView: View {
    var preselectedSubject: Subject? = nil
    
    @Environment(VoiceEngine.self) private var voiceEngine
    @Environment(AIServiceManager.self) private var aiManager
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = UploadViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Header
                uploadHeader
                
                // MARK: - Upload Options
                uploadOptions
                
                // MARK: - Processing State
                if aiManager.isProcessing {
                    ProcessingView(aiManager: aiManager)
                }
                
                // MARK: - Results Preview
                if let result = viewModel.processingResult, viewModel.showResults {
                    ProcessingResultPreview(
                        result: result,
                        onConfirm: { editedTopics in
                            viewModel.confirmedTopics = editedTopics
                            viewModel.showMaterialAssignment = true
                        }
                    )
                }
                
                // MARK: - Recent Materials
                recentMaterialsSection
            }
            .padding(.vertical)
        }
        .background(ColorTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Subir material")
        .onChange(of: viewModel.selectedPhotoItem) { _, newItem in
            Task { await viewModel.loadImage(from: newItem) }
        }
        .onChange(of: viewModel.selectedImage) { _, newImage in
            if newImage != nil {
                Task { await viewModel.processSelectedImage(using: aiManager) }
            }
        }
        .sheet(isPresented: $viewModel.showCamera) {
            CameraCaptureView(image: $viewModel.selectedImage)
        }
        .sheet(isPresented: $viewModel.showDocumentPicker) {
            DocumentPickerView { url in
                Task { await viewModel.processDocument(at: url, using: aiManager) }
            }
        }
        .sheet(isPresented: $viewModel.showMaterialAssignment) {
            MaterialAssignmentView(
                preselectedSubject: preselectedSubject,
                result: viewModel.processingResult,
                confirmedTopics: viewModel.confirmedTopics ?? viewModel.processingResult?.detectedTopics ?? [],
                onAssign: { subject in
                    saveToSubject(subject)
                }
            )
        }
        .announceOnAppear("Subir material de estudio. Selecciona cómo quieres subir: foto, galería o documento.")
    }
    
    // MARK: - Upload Header
    
    private var uploadHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "arrow.up.doc.fill")
                .font(.system(size: 48))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(ColorTheme.accentHex)
                .accessibilityHidden(true)
            
            Text("Subir material de estudio")
                .font(FontTheme.title2)
                .foregroundStyle(ColorTheme.adaptiveText)
                .accessibilityAddTraits(.isHeader)
            
            Text("Sube una foto, PDF o documento y la IA lo procesará por ti")
                .font(FontTheme.body)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Upload Options
    
    private var uploadOptions: some View {
        VStack(spacing: 12) {
            // Camera
            Button {
                viewModel.showCamera = true
            } label: {
                uploadOptionRow(
                    icon: "camera.fill",
                    title: "Tomar foto",
                    subtitle: "Captura un pizarrón o documento"
                )
            }
            .accessibilityLabel("Tomar foto con la cámara")
            .accessibilityHint("Abre la cámara para capturar material de estudio")
            
            // Photo picker
            PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                uploadOptionRow(
                    icon: "photo.on.rectangle",
                    title: "Seleccionar de la galería",
                    subtitle: "Fotos de pizarrones, apuntes, diagramas"
                )
            }
            .accessibilityLabel("Seleccionar foto de la galería")
            .accessibilityHint("Abre tu galería de fotos para seleccionar una imagen")
            
            // Document picker
            Button {
                viewModel.showDocumentPicker = true
            } label: {
                uploadOptionRow(
                    icon: "doc.fill",
                    title: "Seleccionar documento",
                    subtitle: "PDFs, documentos de texto"
                )
            }
            .accessibilityLabel("Seleccionar documento")
            .accessibilityHint("Abre el selector de archivos para elegir un PDF o documento")
        }
        .padding(.horizontal)
    }
    
    // MARK: - Upload Option Row
    
    private func uploadOptionRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(ColorTheme.accentHex)
                .frame(width: 48, height: 48)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(FontTheme.headline)
                    .foregroundStyle(ColorTheme.adaptiveText)
                Text(subtitle)
                    .font(FontTheme.subheadline)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
        }
        .padding(16)
        .frame(minHeight: 80) // A11Y: Large touch target
        .glassEffect(in: .rect(cornerRadius: 20))
    }
    
    // MARK: - Recent Materials
    
    private var recentMaterialsSection: some View {
        Group {
            if !viewModel.recentMaterials.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Materiales recientes")
                        .font(FontTheme.title3)
                        .foregroundStyle(ColorTheme.adaptiveText)
                        .accessibilityAddTraits(.isHeader)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.recentMaterials) { material in
                                MaterialThumbnail(material: material)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    // MARK: - Save Results
    
    private func saveToSubject(_ subject: Subject) {
        guard let result = viewModel.processingResult else { return }
        let topicsToSave = viewModel.confirmedTopics ?? result.detectedTopics
        
        for detectedTopic in topicsToSave {
            let topic = Topic(
                title: detectedTopic.title,
                shortSummary: detectedTopic.shortSummary,
                fullSummary: detectedTopic.fullSummary,
                confidence: detectedTopic.confidence,
                subject: subject,
                orderIndex: subject.topics.count
            )
            modelContext.insert(topic)
            subject.topics.append(topic)
            
            for (index, detectedSubtopic) in detectedTopic.subtopics.enumerated() {
                let subtopic = Subtopic(
                    title: detectedSubtopic.title,
                    content: detectedSubtopic.content,
                    topic: topic,
                    orderIndex: index
                )
                modelContext.insert(subtopic)
                topic.subtopics.append(subtopic)
            }
        }
        
        // Save material record
        let material = StudyMaterial(
            type: .photo,
            fileName: "Material \(Date().shortDateString)",
            imageData: viewModel.selectedImage?.jpegData(compressionQuality: 0.5),
            extractedText: result.extractedText,
            visualDescription: result.visualDescription,
            topics: subject.topics
        )
        modelContext.insert(material)
        
        viewModel.showResults = false
        viewModel.processingResult = nil
        viewModel.showMaterialAssignment = false
        
        HapticService.shared.success()
        voiceEngine.speak(
            "Material guardado exitosamente en \(subject.name) con \(topicsToSave.count) temas",
            priority: .high
        )
        
        // Navigate to subject
        if preselectedSubject == nil {
            router.push(.subjectDetail(subject))
        }
    }
}

// MARK: - Processing View

struct ProcessingView: View {
    @Bindable var aiManager: AIServiceManager
    
    private var steps: [(String, Bool, Bool)] {
        let current = aiManager.currentStep
        return [
            ("Leyendo imagen...", current == .readingImage || aiManager.progress > 0.1,
             aiManager.progress > 0.2),
            ("Extrayendo texto...", current == .extractingText,
             aiManager.progress > 0.4),
            ("Describiendo elementos visuales...", current == .analyzingStructure,
             aiManager.progress > 0.6),
            ("Identificando temas y subtemas...", current == .detectingTopics,
             aiManager.progress > 0.7),
            ("Generando resúmenes...", current == .generatingSummaries,
             aiManager.progress > 0.9),
            ("¡Listo! Procesamiento completado.", current == .complete,
             current == .complete)
        ]
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Progress bar
            ProgressView(value: aiManager.progress)
                .tint(ColorTheme.accentHex)
                .accessibilityLabel("Progreso: \(Int(aiManager.progress * 100)) por ciento")
            
            // Step list
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    let (text, isActive, isComplete) = step
                    
                    HStack(spacing: 10) {
                        Group {
                            if isComplete {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(ColorTheme.successHex)
                            } else if isActive {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundStyle(ColorTheme.adaptiveTextSecondary.opacity(0.4))
                            }
                        }
                        .frame(width: 20)
                        
                        Text(text)
                            .font(isActive ? FontTheme.headline : FontTheme.subheadline)
                            .foregroundStyle(
                                isActive ? ColorTheme.adaptiveText :
                                isComplete ? ColorTheme.successHex :
                                ColorTheme.adaptiveTextSecondary.opacity(0.5)
                            )
                    }
                    // A11Y: Announce active step
                    .onChange(of: isActive) { _, active in
                        if active {
                            AccessibilityNotification.Announcement(text).post()
                            HapticService.shared.light()
                        }
                    }
                    .onChange(of: isComplete) { _, complete in
                        if complete {
                            HapticService.shared.medium()
                        }
                    }
                }
            }
            
            // Current step text
            Text(aiManager.currentStep.rawValue)
                .font(FontTheme.headline)
                .foregroundStyle(ColorTheme.adaptiveText)
                .accessibilityLabel("Estado actual: \(aiManager.currentStep.rawValue)")
        }
        .padding(20)
        .glassEffect(in: .rect(cornerRadius: 20))
        .padding(.horizontal)
        .announceOnAppear("Procesando material. \(aiManager.currentStep.rawValue)")
    }
}

// MARK: - Processing Result Preview

struct ProcessingResultPreview: View {
    let result: ProcessingResult
    let onConfirm: ([ProcessingResult.DetectedTopic]) -> Void
    
    @State private var editableTopics: [ProcessingResult.DetectedTopic]
    @State private var editingTopicId: UUID?
    @State private var editedTitle: String = ""
    @State private var showAddTopic = false
    @State private var newTopicTitle: String = ""
    
    init(result: ProcessingResult, onConfirm: @escaping ([ProcessingResult.DetectedTopic]) -> Void) {
        self.result = result
        self.onConfirm = onConfirm
        _editableTopics = State(initialValue: result.detectedTopics)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Temas detectados")
                    .font(FontTheme.title3)
                    .foregroundStyle(ColorTheme.adaptiveText)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                ConfidenceBadge(confidence: result.overallConfidence)
            }
            
            // Topics list
            ForEach(editableTopics) { topic in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        if editingTopicId == topic.id {
                            // Editing mode
                            TextField("Nombre del tema", text: $editedTitle)
                                .font(FontTheme.headline)
                                .textFieldStyle(GlassTextFieldStyle())
                                .onSubmit { confirmEdit(for: topic) }
                                .accessibilityLabel("Editar nombre del tema")
                            
                            Button {
                                confirmEdit(for: topic)
                            } label: {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(ColorTheme.successHex)
                            }
                            .accessibilityLabel("Confirmar edición")
                        } else {
                            Text(topic.title)
                                .font(FontTheme.headline)
                                .foregroundStyle(ColorTheme.adaptiveText)
                            
                            Spacer()
                            
                            // Edit button
                            Button {
                                editingTopicId = topic.id
                                editedTitle = topic.title
                            } label: {
                                Image(systemName: "pencil.circle")
                                    .foregroundStyle(ColorTheme.accentHex)
                            }
                            .accessibilityLabel("Editar \(topic.title)")
                            
                            // Delete button
                            Button {
                                removeTopic(topic)
                            } label: {
                                Image(systemName: "trash.circle")
                                    .foregroundStyle(ColorTheme.errorHex)
                            }
                            .accessibilityLabel("Eliminar \(topic.title)")
                        }
                    }
                    
                    Text(topic.shortSummary)
                        .font(FontTheme.subheadline)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                        .lineLimit(3)
                    
                    ConfidenceBadge(confidence: topic.confidence)
                }
                .padding(12)
                .glassEffect(in: .rect(cornerRadius: 12))
                .accessibilityElement(children: .combine)
            }
            
            // Add topic button
            Button {
                showAddTopic = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Agregar tema que faltó")
                }
                .font(FontTheme.subheadline)
                .foregroundStyle(ColorTheme.accentHex)
            }
            .accessibilityLabel("Agregar un tema que no fue detectado")
            .alert("Agregar tema", isPresented: $showAddTopic) {
                TextField("Nombre del tema", text: $newTopicTitle)
                Button("Agregar") { addNewTopic() }
                Button("Cancelar", role: .cancel) {}
            }
            
            // Confirm all button
            Button {
                HapticService.shared.success()
                onConfirm(editableTopics)
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Todo correcto — guardar")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityLabel("Confirmar todos los temas detectados y guardar")
        }
        .padding(16)
        .glassEffect(in: .rect(cornerRadius: 20))
        .padding(.horizontal)
        .announceOnAppear("Se detectaron \(editableTopics.count) temas. Puedes editar, eliminar o agregar temas antes de confirmar.")
    }
    
    private func confirmEdit(for topic: ProcessingResult.DetectedTopic) {
        if let index = editableTopics.firstIndex(where: { $0.id == topic.id }) {
            editableTopics[index] = ProcessingResult.DetectedTopic(
                title: editedTitle,
                shortSummary: topic.shortSummary,
                fullSummary: topic.fullSummary,
                subtopics: topic.subtopics,
                confidence: topic.confidence
            )
        }
        editingTopicId = nil
        HapticService.shared.light()
    }
    
    private func removeTopic(_ topic: ProcessingResult.DetectedTopic) {
        editableTopics.removeAll { $0.id == topic.id }
        HapticService.shared.warning()
    }
    
    private func addNewTopic() {
        guard !newTopicTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newTopic = ProcessingResult.DetectedTopic(
            title: newTopicTitle,
            shortSummary: "Tema agregado manualmente",
            fullSummary: "",
            subtopics: [],
            confidence: 1.0
        )
        editableTopics.append(newTopic)
        newTopicTitle = ""
        HapticService.shared.success()
    }
}

// MARK: - Material Assignment View

struct MaterialAssignmentView: View {
    let preselectedSubject: Subject?
    let result: ProcessingResult?
    let confirmedTopics: [ProcessingResult.DetectedTopic]
    let onAssign: (Subject) -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Subject.lastAccessedAt, order: .reverse) private var subjects: [Subject]
    @State private var showNewSubject = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 40))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(ColorTheme.accentHex)
                            .accessibilityHidden(true)
                        
                        Text("¿A qué materia pertenece?")
                            .font(FontTheme.title3)
                            .foregroundStyle(ColorTheme.adaptiveText)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text("\(confirmedTopics.count) temas listos para guardar")
                            .font(FontTheme.subheadline)
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    }
                    
                    // Suggested subject (if preselected)
                    if let preselected = preselectedSubject {
                        Button {
                            onAssign(preselected)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                SubjectIcon(iconName: preselected.iconName, colorHex: preselected.colorHex, size: 40)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(preselected.name)
                                        .font(FontTheme.headline)
                                        .foregroundStyle(ColorTheme.adaptiveText)
                                    Text("Sugerida")
                                        .font(FontTheme.caption)
                                        .foregroundStyle(ColorTheme.successHex)
                                }
                                
                                Spacer()
                                
                                ConfidenceBadge(confidence: 0.9)
                            }
                            .padding(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(ColorTheme.accentHex, lineWidth: 2)
                            )
                            .glassEffect(in: .rect(cornerRadius: 16))
                        }
                        .padding(.horizontal)
                        .accessibilityLabel("Guardar en \(preselected.name). Sugerida.")
                    }
                    
                    // Existing subjects
                    if !subjects.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Materias existentes")
                                .font(FontTheme.headline)
                                .foregroundStyle(ColorTheme.adaptiveText)
                                .padding(.horizontal)
                            
                            ForEach(subjects.filter { $0.id != preselectedSubject?.id }) { subject in
                                Button {
                                    onAssign(subject)
                                    dismiss()
                                } label: {
                                    HStack(spacing: 12) {
                                        SubjectIcon(iconName: subject.iconName, colorHex: subject.colorHex, size: 36)
                                        
                                        Text(subject.name)
                                            .font(FontTheme.body)
                                            .foregroundStyle(ColorTheme.adaptiveText)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                                    }
                                    .padding(12)
                                    .glassEffect(in: .rect(cornerRadius: 12))
                                }
                                .padding(.horizontal)
                                .accessibilityLabel("Guardar en \(subject.name)")
                            }
                        }
                    }
                    
                    // Create new subject
                    Button {
                        showNewSubject = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(ColorTheme.accentHex)
                            
                            Text("Crear materia nueva")
                                .font(FontTheme.headline)
                                .foregroundStyle(ColorTheme.accentHex)
                            
                            Spacer()
                        }
                        .padding(14)
                        .glassEffect(in: .rect(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                    .accessibilityLabel("Crear una materia nueva para guardar estos temas")
                }
                .padding(.vertical)
            }
            .background(ColorTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Asignar materia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
            .sheet(isPresented: $showNewSubject) {
                NewSubjectSheet()
            }
        }
        .announceOnAppear("Selecciona la materia donde guardar \(confirmedTopics.count) temas.")
    }
}

// MARK: - Camera Capture View

struct CameraCaptureView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraCaptureView
        
        init(_ parent: CameraCaptureView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Document Picker View

struct DocumentPickerView: UIViewControllerRepresentable {
    let onPick: (URL) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .plainText, .rtf])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerView
        
        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                parent.onPick(url)
            }
            parent.dismiss()
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.dismiss()
        }
    }
}

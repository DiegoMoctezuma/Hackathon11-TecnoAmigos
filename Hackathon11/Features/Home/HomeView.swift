// HomeView.swift
// EchoStudy
// A11Y: Dashboard with subjects, upload, recent activity. Pull to refresh.

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AppRouter.self) private var router
    @Environment(VoiceEngine.self) private var voiceEngine
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Subject.lastAccessedAt, order: .reverse) private var subjects: [Subject]
    @Query(sort: \QuizSession.completedAt, order: .reverse) private var quizSessions: [QuizSession]
    
    @State private var viewModel = HomeViewModel()
    
    private var totalTopics: Int {
        subjects.flatMap(\.topics).count
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Header
                headerSection
                
                // MARK: - Quick Upload
                QuickUploadButton {
                    router.selectedTab = .upload
                }
                
                // MARK: - Search
                AccessibleSearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                
                // MARK: - Subjects Grid
                subjectsSection
                
                // MARK: - Recent Activity
                recentActivitySection
            }
            .padding(.vertical)
        }
        .refreshable {
            // A11Y: Pull to refresh
            HapticService.shared.light()
        }
        .background(ColorTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("ARGOS")
        .sheet(isPresented: $viewModel.showNewSubjectSheet) {
            NewSubjectSheet()
        }
        .announceOnAppear(
            subjects.isEmpty
                ? "Inicio de ARGOS. No tienes materias aún. Sube tu primer material."
                : "Inicio de ARGOS. Tienes \(subjects.count) materias."
        )
        .onAppear {
            // Pre-populate mock data if database is empty
            MockDataProvider.populateIfNeeded(context: modelContext)
            
            // A11Y: Announce empty state via voice for first-time users
            if subjects.isEmpty {
                voiceEngine.speak(
                    "Bienvenido a ARGOS. No tienes materias todavía. Toca el botón Subir material nuevo para comenzar.",
                    priority: .normal
                )
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hola")
                    .font(FontTheme.title2)
                    .foregroundStyle(ColorTheme.adaptiveText)
                    .accessibilityAddTraits(.isHeader)
                
                Text(Date().formatted(.dateTime.weekday(.wide).day().month(.wide).locale(Locale(identifier: "es"))))
                    .font(FontTheme.subheadline)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                
                if !subjects.isEmpty {
                    Text("\(subjects.count) materias · \(totalTopics) temas")
                        .font(FontTheme.caption)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                }
            }
            
            Spacer()
            
            // Settings shortcut
            Button {
                router.selectedTab = .settings
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    .frame(width: 48, height: 48)
                    .glassEffect(in: .circle)
            }
            .accessibilityLabel("Ajustes")
            .accessibilityHint("Abre la pantalla de configuración")
        }
        .padding(.horizontal)
    }
    
    // MARK: - Subjects Section
    
    private var subjectsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Mis materias")
                    .font(FontTheme.title3)
                    .foregroundStyle(ColorTheme.adaptiveText)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                Button {
                    HapticService.shared.light()
                    viewModel.showNewSubjectSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(ColorTheme.accentHex)
                }
                .accessibilityLabel("Crear nueva materia")
                .accessibilityHint("Abre formulario para agregar una materia")
            }
            .padding(.horizontal)
            
            if subjects.isEmpty {
                EmptyStateView(
                    iconName: "books.vertical",
                    title: "Sin materias todavía",
                    message: "Sube tu primer material de estudio y EchoStudy organizará todo por ti",
                    actionTitle: "Subir material",
                    action: { router.selectedTab = .upload }
                )
            } else {
                let filtered = viewModel.filteredSubjects(subjects)
                
                // A11Y: 2-column grid for subjects
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    ForEach(filtered) { subject in
                        SubjectCardView(subject: subject)
                            .onTapGesture {
                                HapticService.shared.light()
                                subject.lastAccessedAt = Date()
                                router.push(.subjectDetail(subject))
                            }
                            .contextMenu {
                                // Long press context menu
                                Button {
                                    viewModel.subjectToRename = subject
                                    viewModel.showRenameAlert = true
                                } label: {
                                    Label("Renombrar", systemImage: "pencil")
                                }
                                
                                Button {
                                    router.push(.uploadMaterialToSubject(subject))
                                } label: {
                                    Label("Subir material", systemImage: "arrow.up.doc")
                                }
                                
                                Divider()
                                
                                Button(role: .destructive) {
                                    viewModel.deleteSubject(subject, context: modelContext)
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Recent Activity
    
    private var recentActivitySection: some View {
        let recentItems = viewModel.buildRecentActivity(subjects: subjects, quizSessions: quizSessions)
        
        return Group {
            if !recentItems.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Actividad reciente")
                        .font(FontTheme.title3)
                        .foregroundStyle(ColorTheme.adaptiveText)
                        .accessibilityAddTraits(.isHeader)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach(recentItems.prefix(5)) { item in
                            RecentActivityRow(item: item)
                            
                            if item.id != recentItems.prefix(5).last?.id {
                                Divider()
                                    .padding(.leading, 52)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .glassEffect(in: .rect(cornerRadius: 20))
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct HomeView_pre: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

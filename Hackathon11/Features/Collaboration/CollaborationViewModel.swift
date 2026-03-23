// CollaborationViewModel.swift
// EchoStudy

import Foundation
import SwiftUI

@Observable
@MainActor
final class CollaborationViewModel {
    var showShareSheet: Bool = false
    var shareMessage: String = "Envía tus fotos de apuntes o pizarrones a esta app y EchoStudy los procesará automáticamente."
}

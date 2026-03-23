// OnboardingViewModel.swift
// EchoStudy

import Foundation
import SwiftUI

@Observable
@MainActor
final class OnboardingViewModel {
    var currentPage: Int = 0
    var voiceSpeed: Float = 1.0
    let totalPages = 4
    
    var isLastPage: Bool { currentPage == totalPages - 1 }
    
    func nextPage() {
        if currentPage < totalPages - 1 {
            currentPage += 1
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
}

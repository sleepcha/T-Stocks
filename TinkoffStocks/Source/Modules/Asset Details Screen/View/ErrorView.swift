//
//  ErrorView.swift
//  T-Stocks
//
//  Created by sleepcha on 1/14/25.
//

import SwiftUI

// MARK: - ErrorView

struct ErrorView: View {
    let errorMessage: String
    let onTap: () async -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            Text(errorMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            RefreshButton(onTap: onTap)
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - RefreshButton

struct RefreshButton: View {
    @State private var isLoading = false
    let onTap: () async -> Void

    var body: some View {
        Button(action: startRefresh) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .brandLabel))
                        .scaleEffect(0.66)
                } else {
                    Text("Обновить")
                        .foregroundStyle(.black)
                }
            }
            .frame(width: 80, height: 20)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(.brandAccent)
        .foregroundStyle(.brandLabel)
    }

    private func startRefresh() {
        guard !isLoading else { return }

        isLoading = true
        Task {
            await onTap()
            isLoading = false
        }
    }
}

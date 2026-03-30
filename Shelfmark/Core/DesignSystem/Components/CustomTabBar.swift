//
//  CustomTabBar.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//
//  Purpose: Custom bottom tab bar with central add action and animated tab selection.
//

import Foundation
import SwiftUI

/// Renders app tab navigation controls and emits tab/add action events.
struct CustomTabBar: View {
    @Binding var selectedTab: TabBar
    var onPlusButtonTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 35, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(height: 70)
                .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: -8)
                .overlay(
                    RoundedRectangle(cornerRadius: 35, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                )
                .padding(.horizontal, 20)
            
            HStack(spacing: 0) {
                tabButton(for: .library)
                tabButton(for: .lists)
                
                Color.clear.frame(width: 80)
                
                tabButton(for: .quotes)
                tabButton(for: .profile)
            }
            .padding(.horizontal, 40)
            .frame(height: 70)
            
            plusButton
        }
    }
    
    private var plusButton: some View {
        Button(action: onPlusButtonTap) {
            ZStack {
                Circle()
                    .fill(Color.primaryGreen.opacity(0.9))
                    .frame(width: 62, height: 62)
                    .shadow(color: .green.opacity(0.4), radius: 12, x: 0, y: 5)

                Image(systemName: selectedTab == .quotes ? "camera" : "plus")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .offset(y: -28)
        .accessibilityIdentifier("tabbar.plus")
    }
    
    private func tabButton(for tab: TabBar) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.rawValue)
                    .font(.system(size: 20))
                Text(tab.title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(selectedTab == tab ? .primaryGreen : Color.theme.textPrimary.opacity(0.55))
            .frame(maxWidth: .infinity)
        }
        .accessibilityIdentifier("tabbar.\(tab.title.lowercased())")
    }
}

//
//  CustomTabBar.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 05/03/26.
//

import Foundation
import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabBar
    var onPlusButtonTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 35)
                .fill(Color(.systemBackground))
                .frame(height: 70)
                .shadow(color: .black.opacity(0.08),radius: 10, x: 0, y: -5)
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
                    .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)

                Image(systemName: selectedTab == .quotes ? "camera" : "plus")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .offset(y: -28)
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
            .foregroundStyle(selectedTab == tab ? .primaryGreen: .secondary)
            .frame(maxWidth: .infinity)
        }
    }
}

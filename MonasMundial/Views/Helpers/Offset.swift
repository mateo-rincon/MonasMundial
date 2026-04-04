//
//  Offset.swift
//  MonasMundial
//
//  Created by Mateo on 2/04/26.
//
import SwiftUI
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct CustomNavBar: View {
    var offset: CGFloat
    
    var opacity: Double {
        let progress = min(max((offset + 100) / 100, 0), 1)
        return 1 - progress
    }
    
    var body: some View {
        ZStack {
            
            // FONDO CON BLUR
            Color.white.opacity(opacity * 0.9)
                .background(.ultraThinMaterial)
                .blur(radius: 10)
                .ignoresSafeArea()
            
            HStack {
                Text("Mi Álbum")
                    .font(.headline)
                    .foregroundColor(.white.opacity(opacity))
                
                Spacer()
                
                Image(systemName: "person.crop.circle.fill")
                    .foregroundColor(.white.opacity(opacity))
            }
            .padding(.horizontal)
            .padding(.top, 50)
            .padding(.bottom, 10)
        }
        .animation(.easeInOut(duration: 0.25), value: opacity)
    }
}

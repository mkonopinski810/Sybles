import SwiftUI

struct CurrencyBadge: View {
    let coins: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "FFD700"))
            Text("\(coins)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(Color(hex: "FFD700"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color(hex: "FFD700").opacity(0.15))
        )
        .overlay(
            Capsule()
                .stroke(Color(hex: "FFD700").opacity(0.3), lineWidth: 1)
        )
    }
}

struct StreakIndicator: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundColor(Color(hex: "F77F00"))
            Text("×\(streak)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "F77F00"))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(hex: "F77F00").opacity(0.15))
        .clipShape(Capsule())
    }
}

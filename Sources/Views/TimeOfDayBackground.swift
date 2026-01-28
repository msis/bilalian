import SwiftUI

struct TimeOfDayBackground: View {
    let date: Date

    var body: some View {
        LinearGradient(
            colors: gradientColors(for: date),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private func gradientColors(for date: Date) -> [Color] {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<9:
            return [Color(red: 0.95, green: 0.72, blue: 0.45), Color(red: 0.36, green: 0.58, blue: 0.92)]
        case 9..<16:
            return [Color(red: 0.33, green: 0.64, blue: 0.93), Color(red: 0.16, green: 0.33, blue: 0.64)]
        case 16..<19:
            return [Color(red: 0.93, green: 0.45, blue: 0.32), Color(red: 0.24, green: 0.16, blue: 0.43)]
        default:
            return [Color(red: 0.08, green: 0.12, blue: 0.27), Color(red: 0.02, green: 0.02, blue: 0.10)]
        }
    }
}

#Preview {
    TimeOfDayBackground(date: Date())
}


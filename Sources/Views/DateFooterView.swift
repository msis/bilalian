import SwiftUI

/// Footer showing current time plus Gregorian and Hijri dates.
struct DateFooterView: View {
    let display: DateDisplay
    let currentTime: String

    var body: some View {
        VStack(spacing: 6) {
            Text(currentTime)
                .font(.title3)
            Text(display.gregorian)
                .font(.callout)
            Text(display.hijri)
                .font(.callout)
        }
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
}

#Preview {
    DateFooterView(
        display: DateDisplay(gregorian: "January 28, 2026", hijri: "18 Rajab 1447 AH"),
        currentTime: "2:30 PM"
    )
}

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue, Color.cyan, Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 80))
                    .symbolEffect(.pulse, options: .repeat(3))
                    .foregroundStyle(.yellow, .blue)
                    .accessibilityLabel("Animated weather icon")
                Text("Weather Pal")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel("App title: Weather Pal")
            }
        }
    }
}

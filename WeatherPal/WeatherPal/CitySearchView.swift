import SwiftUI

struct CitySearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var city: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showErrorBanner = false
    @State private var hourly: [HourlyWeather] = []
    @State private var daily: [DailyWeather] = []
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color.blue, Color.cyan, Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.primary)
                        TextField("Enter city name", text: $city)
                            .focused($isFocused)
                            .onSubmit { search() }
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground).opacity(0.9))
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)
                if isLoading {
                    ProgressView()
                        .padding(.bottom, 8)
                }
                if !hourly.isEmpty || !daily.isEmpty {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Next hours
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Next hours")
                                    .font(.title2.bold())
                                    .padding(.horizontal)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(hourly) { hour in
                                            VStack(spacing: 8) {
                                                Text("\(hour.temperature)°")
                                                    .font(.title3.bold())
                                                Text("\(hour.humidity)%")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                weatherIconView(iconCode: hour.iconCode, fallback: hour.symbol)
                                                Text("\(hour.hour):00")
                                                    .font(.caption2)
                                            }
                                            .frame(width: 60, height: 120)
                                            .background(.thinMaterial)
                                            .cornerRadius(12)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            // Next 5 days
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Next 5 days")
                                    .font(.title2.bold())
                                    .padding(.horizontal)
                                VStack(spacing: 12) {
                                    ForEach(daily) { day in
                                        HStack(spacing: 16) {
                                            weatherIconView(iconCode: day.iconCode, fallback: day.symbol)
                                            VStack(alignment: .center, spacing: 4) {
                                                Spacer()
                                                Text(day.day)
                                                    .font(.headline)
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                Text("\(day.description) throughout the day.")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                Spacer()
                                            }
                                            Spacer()
                                            Text("\(day.temperature)°")
                                                .font(.title3.bold())
                                        }
                                        .frame(minHeight: 64)
                                        .padding()
                                        .background(.thinMaterial)
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                } else if !isLoading && errorMessage == nil {
                    VStack(spacing: 12) {
                        Image(systemName: "questionmark")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No data found")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                Spacer()
            }
            if showErrorBanner, let error = errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.yellow)
                    Text(error)
                        .font(.callout)
                        .foregroundStyle(.primary)
                    Spacer()
                    Button(action: {
                        showErrorBanner = false
                        errorMessage = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemBackground).opacity(0.95))
                        .shadow(radius: 4)
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .onTapGesture {
                    showErrorBanner = false
                    errorMessage = nil
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: showErrorBanner)
            }
        }
        .navigationTitle("Search City")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { isFocused = true }
        .tint(.white)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                        Text("Back")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    @MainActor
    func search() {
        guard !city.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        errorMessage = nil
        hourly = []
        daily = []
        Task {
            do {
                let (h, d) = try await OpenWeatherService().fetchWeatherByCityName(city)
                hourly = h
                daily = d
            } catch {
                errorMessage = "Could not find weather for \(city)."
                showErrorBanner = true
            }
            isLoading = false
        }
    }

    @MainActor
    func weatherIconView(iconCode: String?, fallback: String) -> some View {
        Group {
            if let iconCode {
                AsyncWeatherIcon(iconCode: iconCode)
            } else {
                Image(systemName: fallback)
            }
        }
        .frame(width: 40, height: 40)
    }
} 
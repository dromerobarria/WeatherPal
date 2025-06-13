import SwiftUI
import TipKit

struct SearchTip: Tip {
    var title: Text {
        Text("Search for a City")
    }
    var message: Text? {
        Text("Tap the magnifying glass in the top right to search for any city.")
    }
    var image: Image? {
        Image(systemName: "magnifyingglass")
    }
}

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    @State private var showErrorBanner = false
    @State private var searchTip = SearchTip()
    @State private var path = NavigationPath()

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

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                LinearGradient(
                    colors: [Color.blue, Color.cyan, Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                VStack(spacing: 0) {
                    Picker("City", selection: $viewModel.selectedCity) {
                        ForEach(City.allCases) { city in
                            Text(city.rawValue).tag(city)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    ScrollView {
                        VStack(spacing: 16) {
                            // Next hours section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Next hours")
                                    .font(.title2.bold())
                                    .padding(.horizontal)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(viewModel.hourly) { hour in
                                            VStack(spacing: 8) {
                                                if hour.symbol == "questionmark" {
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(Color.gray.opacity(0.3))
                                                        .frame(width: 36, height: 24)
                                                    Text("—")
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                    weatherIconView(iconCode: hour.iconCode, fallback: "questionmark")
                                                        .foregroundStyle(.secondary)
                                                    Text("\(hour.hour):00")
                                                        .font(.caption2)
                                                        .foregroundStyle(.secondary)
                                                } else {
                                                    Text("\(hour.temperature)°")
                                                        .font(.title3.bold())
                                                    Text("\(hour.humidity)%")
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                    weatherIconView(iconCode: hour.iconCode, fallback: hour.symbol)
                                                    Text("\(hour.hour):00")
                                                        .font(.caption2)
                                                }
                                            }
                                            .frame(width: 60, height: 120)
                                            .background(.thinMaterial)
                                            .cornerRadius(12)
                                            .accessibilityElement(children: .combine)
                                            .accessibilityLabel(hour.symbol == "questionmark" ? "No data" : "\(hour.hour):00, \(hour.temperature) degrees, \(hour.humidity) percent humidity")
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }

                            // Next 5 days section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Next 5 days")
                                    .font(.title2.bold())
                                    .padding(.horizontal)
                                VStack(spacing: 12) {
                                    ForEach(viewModel.daily) { day in
                                        HStack(spacing: 16) {
                                            if day.symbol == "questionmark" {
                                                weatherIconView(iconCode: day.iconCode, fallback: "questionmark")
                                                    .foregroundStyle(.secondary)
                                                VStack(alignment: .center, spacing: 4) {
                                                    Spacer()
                                                    Text(day.day)
                                                        .font(.headline)
                                                        .foregroundStyle(.secondary)
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                    Text("— throughout the day.")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.secondary)
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                    Spacer()
                                                }
                                                Spacer()
                                                Text("—")
                                                    .font(.title3.bold())
                                                    .foregroundStyle(.secondary)
                                            } else {
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
                                        }
                                        .frame(minHeight: 64)
                                        .padding()
                                        .background(.thinMaterial)
                                        .cornerRadius(12)
                                        .accessibilityElement(children: .combine)
                                        .accessibilityLabel(day.symbol == "questionmark" ? "No data" : "\(day.day), \(day.description), \(day.temperature) degrees")
                                    }
                                }
                                .padding(.horizontal)
                            }
                            Spacer(minLength: 0)
                        }
                        .onAppear {
                            Task { await viewModel.fetchWeather() }
                        }
                    }
                    .refreshable {
                        await viewModel.refresh()
                        if viewModel.errorMessage != nil {
                            showErrorBanner = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                showErrorBanner = false
                                viewModel.clearError()
                            }
                        }
                    }
                }
                if let lastUpdated = viewModel.lastUpdated {
                    HStack {
                        Spacer()
                        Text("Last updated: \(lastUpdated.formatted(date: .abbreviated, time: .shortened))")
                            .font(.footnote)
                            .foregroundStyle(.primary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground).opacity(0.85))
                            )
                        Spacer()
                    }
                    .padding(.bottom, showErrorBanner ? 56 : 24)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                if showErrorBanner, let error = viewModel.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                        Text(error)
                            .font(.callout)
                            .foregroundStyle(.primary)
                        Spacer()
                        Button(action: {
                            showErrorBanner = false
                            viewModel.clearError()
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
                        viewModel.clearError()
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: showErrorBanner)
                }
                if viewModel.isLoading {
                    Color.black.opacity(0.1)
                        .ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                }
            }
            .navigationTitle("Weather Pal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        path.append("search")
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.primary)
                            .padding(8)
                            .background(Circle().fill(Color(.systemBackground).opacity(0.85)))
                    }
                    .accessibilityLabel("Search city")
                    .popoverTip(searchTip)
                }
            }
            .navigationDestination(for: String.self) { route in
                if route == "search" {
                    CitySearchView()
                }
            }
        }
    }
}

struct AsyncWeatherIcon: View {
    let iconCode: String
    @State private var image: Image?

    var body: some View {
        Group {
            if let image {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
            }
        }
        .task(id: iconCode) {
            image = await WeatherIconService.shared.image(for: iconCode)
        }
    }
}

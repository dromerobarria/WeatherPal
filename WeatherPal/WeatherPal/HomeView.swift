import SwiftUI

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.blue, Color.cyan, Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                VStack(spacing: 16) {
                    Picker("City", selection: $viewModel.selectedCity) {
                        ForEach(City.allCases) { city in
                            Text(city.rawValue).tag(city)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

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
                                            Image(systemName: "questionmark")
                                                .font(.title2)
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
                                            Image(systemName: hour.symbol)
                                                .font(.title2)
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
                                        Image(systemName: "questionmark")
                                            .font(.title2)
                                            .foregroundStyle(.secondary)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(day.day)
                                                .font(.headline)
                                                .foregroundStyle(.secondary)
                                            Text("—")
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text("—")
                                            .font(.title3.bold())
                                            .foregroundStyle(.secondary)
                                    } else {
                                        Image(systemName: day.symbol)
                                            .font(.title2)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(day.day)
                                                .font(.headline)
                                            Text(day.description)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text("\(day.temperature)°")
                                            .font(.title3.bold())
                                    }
                                }
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
                    if let lastUpdated = viewModel.lastUpdated {
                        Text("Last updated: \(lastUpdated.formatted(date: .abbreviated, time: .shortened))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 8)
                    }
                }
                .refreshable {
                    await viewModel.refresh()
                }
                .onAppear {
                    Task { await viewModel.fetchWeather() }
                }
                .alert(isPresented: Binding<Bool>(
                    get: { viewModel.errorMessage != nil },
                    set: { newValue in if !newValue { viewModel.clearError() } }
                )) {
                    Alert(
                        title: Text("Error"),
                        message: Text(viewModel.errorMessage ?? ""),
                        dismissButton: .default(Text("OK")) { viewModel.clearError() }
                    )
                }
            }
            .navigationTitle("Weather Pal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Search action
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .accessibilityLabel("Search city")
                }
            }
        }
    }
} 
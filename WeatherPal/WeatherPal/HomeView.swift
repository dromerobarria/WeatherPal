import SwiftUI

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel

    var body: some View {
        NavigationStack {
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
                                .frame(width: 60, height: 120)
                                .background(.thinMaterial)
                                .cornerRadius(12)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("\(hour.hour):00, \(hour.temperature) degrees, \(hour.humidity) percent humidity")
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
                            .padding()
                            .background(.thinMaterial)
                            .cornerRadius(12)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(day.day), \(day.description), \(day.temperature) degrees")
                        }
                    }
                    .padding(.horizontal)
                }
                Spacer(minLength: 0)
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
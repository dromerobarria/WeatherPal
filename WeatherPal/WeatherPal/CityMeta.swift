import Foundation

struct CityMeta: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let country: String
    let lat: Double
    let lon: Double
}

final class CityMetaService {
    static let shared = CityMetaService()
    private(set) var cities: [CityMeta] = []

    init() {
        loadCities()
    }

    private func loadCities() {
        guard let url = Bundle.main.url(forResource: "city_list", withExtension: "json") else { return }
        do {
            let data = try Data(contentsOf: url)
            cities = try JSONDecoder().decode([CityMeta].self, from: data)
        } catch {
            print("[CityMetaService] Failed to load city list: \(error)")
        }
    }

    func search(_ query: String) -> [CityMeta] {
        guard !query.isEmpty else { return [] }
        let lower = query.lowercased()
        return cities.filter { $0.name.lowercased().contains(lower) || $0.country.lowercased().contains(lower) }
    }
} 
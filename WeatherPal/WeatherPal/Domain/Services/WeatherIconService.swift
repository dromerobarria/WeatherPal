import SwiftUI

actor WeatherIconService {
    static let shared = WeatherIconService()
    private let iconBaseURL = "https://openweathermap.org/img/wn/"
    private let cacheDirectory: URL = {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("WeatherIcons")
    }()
    private let lastFetchKey = "WeatherIconService.lastFetchDate"

    init() {
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    private func iconURL(for code: String) -> URL {
        URL(string: "\(iconBaseURL)\(code)@2x.png")!
    }

    private func localIconPath(for code: String) -> URL {
        cacheDirectory.appendingPathComponent("\(code)@2x.png")
    }

    private func isCacheValid() -> Bool {
        guard let lastFetch = UserDefaults.standard.object(forKey: lastFetchKey) as? Date else { return false }
        return Calendar.current.isDateInToday(lastFetch)
    }

    private func updateLastFetchDate() {
        UserDefaults.standard.set(Date(), forKey: lastFetchKey)
    }

    func image(for iconCode: String) async -> Image {
        let localPath = localIconPath(for: iconCode)
        if FileManager.default.fileExists(atPath: localPath.path), isCacheValid() {
            if let uiImage = UIImage(contentsOfFile: localPath.path) {
                return Image(uiImage: uiImage)
            }
        }
        // Download and cache
        do {
            let (data, _) = try await URLSession.shared.data(from: iconURL(for: iconCode))
            try data.write(to: localPath, options: .atomic)
            updateLastFetchDate()
            if let uiImage = UIImage(data: data) {
                return Image(uiImage: uiImage)
            }
        } catch {
            // Fallback to system image if download fails
            return Image(systemName: "questionmark")
        }
        return Image(systemName: "questionmark")
    }
} 
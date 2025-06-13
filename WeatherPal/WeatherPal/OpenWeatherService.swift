import Foundation

struct OpenWeatherService: WeatherServiceProtocol {
    private let apiKey = "9170e0e85794088df319259526c55afd"
    private let session: URLSession = .shared

    func fetchWeather(lat: Double, lon: Double) async throws -> (hourly: [HourlyWeather], daily: [DailyWeather]) {
        let url = URL(string: "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&units=metric&appid=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
        let now = Calendar.current.component(.hour, from: Date())
        let hourly = decoded.hourly.filter { hour in
            let date = Date(timeIntervalSince1970: hour.dt)
            let hourComponent = Calendar.current.component(.hour, from: date)
            return hourComponent >= now
        }.prefix(24 - now).enumerated().map { idx, hour in
            let date = Date(timeIntervalSince1970: hour.dt)
            let hourComponent = Calendar.current.component(.hour, from: date)
            return HourlyWeather(
                hour: hourComponent,
                temperature: Int(hour.temp.rounded()),
                humidity: hour.humidity,
                symbol: hour.weather.first?.sfSymbol ?? "cloud.sun.fill"
            )
        }
        let daily = decoded.daily.prefix(5).map { day in
            let date = Date(timeIntervalSince1970: day.dt)
            let dayLabel = date.formatted(.dateTime.weekday())
            return DailyWeather(
                day: dayLabel,
                description: day.weather.first?.main ?? "Clear",
                temperature: Int(day.temp.day.rounded()),
                symbol: day.weather.first?.sfSymbol ?? "cloud.sun.fill"
            )
        }
        return (Array(hourly), Array(daily))
    }

    func fetchWeather(cityName: String) async throws -> (hourly: [HourlyWeather], daily: [DailyWeather]) {
        // 1. Geocode city name
        let geoURL = URL(string: "https://api.openweathermap.org/geo/1.0/direct?q=\(cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cityName)&limit=1&appid=\(apiKey)")!
        let (geoData, geoResponse) = try await session.data(for: URLRequest(url: geoURL))
        guard let geoHttp = geoResponse as? HTTPURLResponse, geoHttp.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let geoResults = try JSONDecoder().decode([GeocodeResult].self, from: geoData)
        guard let geo = geoResults.first else {
            throw URLError(.cannotFindHost)
        }
        // 2. Fetch weather by coordinates
        return try await fetchWeather(lat: geo.lat, lon: geo.lon)
    }
}

private struct GeocodeResult: Decodable {
    let name: String
    let lat: Double
    let lon: Double
}

// MARK: - OpenWeather API Models

private struct OpenWeatherResponse: Decodable {
    let hourly: [OWHour]
    let daily: [OWDay]
}

private struct OWHour: Decodable {
    let dt: TimeInterval
    let temp: Double
    let humidity: Int
    let weather: [OWWeather]
}

private struct OWDay: Decodable {
    let dt: TimeInterval
    let temp: OWDayTemp
    let weather: [OWWeather]
}

private struct OWDayTemp: Decodable {
    let day: Double
}

private struct OWWeather: Decodable {
    let main: String
    let icon: String
    let description: String

    var sfSymbol: String {
        switch icon.prefix(2) {
        case "01": return "sun.max.fill"
        case "02": return "cloud.sun.fill"
        case "03", "04": return "cloud.fill"
        case "09", "10": return "cloud.rain.fill"
        case "11": return "cloud.bolt.rain.fill"
        case "13": return "snow"
        case "50": return "cloud.fog.fill"
        default: return "cloud.sun.fill"
        }
    }
} 
import Foundation

func formatNewsDate(_ value: String) -> String {
    let parser = ISO8601DateFormatter()

    parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let fractionalDate = parser.date(from: value)
    parser.formatOptions = [.withInternetDateTime]
    guard let date = fractionalDate ?? parser.date(from: value) else {
        return value
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy HH:mm"
    formatter.locale = Locale(identifier: "tr_TR")
    formatter.timeZone = TimeZone(identifier: "Europe/Istanbul")

    return formatter.string(from: date)
}

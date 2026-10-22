// L10n.swift — machine-readable output helpers + lightweight AppKit localization.
// The bundled table starts with Simplified Chinese; AppKit falls back to the
// English development strings when a key or locale is unavailable.
import Foundation

/// `--json`: read commands emit machine-readable output for scripts and agents.
var jsonMode = false

func emitJSON(_ obj: [String: Any]) {
    let data = try? JSONSerialization.data(withJSONObject: obj,
                                           options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
    print(String(data: data ?? Data("{}".utf8), encoding: .utf8) ?? "{}")
}

/// Errors are machine-readable too: {"error":…,"code":…} in JSON mode, plain text otherwise.
func emitError(_ message: String, code: String) {
    if jsonMode { emitJSON(["error": message, "code": code]) } else { print("❌ \(message)") }
}

// MARK: - Localization

private var l10nCache: [String: String]?
private let l10nQueue = DispatchQueue(label: "com.ben0128.nibble.l10n")

private func loadLocalizedStrings() -> [String: String] {
    if let cached = l10nCache { return cached }
    let loaded = l10nQueue.sync { () -> [String: String] in
        if let cached = l10nCache { return cached }
        guard let url = Bundle.main.url(forResource: "Localizable",
                                        withExtension: "strings",
                                        subdirectory: nil,
                                        localization: "zh-Hans"),
              let data = try? Data(contentsOf: url),
              let value = try? PropertyListSerialization.propertyList(
                  from: data, options: [], format: nil
              ) as? [String: String] else { return [:] }
        l10nCache = value
        return value
    }
    return loaded
}

func localized(_ key: String) -> String {
    loadLocalizedStrings()[key] ?? key
}

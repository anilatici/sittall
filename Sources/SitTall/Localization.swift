import Foundation

func sitTallLocalized(_ key: String.LocalizationValue) -> String {
    String(localized: key, bundle: .sitTallResources)
}

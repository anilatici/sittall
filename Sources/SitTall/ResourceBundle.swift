import Foundation

extension Bundle {
    static var sitTallResources: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        return .main
        #endif
    }
}

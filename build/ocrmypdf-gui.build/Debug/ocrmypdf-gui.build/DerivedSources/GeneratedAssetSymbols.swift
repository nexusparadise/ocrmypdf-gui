import Foundation
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "AppIcon.svg" asset catalog image resource.
    static let appIconSvg = DeveloperToolsSupport.ImageResource(name: "AppIcon.svg", bundle: resourceBundle)

    /// The "Header.svg" asset catalog image resource.
    static let headerSvg = DeveloperToolsSupport.ImageResource(name: "Header.svg", bundle: resourceBundle)

    /// The "HeaderImage white.svg" asset catalog image resource.
    static let headerImageWhiteSvg = DeveloperToolsSupport.ImageResource(name: "HeaderImage white.svg", bundle: resourceBundle)

    /// The "HeaderImage white2.svg" asset catalog image resource.
    static let headerImageWhite2Svg = DeveloperToolsSupport.ImageResource(name: "HeaderImage white2.svg", bundle: resourceBundle)

    /// The "HeaderImage.svg" asset catalog image resource.
    static let headerImageSvg = DeveloperToolsSupport.ImageResource(name: "HeaderImage.svg", bundle: resourceBundle)

}


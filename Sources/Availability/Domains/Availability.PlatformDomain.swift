import SemanticVersions

extension Availability {
    @frozen public enum PlatformDomain: String, CaseIterable, Equatable, Hashable, Sendable {
        case Android
        case bridgeOS
        case iOS
        case macOS
        case macCatalyst
        case OpenBSD
        case tvOS
        case visionOS
        case watchOS
        case Windows

        case iOSApplicationExtension
        case macOSApplicationExtension
        case macCatalystApplicationExtension
        case tvOSApplicationExtension
        case watchOSApplicationExtension
    }
}
extension Availability.PlatformDomain: AvailabilityDomain {
    public typealias Bound = NumericVersion
    public typealias Deprecation = Availability.AnyRange
    public typealias Unavailability = Availability.EternalRange
}
extension Availability.PlatformDomain: CustomStringConvertible {
    @inlinable public var description: String {
        switch self {
        case .Android: "Android"
        case .bridgeOS: "bridgeOS"
        case .iOS: "iOS"
        case .macOS: "macOS"
        case .macCatalyst: "Mac Catalyst"
        case .OpenBSD: "OpenBSD"
        case .tvOS: "tvOS"
        case .visionOS: "visionOS"
        case .watchOS: "watchOS"
        case .Windows: "Windows"
        case .iOSApplicationExtension: "iOS App Extension"
        case .macOSApplicationExtension: "macOS App Extension"
        case .macCatalystApplicationExtension: "Mac Catalyst App Extension"
        case .tvOSApplicationExtension: "tvOS App Extension"
        case .watchOSApplicationExtension: "watchOS App Extension"
        }
    }
}

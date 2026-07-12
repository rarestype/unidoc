import Availability
import BSON
internal import Bijection

extension Availability.AnyDomain: BSON.Keyspace {
    /// Represents an ``Availability.AnyDomain`` in the BSON ABI. This has a
    /// single-character raw value, for storage efficiency, and is not intended
    /// to be human-readable.
    @Bijection(label: "rawValue") @inlinable public var rawValue: String {
        switch self {
        case .agnostic(.swift): "s"
        case .agnostic(.swiftPM): "p"
        case .platform(.Android): "a"
        case .platform(.bridgeOS): "b"
        case .platform(.iOS): "i"
        case .platform(.macOS): "m"
        case .platform(.macCatalyst): "c"
        case .platform(.tvOS): "t"
        case .platform(.visionOS): "v"
        case .platform(.watchOS): "w"
        case .platform(.Windows): "n"
        case .platform(.OpenBSD): "o"
        case .platform(.iOSApplicationExtension): "I"
        case .platform(.macOSApplicationExtension): "M"
        case .platform(.macCatalystApplicationExtension): "C"
        case .platform(.tvOSApplicationExtension): "T"
        case .platform(.watchOSApplicationExtension): "W"
        case .universal: "u"
        }
    }
}

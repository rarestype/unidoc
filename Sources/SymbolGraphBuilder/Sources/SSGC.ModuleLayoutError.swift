import SystemIO

extension SSGC {
    enum ModuleLayoutError: Error {
        case foundMultipleModulemaps(FilePath, FilePath)
        case missingSourcesDirectory(FilePath.Directory)
    }
}

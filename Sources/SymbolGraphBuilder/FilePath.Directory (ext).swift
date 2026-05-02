import SystemIO

extension FilePath.Directory {
    func absolute() throws -> Self { .init(path: try self.path.absolute()) }
}

import SystemIO

extension FilePath {
    func absolute() throws -> Self {
        if  self.isAbsolute {
            return self
        } else {
            let current: FilePath.Directory = try .current
            return current.path.appending(self.components).lexicallyNormalized()
        }
    }
}

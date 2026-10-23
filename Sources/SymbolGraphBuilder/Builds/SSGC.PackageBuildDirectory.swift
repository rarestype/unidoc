import Symbols
import SystemIO

extension SSGC {
    /// An SPM build directory. It is usually, but not always, named `.build`.
    struct PackageBuildDirectory {
        let configuration: PackageBuildConfiguration
        let location: FilePath.Directory

        init(configuration: PackageBuildConfiguration, location: FilePath.Directory) {
            guard location.path.isAbsolute else {
                fatalError("""
                    Package build directory must be an absolute path,
                    for IndexStoreDB compatibility!
                    """)
            }

            self.configuration = configuration
            self.location = location
        }
    }
}
extension SSGC.PackageBuildDirectory {
    var index: FilePath.Directory {
        self.location / "\(self.configuration)" / "index"
    }

    var indexStore: FilePath.Directory {
        let swiftBuild: FilePath.Directory = self.location / "out"
        if (try? (swiftBuild / "v5").exists) == true {
            return swiftBuild
        }
        return self.location / "\(self.configuration)" / "index" / "store"
    }

    var indexDatabase: FilePath.Directory {
        let swiftBuild: FilePath.Directory = self.location / "out" / "db"
        if (try? (self.location / "out" / "v5").exists) == true {
            return swiftBuild
        }
        return self.location / "\(self.configuration)" / "index" / "db"
    }

    var modules: [FilePath.Directory] {
        var paths: [FilePath.Directory] = []

        let products: FilePath.Directory = self.location / "out" / "Products"
        if (try? products.exists) == true {
            for case .success(let component) in products {
                let name: String = "\(component)"
                if  name.hasPrefix("\(self.configuration)-") {
                    paths.append(products / component)
                }
            }
        }

        let intermediates: FilePath.Directory = self.location / "out" / "Intermediates.noindex"
        if (try? intermediates.exists) == true {
            for case .success(let component) in intermediates {
                let name: String = "\(component)"
                if  name.hasPrefix("GeneratedModuleMaps-") {
                    paths.append(intermediates / component)
                }
            }
        }

        let native: FilePath.Directory = self.location / "\(self.configuration)" / "Modules"
        if (try? native.exists) == true {
            paths.append(native)
        }

        let config: FilePath.Directory = self.location / "\(self.configuration)"
        if (try? config.exists) == true, !paths.contains(config) {
            paths.append(config)
        }

        return paths
    }

    func modulemap(target: String) -> FilePath? {
        let intermediates: FilePath.Directory = self.location / "out" / "Intermediates.noindex"
        if (try? intermediates.exists) == true {
            for case .success(let component) in intermediates {
                let name: String = "\(component)"
                if  name.hasPrefix("GeneratedModuleMaps-") {
                    let map: FilePath = intermediates / component / "\(target).modulemap"
                    if (try? map.exists) == true {
                        return map
                    }
                }
            }
        }

        let native: FilePath = self.build(target: target) / "module.modulemap"
        if (try? native.exists) == true {
            return native
        }

        return nil
    }

    /// This takes an unmangled target name, not a c99 name.
    private func build(target: String) -> FilePath.Directory {
        self.location / "\(self.configuration)" / "\(target).build"
    }
}

import Symbols
import SystemIO

extension SSGC {
    /// An SPM build directory. It is usually, but not always, named `.build`.
    struct PackageBuildDirectory {
        enum Layout {
            case native
            case swiftbuild
        }

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
    var layout: Layout {
        let flag: FilePath = self.location / ".buildSystem_\(self.configuration)"
        if case true? = try? flag.exists,
            let text: String = try? flag.readLine(),
                text == "swiftbuild" {
            return .swiftbuild
        }
        if case true? = try? (self.location / "out").exists {
            return .swiftbuild
        }
        return .native
    }

    var indexStore: FilePath.Directory {
        switch self.layout {
        case .swiftbuild:
            self.location / "out"
        case .native:
            self.location / "\(self.configuration)" / "index" / "store"
        }
    }

    var indexDatabase: FilePath.Directory {
        switch self.layout {
        case .swiftbuild:
            self.location / "out" / "db"
        case .native:
            self.location / "\(self.configuration)" / "index" / "db"
        }
    }

    var modules: [FilePath.Directory] {
        switch self.layout {
        case .native:
            let configuration: FilePath.Directory = self.location / "\(self.configuration)"
            let modules: FilePath.Directory = configuration / "Modules"
            if case true? = try? modules.exists {
                return [modules]
            }
            return [configuration]

        case .swiftbuild:
            let configuration: FilePath.Directory = self.location / "\(self.configuration)"
            var paths: [FilePath.Directory] = [configuration]

            let out: FilePath.Directory = self.location / "out"
            let intermediates: FilePath.Directory = out / "Intermediates.noindex"
            if case true? = try? intermediates.exists {
                for case .success(let package) in intermediates {
                    guard "\(package)".hasSuffix(".build") else {
                        continue
                    }
                    let packageDirectory: FilePath.Directory = intermediates / package
                    for case .success(let configuration) in packageDirectory {
                        guard "\(configuration)".lowercased().hasPrefix(
                            "\(self.configuration)"
                        ) else {
                            continue
                        }
                        let configurationDirectory: FilePath.Directory =
                        packageDirectory / configuration
                        for case .success(let target) in configurationDirectory {
                            let targetDirectory: FilePath.Directory =
                            configurationDirectory / target
                            let objectsNormal: FilePath.Directory =
                            targetDirectory / "Objects-normal"
                            guard case true? = try? objectsNormal.exists else {
                                continue
                            }
                            for case .success(let architecture) in objectsNormal {
                                let architectureDirectory: FilePath.Directory =
                                objectsNormal / architecture
                                let modules: FilePath.Directory =
                                architectureDirectory / "Modules"
                                if case true? = try? modules.exists {
                                    paths.append(modules)
                                }
                            }
                        }
                    }
                }
            }

            return paths
        }
    }

    func modulemap(target: String) -> FilePath? {
        switch self.layout {
        case .swiftbuild:
            let out: FilePath.Directory = self.location / "out"
            let intermediates: FilePath.Directory = out / "Intermediates.noindex"
            if case true? = try? intermediates.exists {
                for case .success(let component) in intermediates {
                    if "\(component)".hasPrefix("GeneratedModuleMaps") {
                        let map: FilePath = intermediates / component / "\(target).modulemap"
                        if case true? = try? map.exists {
                            return map
                        }
                    }
                }
            }
            return nil

        case .native:
            let configuration: FilePath.Directory = self.location / "\(self.configuration)"
            let targetDirectory: FilePath.Directory = configuration / "\(target).build"
            let moduleMap: FilePath = targetDirectory / "module.modulemap"
            if case true? = try? moduleMap.exists {
                return moduleMap
            }
            let namedMap: FilePath = targetDirectory / "\(target).modulemap"
            if case true? = try? namedMap.exists {
                return namedMap
            }
            return nil
        }
    }
}

import SHA1
import Symbols
import SystemAsync
import SystemIO
import UnixTime

extension SSGC {
    struct Checkout {
        /// Absolute path to the checkout directory.
        let location: FilePath.Directory
        let revision: SHA1
        let date: UnixMillisecond

        private init(location: FilePath.Directory, revision: SHA1, date: UnixMillisecond) {
            self.location = location
            self.revision = revision
            self.date = date
        }
    }
}
extension SSGC.Checkout {
    static func checkout(
        project name: Symbol.Package,
        from repository: String,
        at reference: String,
        in workspace: SSGC.Workspace,
        clean: Bool = false
    ) async throws -> Self {
        //  The directory layout looks something like:
        //
        //  myworkspace/
        //  ├── artifacts/
        //  └── checkouts/
        //      └── swift-example-package/
        //          ├── .git/
        //          ├── .build/
        //          ├── .build.unidoc/
        //          ├── Package.swift
        //          └── ...

        let clone: FilePath.Directory = workspace.checkouts / "\(name)"
        if  clean {
            try clone.remove()
        }

        if  repository.starts(with: "https://x-access-token:") {
            print("WARNING: redacted repository URL because it contains an access token.")
        } else {
            print("Pulling repository from remote: \(repository)")
        }

        if  try clone.exists {
            try SystemProcess.init(command: "git", "-C", "\(clone)", "fetch")()
        } else {
            try SystemProcess.init(
                command: "git", "-C", "\(workspace.checkouts)",
                "clone", repository, "\(name)", "--recurse-submodules"
            )()
        }

        try SystemProcess.init(
            command: "git", "-C", "\(clone)",
            "-c", "advice.detachedHead=false",
            "checkout", "-f", reference,
            "--recurse-submodules"
        )()

        // Get the SHA-1 hash of the current commit
        let (revisionLine, _): (stdout: String, _) = try await Subprocess.capture {
            try SystemProcess.init(
                command: "git", "-C", "\(clone)",
                "rev-list", "-n", "1", reference,
                stdout: $1,
                stderr: $2,
            )
        }

        //  Get the timestamp of the current commit, in seconds since the Unix epoch.
        //  64 bytes should be enough for any Unix timestamp.
        let (unixSecondLine, _): (stdout: String, _) = try await Subprocess.capture {
            try SystemProcess.init(
                command: "git", "-C", "\(clone)",
                "log", "-1", "--format=%ct",
                stdout: $1,
                stderr: $2,
            )
        }

        //  Note: output lines contains trailing newline
        guard
        let revision: SHA1 = .init(revisionLine.prefix(while: { !$0.isNewline })) else {
            fatalError("Could not parse revision from git output: \(revisionLine)")
        }

        guard
        let unixSecond: Int64 = .init(unixSecondLine.prefix(while: { !$0.isNewline })) else {
            fatalError("Could not parse date from git output: \(unixSecondLine)")
        }

        return .init(location: clone, revision: revision, date: .init(index: 1000 * unixSecond))
    }
}

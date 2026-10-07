// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-memory-allocation",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "Memory Aligned Test Support", targets: ["Memory Aligned Test Support"]),
        .library(name: "Memory Aligned", targets: ["Memory Aligned"]),
        .library(name: "Memory Small", targets: ["Memory Small"]),
        .library(name: "Memory Inline", targets: ["Memory Inline"]),
        .library(name: "Memory Allocator Arena", targets: ["Memory Allocator Arena"]),
        .library(
            name: "Memory Allocator",
            targets: ["Memory Allocator"]
        ),
        .library(
            name: "Memory Allocator Protocol",
            targets: ["Memory Allocator Protocol"]
        ),
        .library(
            name: "Memory Allocation",
            targets: ["Memory Allocation"]
        ),
        .library(
            name: "Memory Allocator Pool",
            targets: ["Memory Allocator Pool"]
        ),
        .library(
            name: "Memory Pool",
            targets: ["Memory Pool"]
        ),
        .library(
            name: "Memory Pool Test Support",
            targets: ["Memory Pool Test Support"]
        ),
    ],
    traits: [
        .trait(name: "MemoryAllocatorArena", description: "MemoryAllocatorArena integration"),
        .trait(name: "MemoryInline", description: "MemoryInline integration", enabledTraits: ["MemoryAllocatorArena"]),
        .trait(name: "MemorySmall", description: "MemorySmall integration", enabledTraits: ["MemoryInline"]),
        .trait(name: "MemoryAligned", description: "MemoryAligned integration"),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-span.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-growth.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-byte.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-carrier.git", branch: "main"),

        .package(
            url: "https://github.com/swift-atoms/swift-cardinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-memory.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-tagged.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-index.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-ratio.git",
            branch: "main", traits: ["Difference"]),
        .package(
            url: "https://github.com/swift-atoms/swift-bit.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-ordinal.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-atoms/swift-difference.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-property.git", branch: "main"),
    ],
    targets: [
        .testTarget(
            name: "Absorbed swift-memory-aligned Tests",
            dependencies: [
                .product(name: "Growth", package: "swift-growth", condition: .when(traits: ["MemoryAligned"])),
                .product(name: "Index", package: "swift-index", condition: .when(traits: ["MemoryAligned"])),
                .target(name: "Memory Aligned Test Support", condition: .when(traits: ["MemoryAligned"])),
            ],
            path: "Tests/Absorbed swift-memory-aligned Tests"
        ),
        .target(
            name: "Memory Aligned Test Support",
            dependencies: [
                .product(name: "Memory Test Support", package: "swift-memory", condition: .when(traits: ["MemoryAligned"])),
                .target(name: "Memory Aligned", condition: .when(traits: ["MemoryAligned"])),
            ],
            path: "Tests/Memory Aligned Test Support"
        ),
        .target(
            name: "Memory Aligned",
            dependencies: [
                .product(name: "Byte", package: "swift-byte", condition: .when(traits: ["MemoryAligned"])),
                .product(name: "Growth", package: "swift-growth", condition: .when(traits: ["MemoryAligned"])),
                .product(name: "Index", package: "swift-index", condition: .when(traits: ["MemoryAligned"])),
                .product(name: "Memory", package: "swift-memory", condition: .when(traits: ["MemoryAligned"])),
                .product(name: "Ordinal", package: "swift-ordinal", condition: .when(traits: ["MemoryAligned"])),
                .product(name: "Span", package: "swift-span", condition: .when(traits: ["MemoryAligned"])),
            ],
            path: "Sources/Memory Aligned"
        ),
        .testTarget(
            name: "Absorbed swift-memory-small Tests",
            dependencies: [
                .product(name: "Cardinal", package: "swift-cardinal", condition: .when(traits: ["MemorySmall"])),
                .product(name: "Memory", package: "swift-memory", condition: .when(traits: ["MemorySmall"])),
                .product(name: "Tagged", package: "swift-tagged", condition: .when(traits: ["MemorySmall"])),
                .target(name: "Memory Small", condition: .when(traits: ["MemorySmall"])),
            ],
            path: "Tests/Absorbed swift-memory-small Tests"
        ),
        .target(
            name: "Memory Small",
            dependencies: [
                .product(name: "Cardinal", package: "swift-cardinal", condition: .when(traits: ["MemorySmall"])),
                .product(name: "Memory", package: "swift-memory", condition: .when(traits: ["MemorySmall"])),
                .product(name: "Tagged", package: "swift-tagged", condition: .when(traits: ["MemorySmall"])),
                .target(name: "Memory Allocator Protocol", condition: .when(traits: ["MemorySmall"])),
                .target(name: "Memory Inline", condition: .when(traits: ["MemorySmall"])),
            ],
            path: "Sources/Memory Small"
        ),
        .testTarget(
            name: "Absorbed swift-memory-inline Tests",
            dependencies: [
                .product(name: "Cardinal", package: "swift-cardinal", condition: .when(traits: ["MemoryInline", "MemorySmall"])),
                .target(name: "Memory Allocator Pool", condition: .when(traits: ["MemoryInline", "MemorySmall"])),
                .product(name: "Memory", package: "swift-memory", condition: .when(traits: ["MemoryInline", "MemorySmall"])),
                .product(name: "Tagged", package: "swift-tagged", condition: .when(traits: ["MemoryInline", "MemorySmall"])),
                .target(name: "Memory Allocator Arena", condition: .when(traits: ["MemoryInline", "MemorySmall"])),
                .target(name: "Memory Inline", condition: .when(traits: ["MemoryInline", "MemorySmall"])),
            ],
            path: "Tests/Absorbed swift-memory-inline Tests"
        ),
        .target(
            name: "Memory Inline",
            dependencies: [
                .product(name: "Cardinal", package: "swift-cardinal", condition: .when(traits: ["MemoryInline", "MemorySmall"])),
                .product(name: "Memory", package: "swift-memory", condition: .when(traits: ["MemoryInline", "MemorySmall"])),
                .target(name: "Memory Allocator Protocol", condition: .when(traits: ["MemoryInline", "MemorySmall"])),
            ],
            path: "Sources/Memory Inline"
        ),
        .testTarget(
            name: "Absorbed swift-memory-allocator-arena Tests",
            dependencies: [
                .product(name: "Memory", package: "swift-memory", condition: .when(traits: ["MemoryAllocatorArena", "MemoryInline", "MemorySmall"])),
                .target(name: "Memory Allocator Arena", condition: .when(traits: ["MemoryAllocatorArena", "MemoryInline", "MemorySmall"])),
            ],
            path: "Tests/Absorbed swift-memory-allocator-arena Tests"
        ),
        .target(
            name: "Memory Allocator Arena",
            dependencies: [
                .product(name: "Memory", package: "swift-memory", condition: .when(traits: ["MemoryAllocatorArena", "MemoryInline", "MemorySmall"])),
                .target(name: "Memory Allocator Protocol", condition: .when(traits: ["MemoryAllocatorArena", "MemoryInline", "MemorySmall"])),
                .target(name: "Memory Allocator", condition: .when(traits: ["MemoryAllocatorArena", "MemoryInline", "MemorySmall"])),
            ],
            path: "Sources/Memory Allocator Arena"
        ),
        .target(
            name: "Memory Allocator",
            dependencies: [
                .product(name: "Memory", package: "swift-memory"),
            ]
        ),
        .target(
            name: "Memory Allocator Protocol",
            dependencies: [
                .target(name: "Memory Allocator"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),
        .target(
            name: "Memory Allocator Pool",
            dependencies: [
                .product(name: "Carrier", package: "swift-carrier"),

                .target(name: "Memory Allocator"),
                .target(name: "Memory Allocator Protocol"),
                .target(name: "Memory Pool"),
                .product(name: "Memory", package: "swift-memory"),
                .product(
                    name: "Memory",
                    package: "swift-memory"
                ),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Ratio", package: "swift-ratio"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Bit", package: "swift-bit"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Difference", package: "swift-difference"),
                .product(name: "Property", package: "swift-property"),
            ]
        ),
        .target(
            name: "Memory Allocation",
            dependencies: [
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),
        .target(
            name: "Memory Pool",
            dependencies: [
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),
        .target(
            name: "Memory Pool Test Support",
            dependencies: [
                .target(name: "Memory Pool"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Tagged", package: "swift-tagged"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Memory Allocator Pool Tests",
            dependencies: [
                .target(name: "Memory Allocator Pool"),
                .target(name: "Memory Allocator Protocol"),
                .target(name: "Memory Pool"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),
        .testTarget(
            name: "Memory Allocation Tests",
            dependencies: [
                .target(name: "Memory Allocator"),
                .target(name: "Memory Allocator Protocol"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(
                    name: "Cardinal",
                    package: "swift-cardinal"
                ),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("RawLayout"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}

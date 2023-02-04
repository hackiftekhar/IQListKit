// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "IQListKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "IQListKit", targets: ["IQListKit"])
    ],
   targets: [
       .target(
           name: "IQListKit",
           path: "IQListKit"
       )
   ]
)

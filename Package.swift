import PackageDescription

let package = Package(
    name: "IQListKit",
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

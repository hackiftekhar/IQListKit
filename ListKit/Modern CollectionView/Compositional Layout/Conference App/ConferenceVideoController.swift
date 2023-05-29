/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Controller object that manages the videos and video collection for the sample app
*/

import Foundation
import UIKit

class ConferenceVideoController {

    struct Video: Hashable {
        let title: String
        let category: String
        let color: UIColor
        let identifier = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }

    struct VideoCollection: Hashable {
        let orthogonalScrollBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior
        let title: String
        let videos: [Video]

        let identifier = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }

    var collections: [VideoCollection] {
        return _collections
    }

    init() {
        generateCollections()
    }
    fileprivate var _collections = [VideoCollection]()
}

extension ConferenceVideoController {
    func generateCollections() {
        _collections = [
            VideoCollection(orthogonalScrollBehaviour: .continuous,
                            title: "The New iPad Pro",
                            videos: [Video(title: "Bringing Your Apps to the New iPad Pro",
                                           category: "Tech Talks", color: UIColor.systemRed),
                                     Video(title: "Designing for iPad Pro and Apple Pencil",
                                           category: "Tech Talks", color: UIColor.systemGreen)]),

            VideoCollection(orthogonalScrollBehaviour: .continuousGroupLeadingBoundary,
                            title: "iPhone and Apple Watch",
                            videos: [Video(title: "Building Apps for iPhone XS, iPhone XS Max, and iPhone XR",
                                            category: "Tech Talks", color: UIColor.systemBlue),
                                      Video(title: "Designing for Apple Watch Series 4",
                                            category: "Tech Talks", color: UIColor.systemOrange),
                                      Video(title: "Developing Complications for Apple Watch Series 4",
                                            category: "Tech Talks", color: UIColor.systemYellow),
                                      Video(title: "What's New in Core NFC",
                                            category: "Tech Talks", color: UIColor.systemPink)]),

            VideoCollection(orthogonalScrollBehaviour: .paging,
                            title: "App Store Connect",
                            videos: [Video(title: "App Store Connect Basics",
                                           category: "App Store Connect", color: UIColor.systemPurple),
                                      Video(title: "App Analytics Retention",
                                            category: "App Store Connect", color: UIColor.systemTeal),
                                      Video(title: "App Analytics Metrics",
                                            category: "App Store Connect", color: UIColor.systemIndigo),
                                      Video(title: "App Analytics Overview",
                                            category: "App Store Connect", color: UIColor.systemBrown),
                                      Video(title: "TestFlight",
                                            category: "App Store Connect", color: UIColor.systemRed)]),

            VideoCollection(orthogonalScrollBehaviour: .groupPaging,
                            title: "Apps on Your Wrist",
                            videos: [Video(title: "What's new in watchOS",
                                           category: "Conference 2018", color: UIColor.systemGreen),
                                      Video(title: "Updating for Apple Watch Series 3",
                                            category: "Tech Talks", color: UIColor.systemBlue),
                                      Video(title: "Planning a Great Apple Watch Experience",
                                            category: "Conference 2017", color: UIColor.systemOrange),
                                      Video(title: "News Ways to Work with Workouts",
                                            category: "Conference 2018", color: UIColor.systemYellow),
                                      Video(title: "Siri Shortcuts on the Siri Watch Face",
                                            category: "Conference 2018", color: UIColor.systemPink),
                                      Video(title: "Creating Audio Apps for watchOS",
                                            category: "Conference 2018", color: UIColor.systemPurple),
                                      Video(title: "Designing Notifications",
                                            category: "Conference 2018", color: UIColor.systemIndigo)]),

            VideoCollection(orthogonalScrollBehaviour: .groupPagingCentered,
                            title: "Speaking with Siri",
                            videos: [Video(title: "Introduction to Siri Shortcuts",
                                           category: "Conference 2018", color: UIColor.systemBrown),
                                     Video(title: "Building for Voice with Siri Shortcuts",
                                           category: "Conference 2018", color: UIColor.systemRed),
                                     Video(title: "What's New in SiriKit",
                                           category: "Conference 2017", color: UIColor.systemGreen),
                                     Video(title: "Making Great SiriKit Experiences",
                                           category: "Conference 2017", color: UIColor.systemBlue),
                                     Video(title: "Increase Usage of You App With Proactive Suggestions",
                                           category: "Conference 2018", color: UIColor.systemOrange)])
                                    ]
    }
}

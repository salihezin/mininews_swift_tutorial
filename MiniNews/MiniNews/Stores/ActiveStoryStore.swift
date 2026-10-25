import Foundation
import Observation

@Observable
class ActiveStoryStore {
    private(set) var activeStory: String = "Beşiktaş"
    private(set) var visitedStories: Set<String>
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        visitedStories = Set(defaults.stringArray(forKey: "visitedNewsTopics") ?? [])
        visitedStories.insert(activeStory)
    }

    func setActiveStory(_ story: String) {
        activeStory = story
        visitedStories.insert(story)
        defaults.set(Array(visitedStories), forKey: "visitedNewsTopics")
    }

    func isActiveStory(_ story: String) -> Bool { activeStory == story }
    func hasVisited(_ story: String) -> Bool { visitedStories.contains(story) }
}

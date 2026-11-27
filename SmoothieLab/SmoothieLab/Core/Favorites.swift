import Foundation
import Observation

/// Saved recipe ids, kept in UserDefaults on the device.
@Observable
final class Favorites {
    private(set) var ids: Set<String>
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let key = "favoriteRecipeIDs"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.ids = Set(defaults.stringArray(forKey: "favoriteRecipeIDs") ?? [])
    }

    func contains(_ recipe: Recipe) -> Bool { ids.contains(recipe.id) }

    func toggle(_ recipe: Recipe) {
        if ids.contains(recipe.id) {
            ids.remove(recipe.id)
        } else {
            ids.insert(recipe.id)
        }
        defaults.set(Array(ids).sorted(), forKey: key)
    }
}

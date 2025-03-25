
import Foundation

protocol TrackerCategoryStoreProtocol {
    func createCategory(_ category: TrackerCategory) throws
    func fetchCategories() throws -> [TrackerCategory]
}

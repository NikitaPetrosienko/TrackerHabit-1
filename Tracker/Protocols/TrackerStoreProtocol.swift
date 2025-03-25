
import Foundation

protocol TrackerStoreProtocol {
    func createTracker(_ tracker: Tracker, category: TrackerCategory) throws
    func fetchTrackers() throws -> [Tracker]
    func deleteTracker(id: UUID) throws
    func countTrackers() -> Int
}

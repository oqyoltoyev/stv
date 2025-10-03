import Foundation

final class Debouncer {
    private let queue: DispatchQueue
    private var workItem: DispatchWorkItem?
    private let interval: TimeInterval

    init(interval: TimeInterval, queue: DispatchQueue = .main) {
        self.interval = interval
        self.queue = queue
    }

    func schedule(_ block: @escaping () -> Void) {
        workItem?.cancel()
        let item = DispatchWorkItem(block: block)
        workItem = item
        queue.asyncAfter(deadline: .now() + interval, execute: item)
    }

    func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}


import Foundation
import Combine

/// Publishes the current time every second for countdown updates.
final class CountdownTimerService: ObservableObject {
    @Published var now: Date = Date()
    private var timer: AnyCancellable?

    /// Starts the timer updates.
    func start() {
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] value in
                self?.now = value
            }
    }

    /// Stops the timer updates.
    func stop() {
        timer?.cancel()
        timer = nil
    }
}

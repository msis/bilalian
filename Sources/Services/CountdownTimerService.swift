import Foundation
import Combine

final class CountdownTimerService: ObservableObject {
    @Published var now: Date = Date()
    private var timer: AnyCancellable?

    func start() {
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] value in
                self?.now = value
            }
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }
}

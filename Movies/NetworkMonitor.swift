import Network
class NetworkMonitor{
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "InternetMonitor")
    
    var isConnected : Bool = false
    var onStatusChanged: ((Bool) -> Void)?
    private init() {
        monitor.pathUpdateHandler = {path in
            let status = (path.status == .satisfied)
            self.isConnected = status
            DispatchQueue.main.async {
                self.onStatusChanged?(status)
            }
        }
        monitor.start(queue: queue)
    }
}
    

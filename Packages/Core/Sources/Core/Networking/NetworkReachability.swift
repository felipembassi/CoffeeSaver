import Foundation
import Network

/// Protocol for network reachability monitoring.
///
/// Use this protocol to abstract network connectivity checks,
/// enabling easy testing with mock implementations.
public protocol NetworkReachabilityProtocol: Sendable {
    /// Whether the device currently has network connectivity.
    var isConnected: Bool { get async }

    /// An async stream that emits connectivity changes.
    var connectivityStream: AsyncStream<Bool> { get }
}

/// A service that monitors network connectivity status using modern Swift concurrency.
///
/// `NetworkReachability` uses `NWPathMonitor` to track network availability
/// and provides an `AsyncStream` for observing connectivity changes.
///
/// Example:
/// ```swift
/// let reachability = NetworkReachability()
///
/// // Check current status
/// if await reachability.isConnected {
///     // Proceed with network request
/// }
///
/// // Observe changes
/// for await isConnected in reachability.connectivityStream {
///     print("Network connected: \(isConnected)")
/// }
/// ```
public actor NetworkReachability: NetworkReachabilityProtocol {
    private let monitor: NWPathMonitor
    private var currentPath: NWPath?
    private var continuation: AsyncStream<Bool>.Continuation?

    /// Whether the device currently has network connectivity.
    public var isConnected: Bool {
        currentPath?.status == .satisfied
    }

    /// An async stream that emits connectivity changes.
    public nonisolated var connectivityStream: AsyncStream<Bool> {
        AsyncStream { continuation in
            Task {
                await self.setContinuation(continuation)
                // Emit current state immediately
                let connected = await self.isConnected
                continuation.yield(connected)
            }
        }
    }

    public init() {
        self.monitor = NWPathMonitor()
    }

    /// Starts monitoring network connectivity.
    ///
    /// Call this method to begin receiving connectivity updates.
    /// The monitor runs on a dedicated dispatch queue.
    public func startMonitoring() {
        let queue = DispatchQueue(label: "com.coffeesaver.networkreachability")

        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            Task {
                await self.handlePathUpdate(path)
            }
        }

        monitor.start(queue: queue)
    }

    /// Stops monitoring network connectivity.
    public func stopMonitoring() {
        monitor.cancel()
        continuation?.finish()
        continuation = nil
    }

    // MARK: - Private

    private func setContinuation(_ continuation: AsyncStream<Bool>.Continuation) {
        self.continuation = continuation
    }

    private func handlePathUpdate(_ path: NWPath) {
        let wasConnected = currentPath?.status == .satisfied
        let isNowConnected = path.status == .satisfied

        currentPath = path

        // Only emit if connectivity status changed
        if wasConnected != isNowConnected || currentPath == nil {
            continuation?.yield(isNowConnected)
        }
    }

    deinit {
        monitor.cancel()
    }
}

// MARK: - Mock Implementation

/// Mock implementation for testing.
public actor MockNetworkReachability: NetworkReachabilityProtocol {
    private var _isConnected: Bool
    private var continuation: AsyncStream<Bool>.Continuation?

    public var isConnected: Bool {
        _isConnected
    }

    public nonisolated var connectivityStream: AsyncStream<Bool> {
        AsyncStream { continuation in
            Task {
                await self.setContinuation(continuation)
                let connected = await self.isConnected
                continuation.yield(connected)
            }
        }
    }

    public init(isConnected: Bool = true) {
        self._isConnected = isConnected
    }

    /// Simulates a connectivity change for testing.
    public func setConnected(_ connected: Bool) {
        _isConnected = connected
        continuation?.yield(connected)
    }

    private func setContinuation(_ continuation: AsyncStream<Bool>.Continuation) {
        self.continuation = continuation
    }
}

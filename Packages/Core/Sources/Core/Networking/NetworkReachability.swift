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
/// This implementation supports multiple concurrent consumers. Each call to
/// `connectivityStream` returns a new stream that receives all connectivity updates.
///
/// Example:
/// ```swift
/// let reachability = NetworkReachability()
/// await reachability.startMonitoring()
///
/// // Check current status
/// if await reachability.isConnected {
///     // Proceed with network request
/// }
///
/// // Observe changes (supports multiple consumers)
/// for await isConnected in reachability.connectivityStream {
///     print("Network connected: \(isConnected)")
/// }
/// ```
public actor NetworkReachability: NetworkReachabilityProtocol {
    private let monitor: NWPathMonitor
    private var currentPath: NWPath?
    private var continuations: [UUID: AsyncStream<Bool>.Continuation] = [:]

    /// Whether the device currently has network connectivity.
    public var isConnected: Bool {
        currentPath?.status == .satisfied
    }

    /// An async stream that emits connectivity changes.
    ///
    /// Each call returns a new stream, allowing multiple consumers to observe
    /// connectivity changes independently. The stream emits the current state
    /// immediately upon subscription.
    public nonisolated var connectivityStream: AsyncStream<Bool> {
        AsyncStream { continuation in
            let id = UUID()
            Task {
                await self.addContinuation(continuation, id: id)
                // Emit current state immediately
                let connected = await self.isConnected
                continuation.yield(connected)
            }
            continuation.onTermination = { _ in
                Task {
                    await self.removeContinuation(id: id)
                }
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
            Task { [weak self] in
                await self?.handlePathUpdate(path)
            }
        }

        monitor.start(queue: queue)
    }

    /// Stops monitoring network connectivity.
    public func stopMonitoring() {
        monitor.cancel()
        for continuation in continuations.values {
            continuation.finish()
        }
        continuations.removeAll()
    }

    // MARK: - Private

    private func addContinuation(_ continuation: AsyncStream<Bool>.Continuation, id: UUID) {
        continuations[id] = continuation
    }

    private func removeContinuation(id: UUID) {
        continuations.removeValue(forKey: id)
    }

    private func handlePathUpdate(_ path: NWPath) {
        let wasConnected = currentPath?.status == .satisfied
        let isNowConnected = path.status == .satisfied

        currentPath = path

        // Only emit if connectivity status changed
        if wasConnected != isNowConnected || currentPath == nil {
            for continuation in continuations.values {
                continuation.yield(isNowConnected)
            }
        }
    }

    deinit {
        // Cancel the monitor to stop receiving updates.
        // Continuations are cleaned up via their onTermination handlers
        // when consumers stop iterating the AsyncStream.
        monitor.cancel()
    }
}

// MARK: - Mock Implementation

/// Mock implementation for testing.
///
/// Supports multiple concurrent consumers, matching the behavior of the real implementation.
public actor MockNetworkReachability: NetworkReachabilityProtocol {
    private var _isConnected: Bool
    private var continuations: [UUID: AsyncStream<Bool>.Continuation] = [:]

    public var isConnected: Bool {
        _isConnected
    }

    public nonisolated var connectivityStream: AsyncStream<Bool> {
        AsyncStream { continuation in
            let id = UUID()
            Task {
                await self.addContinuation(continuation, id: id)
                let connected = await self.isConnected
                continuation.yield(connected)
            }
            continuation.onTermination = { _ in
                Task {
                    await self.removeContinuation(id: id)
                }
            }
        }
    }

    public init(isConnected: Bool = true) {
        self._isConnected = isConnected
    }

    /// Simulates a connectivity change for testing.
    public func setConnected(_ connected: Bool) {
        _isConnected = connected
        for continuation in continuations.values {
            continuation.yield(connected)
        }
    }

    private func addContinuation(_ continuation: AsyncStream<Bool>.Continuation, id: UUID) {
        continuations[id] = continuation
    }

    private func removeContinuation(id: UUID) {
        continuations.removeValue(forKey: id)
    }
}

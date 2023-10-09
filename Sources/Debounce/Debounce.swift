// The Swift Programming Language
// https://docs.swift.org/swift-book

import DebounceMacros
import os

/// Debounce within a given interval
@freestanding(declaration)
public macro debounce(
    _ interval: ContinuousClock.Instant.Duration,
    _ expr: DebouncedStrategy? = nil
) = #externalMacro(module: "DebounceMacros", type: "DebounceMacro")

/// Turn on/off debounce debugging
@freestanding(declaration)
public macro debounce(
    debug: Bool
) = #externalMacro(module: "DebounceMacros", type: "DebounceMacro")

public enum DebouncedStrategy {
    case `throw`(Error)
    case `return`(Any)
}

fileprivate var bounces = OSAllocatedUnfairLock(initialState: Set<String>())

struct Bounced: Error {
    let file: StaticString
    let line: UInt
}

let logger = Logger(subsystem: "DebounceMacro", category: "Debounce")

@discardableResult
public func debounce(interval: ContinuousClock.Instant.Duration, debug debugEnabled: Bool, fileID: StaticString = #fileID, line: UInt = #line) async -> Result<Void, Error> {
    let id = "\(fileID):\(line)"
    let inserted = bounces.withLock { bounces in
        bounces.insert(id).inserted
    }
    guard inserted else {
        if debugEnabled {
            logger.debug("debounce bounced at \(id, privacy: .public)")
        }
        return .failure(Bounced(file: fileID, line: line))
    }
    defer {
        _ = bounces.withLock { bounces in
            bounces.remove(id)
        }
    }
    try? await Task.sleep(for: interval)
    return .success(())
}

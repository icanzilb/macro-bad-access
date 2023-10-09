import Foundation
import Debounce

// MARK: -
// MARK: Debounce + return
print("MARK: Debounce + return")

//https://mastodon.social/@NeoNacho/111144952094263165

func printer(_ text: String) async throws {
    // return when debouncing
    #debounce(.milliseconds(100))
    print(text)
}

func demo1() async throws {
    print("---- Drop second value out of three:")
    Task(priority: .high) {
        try await printer("1")
    }
    try await Task.sleep(for: .milliseconds(10))
    Task(priority: .low) {
        try await printer("2")
    }
    try await Task.sleep(for: .milliseconds(400))
    try await printer("3")
}

func demo2() async throws {
    print("---- Drop random value out of two:")
    Task {
        try await printer("1")
    }
    Task {
        try await printer("2")
    }
    try await Task.sleep(for: .milliseconds(400))
}

func demo3() async throws {
    print("---- Drop none out of three:")
    Task {
        try await printer("1")
    }
    Task {
        try await Task.sleep(for: .milliseconds(300))
        try await printer("2")
    }
    Task {
        try await Task.sleep(for: .milliseconds(600))
        try await printer("3")
    }
    try await Task.sleep(for: .milliseconds(900))
}

try await demo1()
try await demo2()
try await demo3()

// MARK: -
// MARK: Debounce + return value
print()
print("MARK: Debounce + return value (debug enabled)")

func calculate(_ value: Int) async throws -> Int {
    // return value when debouncing
    #debounce(debug: true)
    #debounce(.milliseconds(200), .return(0))
    #debounce(debug: false)
    return value * value
}

func demo4() async throws {
    print("---- Drop second call out of three:")
    Task(priority: .high) {
        print(try await calculate(3))
    }
    try await Task.sleep(for: .milliseconds(10))
    Task(priority: .low) {
        print(try await calculate(4))
    }
    try await Task.sleep(for: .milliseconds(400))
    print(try await calculate(5))
    print("---- Done")
}

try await demo4()

// MARK: -
// MARK: Debounce + throw error
print()
print("MARK: Debounce + throw error")

struct MyError: Error { }

func calculateAndThrow(_ value: Int) async throws -> Int {
    // return value when debouncing
    #debounce(debug: true)
    #debounce(.milliseconds(200), .throw(MyError()))
    #debounce(debug: false)
    return value * value
}

func demo5() async throws {
    print("---- Throw on second call out of three:")
    Task(priority: .high) {
        print(try await calculate(3))
    }
    try await Task.sleep(for: .milliseconds(10))
    Task(priority: .low) {
        print(try await calculate(4))
    }
    try await Task.sleep(for: .milliseconds(400))
    print(try await calculate(5))
    print("---- Done")
}

try await demo5()

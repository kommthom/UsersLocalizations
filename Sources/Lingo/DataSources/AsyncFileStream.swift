//
//  AsyncFileStream.swift
//  common-localizations
//
//  Created by Andy Finnell
//  Updated by Thomas Benninghaus on 30.08.24.
//
// 	Usage:
// 	let data = try await  Data(asyncContentsOf: fileURL)
//	try await data.asyncWrite(to: fileURL)

import Foundation
//import Combine

/// A phantom type used by AsyncFileStream to restrict methods to read mode
public enum ReadMode {}
/// A phantom type used by AsyncFileStream to restrict methods to write mode
public enum WriteMode {}
///
public enum AsyncFileStreamError: Error {
	case notFileURL
	case openError(_ errno: Int32)
	case readError(_ error: Int32)
	case writeError(_ error: Int32)
}

final actor AsyncError {
	private(set) var error: AsyncFileStreamError?

	func setError(_ error: AsyncFileStreamError) {
		self.error = error
	}
}

public struct AsyncFileStream<Mode>: ~Copyable {
	/// The queue to run the operations on
	private let queue: DispatchQueue
	/// The unix file descriptor for the open file
	private let fileDescriptor: Int32
	/// The DispatchIO instance used to issue operations
	private let io: DispatchIO
	/// If the file is open or not; used to prevent double closes()
	private var isClosed = false
	
	fileprivate init(url: URL, mode: Int32) throws {
		guard url.isFileURL else {
			throw AsyncFileStreamError.notFileURL
		}
		// Since we're reading/writing as a stream, keep it a serial queue
		let queue = DispatchQueue(label: "AsyncFileStream")
		let fileDescriptor = open(url.absoluteURL.path, mode, 0o666)
		// Once we start setting properties, we can't throw. So check to see if
		//  we need to throw now, then set properties
		if fileDescriptor == -1 {
			throw AsyncFileStreamError.openError(errno)
		}
		self.queue = queue
		self.fileDescriptor = fileDescriptor
		io = DispatchIO(
			type: .stream,
			fileDescriptor: fileDescriptor,
			queue: queue,
			cleanupHandler: { [fileDescriptor] error in
				// Unfortunately, we can't seem to do anything with `error`.
				// There are no guarantees when this closure is invoked, so
				//  the safe thing would be to save the error in an actor
				//  that the AsyncFileStream holds. That would allow the caller
				//  to check for it, or the read()/write() methods to check
				//  for it as well. Howevever, having an actor as a property
				//  on a non-copyable type appears to uncover a compiler bug.

				// Since we opened the file, we need to close it
				Darwin.close(fileDescriptor)
			}
		)
	}
	
	/// Close the file. Consuming method
	public consuming func close() {
		isClosed = true
		io.close()
	}
	
	deinit {
		// Ensure we've closed the file if we're going out of scope
		if !isClosed {
			io.close()
		}
	}
}

extension DispatchData: @retroactive @unchecked Sendable {}

public extension AsyncFileStream where Mode == ReadMode {
	/// Read the entire contents of the file in one go
	func readToEnd() async throws -> DispatchData {
		try await read(upToCount: .max)
	}

	/// Read the next `length` bytes.
	func read(upToCount length: Int) async throws -> DispatchData {
		try await withCheckedThrowingContinuation { continuation in
			var readData = DispatchData.empty
			io.read(offset: 0, length: length, queue: queue) { done, data, error in
				if let data { readData.append(data) }
				guard done else { return } // not done yet
				if error != 0 {
					continuation.resume(throwing: AsyncFileStreamError.readError(error))
				} else {
					continuation.resume(returning: readData)
				}
			}
		}
	}
}

public extension AsyncFileStream where Mode == WriteMode {
	/// Write the data out to file async
	func write(_ data: DispatchData) async throws {
		try await withCheckedThrowingContinuation { continuation in
			io.write(
				offset: 0,
				data: data,
				queue: queue
			) { done, _, error in
				guard done else {
					return // not done yet
				}
				if error != 0 {
					continuation.resume(throwing: AsyncFileStreamError.writeError(error))
				} else {
					continuation.resume(returning: ())
				}
			}
		} as Void
	}
}

public extension URL {
	/// Create an instance from the URL for reading only
	func openForReading() throws -> AsyncFileStream<ReadMode> {
		try AsyncFileStream<ReadMode>(url: self, mode: O_RDONLY)
	}

	/// Create an instance from the URL for writing. It will overwrite if the file
	/// already exists or create it if it does not exist.
	func openForWriting() throws -> AsyncFileStream<WriteMode> {
		try AsyncFileStream<WriteMode>(url: self, mode: O_WRONLY | O_TRUNC | O_CREAT)
	}
	
	func exists() async -> (exists: Bool, isDirectory: Bool) {
		let queue = DispatchQueue(label: "AsyncFileStream")
		return await withCheckedContinuation { continuation in
			queue.async {
				var isDirectory: ObjCBool = false
				let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
				continuation.resume(returning: (exists: exists, isDirectory: isDirectory.boolValue))
			}
		}
	}
}

public extension Data {
	/// Asynchronously read from the contents of the fileURL. This method
	/// will throw an error if it's not a file URL.
	init(asyncContentsOf url: URL) async throws {
		let stream = try url.openForReading()
		self = try await Data(stream.readToEnd())
	}

	/// Asynchronously write the contents of self into the fileURL.
	func asyncWrite(to url: URL) async throws {
		// This line makes me sad because we're copying the data. I'm not
		//  currently aware of a way to not copy these bytes.
		let dispatchData = withUnsafeBytes { DispatchData(bytes: $0) }
		let stream = try url.openForWriting()
		try await stream.write(dispatchData)
	}
}

/// Recursive iteration over directory
/// Usage:
/// let swiftFiles = walkDirectory(at: path!, options: options).filter {
/// 	$0.pathExtension == "swift"
/// }
/// for await item in swiftFiles {
///		print(item.lastPathComponent)
/// }

public func walkDirectory(at url: URL, options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants]) -> AsyncStream<URL> {
	AsyncStream { continuation in
		Task {
			let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options: options)
			while let fileURL = enumerator?.nextObject() as? URL {
				if fileURL.hasDirectoryPath {
					for await item in walkDirectory(at: fileURL, options: options) {
						continuation.yield(item)
					}
				} else {
					continuation.yield( fileURL )
				}
			}
			continuation.finish()
		}
	}
}

/*
 Copyright (c) 2026, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import XCTest

final class ORKTaskViewControllerOutputDirectoryTests: XCTestCase {
    
    private func createTask() -> ORKOrderedTask {
        let step = ORKInstructionStep(identifier: "step")
        let task = ORKOrderedTask(identifier: "task", steps: [step])
        return task
    }
    
    private func folders(at url: URL) throws -> [URL] {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: .skipsHiddenFiles
        )
        
        return contents
    }
    
    func testOutputDirectoryDeletedOnDeallocWhenEmpty() {
        let fileManager = FileManager.default
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        
        var taskVC: ORKTaskViewController? = ORKTaskViewController(task: createTask(), taskRun: UUID())
        taskVC?.outputDirectory = tempURL
        
        XCTAssertTrue(fileManager.fileExists(atPath: tempURL.path))
        
        taskVC = nil
        
        XCTAssertFalse(
            fileManager.fileExists(atPath: tempURL.path),
            "Empty outputDirectory should be deleted on dealloc"
        )
    }
    
    func testOutputDirectoryDeletedOnDeallocWhenContainsOnlySubdirectories() {
        let fileManager = FileManager.default
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        
        var taskVC: ORKTaskViewController? = ORKTaskViewController(task: createTask(), taskRun: UUID())
        taskVC?.outputDirectory = tempURL
        
        XCTAssertTrue(fileManager.fileExists(atPath: tempURL.path))
        
        // create a sub directory inside of the output directory
        let subDirURL = tempURL.appendingPathComponent("subdir", isDirectory: true)
        try! fileManager.createDirectory(at: subDirURL, withIntermediateDirectories: true)
        
        taskVC = nil
        
        XCTAssertFalse(
            fileManager.fileExists(atPath: tempURL.path),
            "outputDirectory containing only empty subdirectories should be deleted on dealloc"
        )
    }
    
    func testOutputDirectoryDeletesAllEmptySubdirectoriesOnDealloc() throws {
        let fileManager = FileManager.default
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        
        addTeardownBlock {
            try? fileManager.removeItem(at: tempURL)
        }
        
        var taskVC: ORKTaskViewController? = ORKTaskViewController(task: createTask(), taskRun: UUID())
        taskVC?.outputDirectory = tempURL
        
        XCTAssertTrue(fileManager.fileExists(atPath: tempURL.path))
        
        // create a empty sub directory inside of the output directory
        let emptySubDirURL = tempURL.appendingPathComponent("emptySubDir", isDirectory: true)
        try! fileManager.createDirectory(at: emptySubDirURL, withIntermediateDirectories: true)
        
        // create a sub directory inside of the output directory
        let subDirURL = tempURL.appendingPathComponent("subdir", isDirectory: true)
        try! fileManager.createDirectory(at: subDirURL, withIntermediateDirectories: true)
        
        // create a file inside of the sub directory
        let fileURL = subDirURL.appendingPathComponent("result.json")
        try! Data("{}".utf8).write(to: fileURL)
        
        let contentsBeforeDealloc = try folders(at: tempURL)
        XCTAssertEqual(contentsBeforeDealloc.count, 2, "Expected 2 subdirectories before dealloc")
        
        taskVC = nil
        
        let contentsAfterDealloc = try folders(at: tempURL)
        XCTAssertEqual(contentsAfterDealloc.count, 1, "Expected only the non-empty subdirectory to remain after dealloc")
    }
    
    func testOutputDirectoryNotDeletedOnDeallocWhenContainsFile() {
        let fileManager = FileManager.default
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        
        addTeardownBlock {
            try? fileManager.removeItem(at: tempURL)
        }
        
        var taskVC: ORKTaskViewController? = ORKTaskViewController(task: createTask(), taskRun: UUID())
        taskVC?.outputDirectory = tempURL
        
        XCTAssertTrue(fileManager.fileExists(atPath: tempURL.path))
        
        // create a file inside of the output directory
        let fileURL = tempURL.appendingPathComponent("result.json")
        try! Data("{}".utf8).write(to: fileURL)
        
        taskVC = nil
        
        XCTAssertTrue(
            fileManager.fileExists(atPath: tempURL.path),
            "outputDirectory with files should not be deleted on dealloc"
        )
    }
    
    func testOutputDirectoryNotDeletedOnDeallocWhenContainsFileInSubdirectory() {
        let fileManager = FileManager.default
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        
        addTeardownBlock {
            try? fileManager.removeItem(at: tempURL)
        }
        
        var taskVC: ORKTaskViewController? = ORKTaskViewController(task: createTask(), taskRun: UUID())
        taskVC?.outputDirectory = tempURL
        
        XCTAssertTrue(fileManager.fileExists(atPath: tempURL.path))
        
        // create a sub directory inside of the output directory
        let subDirURL = tempURL.appendingPathComponent("subdir", isDirectory: true)
        try! fileManager.createDirectory(at: subDirURL, withIntermediateDirectories: true)
        
        // create a file inside of the sub directory
        let fileURL = subDirURL.appendingPathComponent("result.json")
        try! Data("{}".utf8).write(to: fileURL)
        
        taskVC = nil
        
        XCTAssertTrue(
            fileManager.fileExists(atPath: tempURL.path),
            "outputDirectory with files in subdirectories should not be deleted on dealloc"
        )
    }
    
    func testOutputDirectoryDeletedOnFinishWhenEmpty() {
        let fileManager = FileManager.default
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        
        let taskVC: ORKTaskViewController = ORKTaskViewController(task: createTask(), taskRun: UUID())
        taskVC.outputDirectory = tempURL
        
        XCTAssertTrue(fileManager.fileExists(atPath: tempURL.path))
        
        taskVC.finish(with: .completed, error: nil)
        
        XCTAssertFalse(
            fileManager.fileExists(atPath: tempURL.path),
            "Empty outputDirectory should be deleted on dealloc"
        )
    }
    
    func testOutputDirectoryDeletedOnFinishWhenContainsOnlySubdirectories() {
        let fileManager = FileManager.default
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        
        let taskVC: ORKTaskViewController = ORKTaskViewController(task: createTask(), taskRun: UUID())
        taskVC.outputDirectory = tempURL
        
        XCTAssertTrue(fileManager.fileExists(atPath: tempURL.path))
        
        // create a sub directory inside of the output directory
        let subDirURL = tempURL.appendingPathComponent("subdir", isDirectory: true)
        try! fileManager.createDirectory(at: subDirURL, withIntermediateDirectories: true)
        
        taskVC.finish(with: .completed, error: nil)
        
        XCTAssertFalse(
            fileManager.fileExists(atPath: tempURL.path),
            "outputDirectory containing only empty subdirectories should be deleted on dealloc"
        )
    }
    
    func testOutputDirectoryDeletesAllEmptySubdirectoriesOnFinish() throws {
        let fileManager = FileManager.default
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        
        addTeardownBlock {
            try? fileManager.removeItem(at: tempURL)
        }
        
        let taskVC: ORKTaskViewController = ORKTaskViewController(task: createTask(), taskRun: UUID())
        taskVC.outputDirectory = tempURL
        
        XCTAssertTrue(fileManager.fileExists(atPath: tempURL.path))
        
        // create a empty sub directory inside of the output directory
        let emptySubDirURL = tempURL.appendingPathComponent("emptySubDir", isDirectory: true)
        try! fileManager.createDirectory(at: emptySubDirURL, withIntermediateDirectories: true)
        
        // create a sub directory inside of the output directory
        let subDirURL = tempURL.appendingPathComponent("subdir", isDirectory: true)
        try! fileManager.createDirectory(at: subDirURL, withIntermediateDirectories: true)
        
        // create a file inside of the sub directory
        let fileURL = subDirURL.appendingPathComponent("result.json")
        try! Data("{}".utf8).write(to: fileURL)
        
        let contentsBeforeDealloc = try folders(at: tempURL)
        XCTAssertEqual(contentsBeforeDealloc.count, 2, "Expected 2 subdirectories before dealloc")
        
        taskVC.finish(with: .completed, error: nil)
        
        let contentsAfterDealloc = try folders(at: tempURL)
        XCTAssertEqual(contentsAfterDealloc.count, 1, "Expected only the non-empty subdirectory to remain after dealloc")
    }
    
    func testOutputDirectoryNotDeletedOnFinishWhenContainsFile() {
        let fileManager = FileManager.default
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        
        addTeardownBlock {
            try? fileManager.removeItem(at: tempURL)
        }
        
        let taskVC: ORKTaskViewController = ORKTaskViewController(task: createTask(), taskRun: UUID())
        taskVC.outputDirectory = tempURL
        
        XCTAssertTrue(fileManager.fileExists(atPath: tempURL.path))
        
        // create a file inside of the output directory
        let fileURL = tempURL.appendingPathComponent("result.json")
        try! Data("{}".utf8).write(to: fileURL)
        
        taskVC.finish(with: .completed, error: nil)
        
        XCTAssertTrue(
            fileManager.fileExists(atPath: tempURL.path),
            "outputDirectory with files should not be deleted on dealloc"
        )
    }
    
    func testOutputDirectoryNotDeletedOnFinishWhenContainsFileInSubdirectory() {
        let fileManager = FileManager.default
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        
        addTeardownBlock {
            try? fileManager.removeItem(at: tempURL)
        }
        
        let taskVC: ORKTaskViewController = ORKTaskViewController(task: createTask(), taskRun: UUID())
        taskVC.outputDirectory = tempURL
        
        XCTAssertTrue(fileManager.fileExists(atPath: tempURL.path))
        
        // create a sub directory inside of the output directory
        let subDirURL = tempURL.appendingPathComponent("subdir", isDirectory: true)
        try! fileManager.createDirectory(at: subDirURL, withIntermediateDirectories: true)
        
        // create a file inside of the sub directory
        let fileURL = subDirURL.appendingPathComponent("result.json")
        try! Data("{}".utf8).write(to: fileURL)
        
        taskVC.finish(with: .completed, error: nil)
        
        XCTAssertTrue(
            fileManager.fileExists(atPath: tempURL.path),
            "outputDirectory with files in subdirectories should not be deleted on dealloc"
        )
    }
    
    func testNilOutputDirectoryDoesNotCrashOnDealloc() {
        let taskRunUUID = UUID()
        var taskVC: ORKTaskViewController? = ORKTaskViewController(task: createTask(), taskRun: taskRunUUID)
        taskVC?.taskRunUUID = taskRunUUID // silences the "never read" warning
        taskVC = nil
    }
}

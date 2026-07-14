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

import SwiftUI
import ResearchKit
import ResearchKitActiveTask

/// Observable view model that serializes an `ORKResult` into a tree of `JSONNode`s.
@MainActor
final class ResultViewModel: ObservableObject {
    @Published var nodes: [JSONNode] = []
    @Published var errorMessage: String?
    private(set) var jsonString: String?

    func update(with result: ORKResult?) {
        guard let result else {
            nodes = []
            jsonString = nil
            errorMessage = nil
            return
        }

        let serializer = ORKESerializer(entryProviders: [
            ORKCoreSerializationEntryProvider(),
            ORKActiveTaskSerializationEntryProvider()
        ])

        do {
            let jsonDict = try serializer.jsonObject(for: result)
            nodes = jsonDict.compactMap { key, value -> JSONNode? in
                guard let key = key as? String else { return nil }
                return JSONNode(key: key, value: .from(value))
            }.sorted { $0.key < $1.key }
            let data = try serializer.jsonData(for: jsonDict, options: [.prettyPrinted, .sortedKeys])
            jsonString = String(data: data, encoding: .utf8)
            errorMessage = nil
        } catch {
            nodes = []
            jsonString = nil
            errorMessage = error.localizedDescription
        }
    }
}

/// A SwiftUI view that displays a serialized `ORKResult` as an expandable JSON tree.
struct ResultView: View {
    @ObservedObject var viewModel: ResultViewModel

    var body: some View {
        if let error = viewModel.errorMessage {
            VStack {
                Spacer()
                Label(error, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.secondary)
                    .padding()
                Spacer()
            }
        } else if viewModel.nodes.isEmpty {
            VStack {
                Spacer()
                Text("No result set yet.")
                    .foregroundStyle(.secondary)
                Spacer()
            }
        } else {
            List {
                ForEach(viewModel.nodes) { node in
                    JSONNodeView(node: node)
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

private struct JSONNodeView: View {
    let node: JSONNode

    var body: some View {
        switch node.value {
        case .string(let s):
            if let url = getStandardFile(from: s) {
                ShareLink(item: url) {
                    LabeledContent(node.key, value: url.lastPathComponent)
                }
            } else if let url = getRecorderFile(from: s) {
                ShareLink(item: url) {
                    LabeledContent(node.key, value: url.lastPathComponent)
                }
            } else {
                LabeledContent(node.key, value: s)
            }
        case .number(let n):
            LabeledContent(node.key, value: formatted(n))
        case .bool(let b):
            LabeledContent(node.key, value: b ? "true" : "false")
        case .null:
            LabeledContent(node.key, value: "null")
                .foregroundStyle(.secondary)
        case .object(let children):
            DisclosureGroup(node.key) {
                ForEach(children) { child in
                    JSONNodeView(node: child)
                }
            }
        case .array(let items):
            DisclosureGroup("\(node.key) (\(items.count))") {
                ForEach(items) { item in
                    JSONNodeView(node: item)
                }
            }
        }
    }
    
    private func getStandardFile(from nodeValue: String) -> URL? {
        let url = ORKTaskViewController.orkDefaultTemporaryOutputDirectory().appendingPathComponent(nodeValue)
        if url.scheme == "file", FileManager.default.fileExists(atPath: url.path) {
            return url
        }
        
        return nil
    }
    
    private func getRecorderFile(from nodeValue: String) -> URL? {
        if node.key == "fileName" && nodeValue.contains("_"), let fileID = extractFileID(from: nodeValue) {
            let fileFolder = "recorder-\(fileID)"
            let url = ORKTaskViewController.orkDefaultTemporaryOutputDirectory().appendingPathComponent(fileFolder).appendingPathComponent(nodeValue)
            
            if url.scheme == "file" && FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }
        
        return nil
    }
    
    private func extractFileID(from fileName: String) -> String? {
        let result = fileName
              .components(separatedBy: "_").last?
              .components(separatedBy: ".").first
        
        return result
    }

    private func formatted(_ n: Double) -> String {
        n.truncatingRemainder(dividingBy: 1) == 0 && n.isFinite ? String(Int(n)) : String(n)
    }
}

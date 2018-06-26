//
//  Censor.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 6/21/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

protocol CensorProtocol {
    func process(_ string: String, type: Censor.Rule.RuleType) -> String
}

extension CensorProtocol {
    func process(_ string: String) -> String {
        return process(string, type: .message)
    }
}

class Censor {
    struct Rule: Decodable {
        enum RuleType: Int, Decodable {
            case message = 2
            case fragment = 3
        }
        
        struct Search: Decodable {
            enum SearchType: String, Decodable {
                case regex
                case recursive
            }
            
            let type: SearchType
            let value: [NSRegularExpression]
            
            enum CodingKeys: String, CodingKey {
                case type = "Type"
                case value = "Value"
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                type = try container.decode(SearchType.self, forKey: .type)
                switch type {
                case .regex:
                    value = [try container.decode(String.self, forKey: .value)].map { Censor.createRegex(from: $0) }.compactMap { $0 }
                case .recursive:
                    value = try container.decode([Search].self, forKey: .value).map { $0.value }.flatMap { $0 }
                }
            }
            
            init(regexes: [String]) {
                type = regexes.count > 1 ? .recursive : .regex
                value = regexes.map { Censor.createRegex(from: $0) }.compactMap { $0 }
            }
        }
        
        struct Replacement: Decodable {
            let search: NSRegularExpression
            let replace: String
            
            enum CodingKeys: String, CodingKey {
                case search = "Search"
                case replace = "Replace"
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                guard let regex = Censor.createRegex(from: try container.decode(String.self, forKey: .search)) else {
                    throw DecodingError.dataCorruptedError(forKey: .search, in: container, debugDescription: "Could not create regex from string.")
                }
                search = regex
                replace = try container.decode(String.self, forKey: .replace)
            }
            
            init(search: String, replace: String) {
                self.search = Censor.createRegex(from: search)!
                self.replace = replace
            }
        }
        
        let type: RuleType?
        let category: String
        let search: Search
        let replacements: [Replacement]
        
        enum CodingKeys: String, CodingKey {
            case type = "Type"
            case category = "Category"
            case search = "Search"
            case replacements = "Replacements"
        }
    }
    
    var rules: [Rule] = []
    
    private static func createRegex(from string: String) -> NSRegularExpression? {
        var string = string
        if string.hasPrefix("/") {
            string = String(string[string.index(after: string.startIndex)..<string.endIndex])
        }
        if string.hasSuffix("/") {
            string = String(string[string.startIndex..<string.index(before: string.endIndex)])
        }
        return try? NSRegularExpression(pattern: string, options: [.caseInsensitive])
    }
}

extension Censor: CensorProtocol {
    private func replace(_ regex: NSRegularExpression, in string: String, with replacement: String) -> String? {
        return regex.stringByReplacingMatches(in: string, options: [], range: NSRange(location: 0, length: string.count), withTemplate: replacement)
    }
    
    private func getUntaggedRanges(of string: String) -> [Range<String.Index>] {
        guard let regex = try? NSRegularExpression(pattern: "\\{[0-9a-z]+:[^}]+\\}", options: [.caseInsensitive]) else {
            return []
        }
        
        let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        let taggedRanges = matches.map { Range($0.range, in: string) }.compactMap { $0 }
        
        var untaggedRanges: [Range<String.Index>] = [
            string.startIndex ..< (taggedRanges.isEmpty ? string.endIndex : taggedRanges[0].lowerBound)
        ]
        
        for (i, taggedRange) in taggedRanges.enumerated() {
            let isLast = (i == taggedRanges.count - 1)
            let start = taggedRange.upperBound
            let end = isLast ? string.endIndex : taggedRanges[i + 1].lowerBound
            untaggedRanges.append(start ..< end)
        }
        
        return untaggedRanges
    }
    
    private func getReplacement(for range: Range<String.Index>, in string: String, following rule: Rule) -> String {
        var output = string
        
        for replacement in rule.replacements {
            let substring = String(output[range])
            guard
                let modified = replace(replacement.search, in: substring, with: replacement.replace),
                substring != modified
            else {
                continue
            }
            
            output.replaceSubrange(range, with: modified)
        }
        
        return output == string ? String(output[range]) : "{\(rule.category):\(output[range])}"
    }
    
    private func replaceRanges(_ ranges: [Range<String.Index>], in string: String, following rule: Rule) -> String {
        var output = string
        var replacements: [String] = []
        
        for range in ranges {
            replacements.append(getReplacement(for: range, in: string, following: rule))
        }
        
        for (range, replacement) in zip(ranges, replacements).reversed() {
            output.replaceSubrange(range, with: replacement)
        }
        
        return output
    }
    
    private func chainedSearch(string: String, ranges: [Range<String.Index>], regexes: [NSRegularExpression]) -> [Range<String.Index>] {
        if ranges.isEmpty {
            return []
        }
        
        var regexes = regexes
        guard let regex = regexes.popLast() else {
            return ranges
        }
        
        var allResults: [NSTextCheckingResult] = []
        for range in ranges {
            let results = regex.matches(in: string, options: [], range: NSRange(range, in: string))
            allResults.append(contentsOf: results)
        }
        
        let newRanges = allResults.map { Range($0.range, in: string) }.compactMap { $0 }
        return chainedSearch(string: string, ranges: newRanges, regexes: regexes)
    }
    
    func process(_ string: String, type: Censor.Rule.RuleType = .message) -> String {
        guard !string.isEmpty else {
            return string
        }
        
        var string = string
        
        let filteredRules = rules.filter {
            type == .fragment ? true : (($0.type ?? .message) == type)
        }
        
        for rule in filteredRules {
            let untaggedRanges = getUntaggedRanges(of: string)
            let matchedRanges = chainedSearch(string: string, ranges: untaggedRanges, regexes: rule.search.value.reversed())
            string = replaceRanges(matchedRanges, in: string, following: rule)
        }
        
        return string
    }
}

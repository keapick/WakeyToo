//
//  StringPhoneticAlgorithms.swift
//  WakeyLib
//
//  Created by Cho, Ernest on 10/8/25.
//

import Foundation

// Phonetic algorithms to assist mapping Siri inputs to expected inputs
extension String {
    
    // Phonetic distance estimation. Only looks at early syllables.
    // Encodes strings based on pronunciation with soundex, then does a Levenshtein distance calculation.
    // Returns the first best candidate string or nil
    public func bestPhoneticMatch(in candidates: [String], maxDistance: Int = 5) -> String? {
        var best: String? = nil
        var bestScore: Int = 0
        
        let phonemes = candidates.map { $0.soundex() }
        
        for (index, phoneme) in phonemes.enumerated() {
            let distance = self.soundex().levenshteinDistance(otherString: phoneme)
            
            if best == nil || (distance < bestScore && distance < maxDistance) {
                best = candidates[index]
                bestScore = distance
                print("\(candidates[index]) is closer to \(self) with distance: \(distance)")
            } else {
                print("\(candidates[index]) is not closer to \(self) with distance: \(distance)")
            }
        }
        
        return best
    }
    
    // Soundex algorithm
    // This is the textbook implementation, not the common database alternative.
    // https://en.wikipedia.org/wiki/Soundex
    func soundex() -> String {
        guard !self.isEmpty else { return "0000" }

        // mapping of consonants to digits
        let soundexMap: [Character: Character] = [
            "B": "1", "F": "1", "P": "1", "V": "1",
            "C": "2", "G": "2", "J": "2", "K": "2", "Q": "2", "S": "2", "X": "2", "Z": "2",
            "D": "3", "T": "3",
            "L": "4",
            "M": "5", "N": "5",
            "R": "6"
        ]
        
        // consonants separated by vowels are counted twice
        let vowels: [Character] = [
            "A", "E", "I", "O", "U"
        ]
        
        // Y and H, W are ignored

        var soundexCode = ""
        let originalString = self.uppercased()
        var charArray = Array(originalString)
        
        // retain the first letter
        let firstLetter = charArray.removeFirst()
        soundexCode.append(firstLetter)
        var lastDigit: Character? = soundexMap[firstLetter]

        for char in charArray {
            if let digit = soundexMap[char] {
                // ignore consecutive identical digits unless separated by a vowel
                if digit != lastDigit {
                    soundexCode.append(digit)
                    lastDigit = digit
                }
            } else if vowels.contains(char) {
                // consecutive identical digits separated by a vowel are counted twice, so clear lastDigit.
                lastDigit = nil
            }

            // truncate if the code reaches 4 characters (1 letter + 3 digits)
            if soundexCode.count == 4 {
                break
            }
        }

        // pad with zeros if the code is shorter than 4 characters
        while soundexCode.count < 4 {
            soundexCode.append("0")
        }

        return soundexCode
    }
    
    // Levenshtein distance algorithm
    // This version does NOT handle larger grapheme clusters properly, for example skin color emojis.
    // https://en.wikipedia.org/wiki/Levenshtein_distance
    func levenshteinDistance(otherString: String) -> Int {
        let a = Array(self.utf16) // Convert strings to UTF-16 arrays for character access
        let b = Array(otherString.utf16)

        if a.count == 0 { return b.count }
        if b.count == 0 { return a.count }

        // Initialize a matrix to store distances
        var dist = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)

        // Fill the first row and column representing the cost of transforming to an empty string
        for i in 0...a.count {
            dist[i][0] = i
        }
        for j in 0...b.count {
            dist[0][j] = j
        }

        // Fill the rest of the matrix using dynamic programming
        for i in 1...a.count {
            for j in 1...b.count {
                // If characters are the same, no operation is needed
                if a[i - 1] == b[j - 1] {
                    dist[i][j] = dist[i - 1][j - 1]
                } else {
                    // Calculate the cost of deletion, insertion, and substitution, Take the minimum.
                    // String has min function as well, need to explicitly call for the Swift one
                    dist[i][j] = Swift.min(
                        dist[i - 1][j] + 1,      // Deletion
                        dist[i][j - 1] + 1,      // Insertion
                        dist[i - 1][j - 1] + 1   // Substitution
                    )
                }
            }
        }

        // The final distance is in the bottom-right cell of the matrix
        return dist[a.count][b.count]
    }
    
}

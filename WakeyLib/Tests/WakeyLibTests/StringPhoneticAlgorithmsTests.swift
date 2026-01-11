import Testing
import Foundation
@testable import WakeyLib

struct SoundexTest: Codable {
    var word: String
    var soundex: String
}

struct DistanceTest: Codable {
    var s1: String
    var s2: String
    var distance: Int
    var note: String
}

struct StringPhoneticAlgorithmsTests {
    
    func urlForTests(named: String) -> URL? {
        if let url = Bundle.module.url(forResource: named, withExtension: "json") {
            return url
        }
        return nil
    }
    
    // Samples to test edge cases
    func loadSoundexTests() -> [SoundexTest] {
        guard let url = self.urlForTests(named: "soundex_tests") else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([SoundexTest].self, from: data)
        } catch {
            print("\(error)")
        }

        return []
    }
    
    // Samples that should be equivalent
    func loadSoundexEquivalenceTests() -> [[String]] {
        guard let url = self.urlForTests(named: "soundex_equivalance_tests") else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([[String]].self, from: data)
        } catch {
            print("\(error)")
        }
        
        return []
    }
    
    // Samples with expected distance
    func loadDistanceTests() -> [DistanceTest] {
        guard let url = self.urlForTests(named: "distance_tests") else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([DistanceTest].self, from: data)
        } catch {
            print("\(error)")
        }
        
        return []
    }
    
    @Test func validateSoundexJSONLoaded() async throws {
        let tests = self.loadSoundexTests()
        #expect(!tests.isEmpty)
    }
    
    @Test func validateSoundexEquivalenceJSONLoaded() async throws {
        let tests = self.loadSoundexEquivalenceTests()
        #expect(!tests.isEmpty)
    }
    
    @Test func validateDistanceTestsLoaded() async throws {
        let tests = self.loadDistanceTests()
        #expect(!tests.isEmpty)
    }
    
    @Test func testSoundex() async throws {
        let tests = self.loadSoundexTests()
        for test in tests {
            print("Testing: \(test.word) -> \(test.soundex)")
            let code = test.word.soundex()
            #expect(code == test.soundex)
        }
    }
    
    @Test func testSoundexEquivalence() async throws {
        let tests = self.loadSoundexEquivalenceTests()
        for test in tests {
            print("Testing: \(test[0]) <-> \(test[1])")
            let code1 = test[0].soundex()
            let code2 = test[1].soundex()
            #expect(code1 == code2)
        }
    }
    
    @Test func testDistance() async throws {
        let tests = self.loadDistanceTests()
        for test in tests {
            print("Testing: \(test.s1) -> \(test.s2) = \(test.distance)")
            #expect(test.distance == test.s1.levenshteinDistance(otherString: test.s2))
        }
    }
    
    @Test func testSiriMisheardDeane1() async throws {
        let input = "The Yea"
        let candidates = ["Deane", "Ernest", "Naveen Jammula", "Paulina"]
        
        let best = input.bestPhoneticMatch(in: candidates)
        #expect(best == "Deane")
    }
    
    @Test func testSiriMisheardDeane2() async throws {
        let input = "Diane"
        let candidates = ["Deane", "Ernest", "Naveen Jammula", "Paulina"]
        
        let best = input.bestPhoneticMatch(in: candidates)
        #expect(best == "Deane")
    }
    
    @Test func testSiriNaveen() async throws {
        let input = "Naveen"
        let candidates = ["Deane", "Ernest", "Naveen Jammula", "Paulina"]
        
        let best = input.bestPhoneticMatch(in: candidates)
        #expect(best == "Naveen Jammula")
    }
}

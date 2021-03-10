//
//  ParticipantsViewModel.swift
//  Jeoparty
//
//  Created by David Chen on 2/4/21.
//

import Foundation

class ParticipantsViewModel: ObservableObject {
    @Published var teams = [Team]()
    @Published var wagers = [String]()
    @Published var finalJeopardyAnswers = [String]()
    @Published var questionTicker = 0
    @Published var spokespeople = [String]()
    @Published var toSubtracts = [Bool]()
    
    func addTeam(index: Int, name: String, members: [String], score: Int, color: String) {
        self.teams.append(Team(index: index, name: name, members: members, score: score, color: color))
        self.wagers.append("")
        self.finalJeopardyAnswers.append("")
        self.spokespeople.append("")
        self.toSubtracts.append(false)
    }
    
    func editScore(index: Int, amount: Int) {
        self.teams[index].editScore(amount: amount)
    }
    
    func addMember(index: Int, name: String) {
        self.teams[index].addMember(name: name)
    }
    
    func editName(index: Int, name: String) {
        self.teams[index].editName(name: name)
    }
    
    func removeTeam(index: Int) {
        self.teams.remove(at: index)
        self.wagers.remove(at: index)
        self.finalJeopardyAnswers.remove(at: index)
        for i in 0..<self.teams.count {
            teams[i].setIndex(index: i)
        }
    }
    
    func removeMember(index: Int, name: String) {
        self.teams[index].removeMember(name: name)
    }
    
    func editColor(index: Int, color: String) {
        self.teams[index].editColor(color: color)
    }
    
    func resetSubtracts() {
        for i in 0..<toSubtracts.count {
            toSubtracts[i] = false
        }
    }
    
    func resetScores() {
        for i in 0..<teams.count {
            teams[i].editScore(amount: -teams[i].score)
            wagers[i] = ""
            finalJeopardyAnswers[i] = ""
        }
    }
    
    func getIDByName(name: String) -> Int {
        for i in 0..<self.teams.count {
            if self.teams[i].name == name {
                return i
            }
        }
        return 0
    }
    
    func getNextPlayer() {
        questionTicker += 1
        for team in self.teams {
            if team.members.count > 0 {
                self.spokespeople[team.index] = team.members[questionTicker % team.members.count]
            }
        }
    }
}

struct Team: Hashable, Identifiable {
    static func == (lhs: Team, rhs: Team) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String
    var index: Int
    var name: String
    var members: [String]
    var score: Int
    var color: String
    
    init(index: Int, name: String, members: [String], score: Int, color: String) {
        self.id = UUID().uuidString
        self.index = index
        self.name = name
        self.members = members
        self.score = score
        self.color = color
    }
    
    mutating func editName(name: String) {
        self.name = name
    }
    
    mutating func editScore(amount: Int) {
        self.score += amount
    }
    
    mutating func addMember(name: String) {
        self.members.append(name)
    }
    
    mutating func removeMember(name: String) {
        self.members = self.members.filter { $0 != name }
    }
    
    mutating func editColor(color: String) {
        self.color = color
    }
    
    mutating func getNextMember() {
        let firstMember = members.removeFirst()
        self.members.append(firstMember)
    }
    
    mutating func setIndex(index: Int) {
        self.index = index
    }
}

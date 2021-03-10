//
//  TrackerViewModel.swift
//  Jeoparty
//
//  Created by David Chen on 3/6/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class TrackerViewModel: ObservableObject {
    @Published var steps = 0
    @Published var scores: [[Int]] = []
    @Published var solved = 0
    
    var teams = [Team]()
    var teamIDs = [String]()
    var idNameMap = [String:String]()
    var idColorMap = [String:String]()
    var selectedTeam: Team? = nil
    private var db = Firestore.firestore()
    
    func addTeam(team: Team) {
        self.teams.append(team)
        self.teamIDs.append(team.id)
        var zeros = [Int]()
        for _ in 0..<self.steps {
            zeros.append(0)
        }
        self.scores.append(zeros)
        self.idNameMap.updateValue(team.name, forKey: team.id)
        self.idColorMap.updateValue(team.color, forKey: team.id)
    }
    
    func removeTeam(index: Int) {
        let teamID = self.teams[index].id
        self.idNameMap.removeValue(forKey: teamID)
        self.teams.remove(at: index)
        self.teamIDs.remove(at: index)
        self.scores.remove(at: index)
    }
    
    func progressGame() {
        for i in 0..<self.teams.count {
            self.scores[i].append(0)
        }
    }
    
    func incrementStep() {
        self.steps += 1
    }
    
    func editScore(index: Int, score: Int) {
        self.scores[index][self.steps] += score
    }
    
    func editName(id: String, name: String) {
        self.idNameMap.updateValue(name, forKey: id)
    }
    
    func editColor(id: String, color: String) {
        self.idColorMap.updateValue(color, forKey: id)
    }
    
    func addSolved() {
        self.solved += 1
    }
    
    func resetGame() {
        self.solved = 0
        self.steps = 0
        for i in 0..<scores.count {
            scores[i] = []
        }
    }
    
    func writeToFirestore(showNo: String) {
        let gameRef = db.collection("users").document(Auth.auth().currentUser?.uid ?? "no_id").collection("games").document()
        gameRef.setData([
            "date" : Date(),
            "episode_played" : showNo,
            "steps" : self.steps,
            "team_ids" : self.teamIDs,
            "name_id_map" : self.idNameMap,
            "color_id_map" : self.idColorMap,
            "qs_solved" : self.solved
        ])
        for team_i in 0..<self.teams.count {
            let id = self.teamIDs[team_i]
            let docRef = gameRef.collection(id)
            for step_i in 0..<self.steps {
                docRef.addDocument(data: [
                    "step" : step_i,
                    "score" : scores[team_i][step_i]
                ])
            }
        }
    }
}

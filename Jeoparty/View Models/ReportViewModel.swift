//
//  ReportViewModel.swift
//  Jeoparty
//
//  Created by David Chen on 3/6/21.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class ReportViewModel: ObservableObject {
    @Published var allGames = [Report]()
    @Published var scores: [String:[Int]] = [:]
    @Published var currentGame: Report? = nil
    @Published var selectedID = ""
    private var db = Firestore.firestore()
    
    init() {
        getAllData()
    }
    
    func getAllData() {
        let docRef = db.collection("users").document(Auth.auth().currentUser?.uid ?? "hello").collection("games").order(by: "date", descending: true)
        docRef.addSnapshotListener { (snap, err) in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            guard let data = snap?.documents else { return }
            DispatchQueue.main.async {
                self.allGames = data.compactMap { (queryDocSnap) -> Report? in
                    return try! queryDocSnap.data(as: Report.self)
                }
            }
        }
    }
    
    func getGameInfo(id: String) {
        let docRef = db.collection("users").document(Auth.auth().currentUser?.uid ?? "hello").collection("games").document(id)
        docRef.addSnapshotListener { (doc, err) in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                self.currentGame = try? doc?.data(as: Report.self)
            }
            
            // handle all scores
            let teamIDs = doc?.get("team_ids") as! [String]
            
            for id in teamIDs {
                docRef.collection(id).order(by: "step").addSnapshotListener { (snap, err) in
                    if err != nil {
                        print(err!.localizedDescription)
                        return
                    }
                    guard let data = snap?.documents else { return }
                    DispatchQueue.main.async {
                        var id_scores = [Int]()
                        data.forEach { (doc) in
                            id_scores.append(doc.get("score") as! Int)
                        }
                        if !id_scores.isEmpty {
                            self.scores.updateValue(id_scores, forKey: id)
                            print(self.scores)
                        }
                    }
                }
            }
        }
    }
    
    func getMinMax() -> (Int, Int) {
        var min = 0
        var max = 0
        
        for teamScores in scores.values {
            guard let teamMin = teamScores.min() else { return (0, 0) }
            guard let teamMax = teamScores.max() else { return (0, 0) }
            
            min = teamMin < min ? teamMin : min
            max = teamMax > max ? teamMax : max
        }
        return (min, max)
    }
}

class Report: Decodable, Hashable {
    @DocumentID var id: String?
    var date = Date()
    var episode_played = ""
    var steps = 0
    var team_ids = [String]()
    var name_id_map = ["":""]
    var color_id_map = ["":""]
    var qs_solved = 0
    
    static func == (lhs: Report, rhs: Report) -> Bool {
        return lhs.date == rhs.date
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, date, episode_played, steps, team_ids, name_id_map, color_id_map, qs_solved
    }
    
    func getNames() -> [String] {
        var names = [String]()
        for pair in name_id_map {
            names.append(pair.value)
        }
        return names
    }
}

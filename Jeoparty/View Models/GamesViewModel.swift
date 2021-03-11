//
//  GameViewModel.swift
//  Jeoparty
//
//  Created by David Chen on 2/3/21.
//

import Foundation
import Firebase
import FirebaseFirestore

class GamesViewModel: ObservableObject {
    @Published var moneySections = ["200", "400", "600", "800", "1000"]
    @Published var isDoubleJeopardy = false
    
    @Published var seasons = [String]()
    @Published var episodes = [String]()
    @Published var categories = [String]()
    @Published var clues: [[String]] = []
    @Published var responses: [[String]] = []
    
    @Published var jeopardyCategories = ["", "", "", "", "", ""]
    @Published var jeopardyDailyDoubles = [Int]()
    @Published var doubleJeopardyCategories = ["", "", "", "", "", ""]
    @Published var djDailyDoubles1 = [Int]()
    @Published var djDailyDoubles2 = [Int]()
    @Published var jeopardyRoundClues: [[String]] = []
    @Published var doubleJeopardyRoundClues: [[String]] = []
    @Published var jeopardyRoundResponses: [[String]] = []
    @Published var doubleJeopardyRoundResponses: [[String]] = []
    @Published var fj_clue = ""
    @Published var fj_response = ""
    
    @Published var selectedSeason = ""
    @Published var selectedEpisode = ""
    @Published var usedAnswers = [String]()
    
    @Published var date = ""
    @Published var showNo = ""
    @Published var jRoundScores = [String]()
    @Published var djRoundScores = [String]()
    @Published var finalScores = [String]()
    @Published var jTripleStumpers: [[Int]] = []
    @Published var djTripleStumpers: [[Int]] = []
    
    private var moneySectionsJ = ["200", "400", "600", "800", "1000"]
    private var moneySectionsDJ = ["400", "800", "1200", "1600", "2000"]
    private var db = Firestore.firestore()
    
    init() {
        getSeasons()
    }
    
    func removeAnswer(answer: String) {
        self.usedAnswers = self.usedAnswers.filter { $0 != answer }
    }
    
    func reset() {
        self.isDoubleJeopardy = false
        self.usedAnswers = [String]()
        self.moneySections = moneySectionsJ
    }
    
    func moveOntoDoubleJeopardy() {
        self.isDoubleJeopardy = true
        self.usedAnswers = [String]()
        self.clues = doubleJeopardyRoundClues
        self.responses = doubleJeopardyRoundResponses
        self.moneySections = moneySectionsDJ
        self.categories = doubleJeopardyCategories
    }
    
    func getSeasons() {
        db.collection("seasons").order(by: "id").addSnapshotListener { (snap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = snap?.documents else { return }
            
            data.forEach { (doc) in
                self.seasons.append(String(doc.get("id") as! Int))
            }
        }
    }
    
    func setSeason(season: String) {
        self.selectedSeason = season
    }
    
    func setEpisode(ep: String) {
        self.selectedEpisode = ep
    }
    
    func getEpisodes(seasonID: String, isSelected: Bool) {
        self.episodes = [String]()
        if !isSelected {
            db.collection("seasons").document(seasonID).collection("episodes").order(by: "episode").addSnapshotListener { (snap, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                guard let data = snap?.documents else { return }
                
                data.forEach { (doc) in
                    DispatchQueue.main.async {
                        self.episodes.append(doc.documentID)
                    }
                }
            }
        }
    }
    
    func clearAll() {
        self.jeopardyCategories = ["", "", "", "", "", ""]
        self.doubleJeopardyCategories = ["", "", "", "", "", ""]
        self.usedAnswers = [String]()
        self.jeopardyRoundClues = [[""], [""], [""], [""], [""], [""]]
        self.doubleJeopardyRoundClues = [[""], [""], [""], [""], [""], [""]]
        self.jeopardyRoundResponses = [[""], [""], [""], [""], [""], [""]]
        self.doubleJeopardyRoundResponses = [[""], [""], [""], [""], [""], [""]]
        self.isDoubleJeopardy = false
        self.fj_clue = ""
        self.fj_response = ""
        self.selectedSeason = ""
        self.selectedEpisode = ""
        self.jeopardyDailyDoubles = [Int]()
        self.djDailyDoubles1 = [Int]()
        self.djDailyDoubles2 = [Int]()
        self.jTripleStumpers = []
        self.djTripleStumpers = []
    }
    
    func getEpisodeData(seasonID: String, episodeID: String) {
        clearAll()
        reset()
        db.collection("seasons").document(seasonID).collection("episodes").document(episodeID).addSnapshotListener { (doc, error) in
            let j_category_ids = doc?.get("j_category_ids") as! [String]
            let dj_category_ids = doc?.get("dj_category_ids") as! [String]
            let seasonInt = Int(seasonID) ?? 0
            let episodeInt = Int(episodeID) ?? 0
            
            // get daily doubles
            self.db.collection("daily_doubles").whereField("season", isEqualTo: seasonInt).whereField("episode", isEqualTo: episodeInt).addSnapshotListener { (snap, err) in
                guard let data = snap?.documents else { return }
                data.forEach { (doc) in
                    DispatchQueue.main.async {
                        self.jeopardyDailyDoubles = doc.get("j_round") as! [Int]
                        self.djDailyDoubles1 = doc.get("dj_round_1") as! [Int]
                        self.djDailyDoubles2 = doc.get("dj_round_2") as! [Int]
                    }
                    return
                }
            }
            
            // get episode info
            let epDocRef = self.db.collection("episode_info")
            
            epDocRef.whereField("season", isEqualTo: seasonInt).whereField("episode", isEqualTo: episodeInt).addSnapshotListener { (snap, err) in
                guard let data = snap?.documents else { return }
                guard let doc = data.first else { return }
                if doc.exists {
                    epDocRef.document(doc.documentID).collection("j_triple_stumpers").addSnapshotListener { (snap, err) in
                        guard let data = snap?.documents else { return }
                        data.forEach { (doc) in
                            DispatchQueue.main.async {
                                self.jTripleStumpers.append(doc.get("stumper") as! [Int])
                            }
                        }
                    }
                    epDocRef.document(doc.documentID).collection("dj_triple_stumpers").addSnapshotListener { (snap, err) in
                        guard let data = snap?.documents else { return }
                        data.forEach { (doc) in
                            DispatchQueue.main.async {
                                self.djTripleStumpers.append(doc.get("stumper") as! [Int])
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.date = doc.get("date") as! String
                        self.showNo = doc.get("show_no") as! String
                        self.jRoundScores = doc.get("j_round_scores") as! [String]
                        self.djRoundScores = doc.get("dj_round_scores") as! [String]
                    }
                }
            }
            
            // there are six categories, should be doing stuff for category
            for id in j_category_ids {
                self.db.collection("categories").document(id).addSnapshotListener { (doc, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    DispatchQueue.main.async {
                        let index = doc?.get("index") as! Int
                        self.jeopardyRoundClues[index] = doc?.get("clues") as! [String]
                        self.jeopardyRoundResponses[index] = doc?.get("responses") as! [String]
                        self.jeopardyCategories[index] = doc?.get("name") as! String
                        
                        self.clues = self.jeopardyRoundClues
                        self.responses = self.jeopardyRoundResponses
                        self.categories = self.jeopardyCategories
                    }
                }
            }
            
            for id in dj_category_ids {
                self.db.collection("categories").document(id).addSnapshotListener { (doc, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    DispatchQueue.main.async {
                        let index = doc?.get("index") as! Int
                        self.doubleJeopardyRoundClues[index] = doc?.get("clues") as! [String]
                        self.doubleJeopardyRoundResponses[index] = doc?.get("responses") as! [String]
                        self.doubleJeopardyCategories[index] = doc?.get("name") as! String
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.fj_clue = doc?.get("fj_clue") as! String
                self.fj_response = doc?.get("fj_response") as! String
            }
        }
    }
}

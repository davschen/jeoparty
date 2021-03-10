//
//  CategoriesView.swift
//  Jeoparty
//
//  Created by David Chen on 2/4/21.
//

import Foundation
import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var trackerVM: TrackerViewModel
    @State var answer = ""
    @State var response = ""
    @State var selectedTeam = ""
    @State var amount = 0
    @State var finalJeopardySelected = false
    @State var finalJeopardyReveal = false
    @State var nobodyGotItSelected = false
    @State var isDailyDouble = false
    @State var isTripleStumper = false
    @State var allDone = false
    @State var showInfoView = false
    
    var selectedAll: Bool {
        var numAnswers = 0
        for i in 0..<self.gamesVM.categories.count {
            for j in 0..<self.gamesVM.moneySections.count {
                let answer = self.gamesVM.clues[i][j]
                if !answer.isEmpty {
                    numAnswers += 1
                }
            }
        }
        return self.gamesVM.usedAnswers.count == (numAnswers)
    }
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                ForEach(participantsVM.teams) { team in
                    VStack (spacing: 0) {
                        Text("\(team.name) - $\(team.score)")
                            .font(Font.custom("Avenir Next Bold", size: 20))
                            .foregroundColor(.white)
                        if team.members.count > 0 {
                            HStack {
                                Image(systemName: "music.mic")
                                    .foregroundColor(.white)
                                Text(self.participantsVM.spokespeople[team.index])
                                    .font(Font.custom("Avenir Next Bold", size: 20))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: self.selectedTeam == team.name ? 10 : 0))
                    .background(ColorMap().getColor(color: team.color))
                    .cornerRadius(5)
                    .onTapGesture {
                        if self.selectedTeam == team.name {
                            self.selectedTeam = ""
                        } else {
                            self.selectedTeam = team.name
                        }
                    }
                }
            }
            .padding(.vertical, 5)
            .onAppear {
                participantsVM.getNextPlayer()
            }
            
            ZStack {
                VStack (spacing: 0) {
                    HStack {
                        Text(self.gamesVM.isDoubleJeopardy ? "Double Jeopardy Round" : "Jeopardy Round")
                            .font(Font.custom("Avenir Next Bold", size: 50))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "info.circle.fill")
                            .font(.largeTitle)
                            .onTapGesture {
                                self.showInfoView.toggle()
                            }
                    }
                    HStack {
                        ForEach(gamesVM.categories, id: \.self) { category in
                            ZStack {
                                Color("MainFG")
                                Text(category.uppercased())
                                    .font(Font.custom("Avenir Next Bold", size: 20))
                                    .foregroundColor(Color.white)
                                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 10)
                                    .frame(maxWidth: .infinity)
                            }
                            .cornerRadius(5)
                            .padding(2)
                        }
                    }
                    .frame(height: 150)
                    
                    Spacer(minLength: 3)
                    
                    HStack {
                        // grid where the clue magic happens
                        ForEach(0 ..< self.gamesVM.categories.count) { i in
                            VStack {
                                ForEach(0 ..< self.gamesVM.moneySections.count) { j in
                                    let answer = gamesVM.clues[i][j]
                                    let response = gamesVM.responses[i][j]
                                    ZStack {
                                        Color(self.gamesVM.usedAnswers.contains(answer) || answer.isEmpty ? "Darkened" : "MainFG")
                                        Text(self.gamesVM.moneySections[j])
                                            .font(Font.custom("Avenir Next Bold", size: 50))
                                            .foregroundColor(Color("MainAccent"))
                                            .shadow(color: Color.black.opacity(0.2), radius: 5)
                                            .multilineTextAlignment(.center)
                                            .opacity(self.gamesVM.usedAnswers.contains(answer) || answer.isEmpty ? 0 : 1)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(5)
                                    .shadow(color: Color.black.opacity(0.2), radius: 10)
                                    .padding(2)
                                    .onTapGesture {
                                        if !self.gamesVM.usedAnswers.contains(answer) || answer.isEmpty {
                                            self.nobodyGotItSelected = false
                                            self.updateDailyDouble(i: i, j: j)
                                            self.updateTripleStumper(i: i, j: j)
                                            self.answer = answer
                                            self.response = response
                                            self.gamesVM.usedAnswers.append(answer)
                                            self.amount = Int(self.gamesVM.moneySections[j]) ?? 0
                                            self.trackerVM.progressGame()
                                        }
                                    }
                                    .onLongPressGesture {
                                        if self.gamesVM.usedAnswers.contains(answer) {
                                            self.gamesVM.removeAnswer(answer: answer)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .opacity(self.answer.isEmpty ? 1 : 0)
                .opacity(allDone ? 0.4 : 1)
                .opacity(self.finalJeopardySelected ? 0 : 1)
                if !self.answer.isEmpty {
                    AnswerView(answer: $answer, response: $response, amount: $amount, selectedTeam: $selectedTeam, nobodyGotItSelected: $nobodyGotItSelected, isDailyDouble: self.isDailyDouble, isTripleStumper: self.isTripleStumper)
                        .environmentObject(self.participantsVM)
                        .environmentObject(self.gamesVM)
                        .onDisappear {
                            if !self.selectedTeam.isEmpty
                                && !self.participantsVM.toSubtracts[self.participantsVM.getIDByName(name: selectedTeam)]
                                && !self.nobodyGotItSelected
                                && !self.isDailyDouble
                                && self.participantsVM.teams.count > 0 {
                                let team_i = getIndex(name: selectedTeam)
                                self.participantsVM.editScore(index: team_i, amount: self.amount)
                            }
                            for team in self.participantsVM.teams {
                                self.trackerVM.editScore(index: team.index, score: team.score)
                            }
                            self.trackerVM.incrementStep()
                            if self.selectedAll && self.gamesVM.isDoubleJeopardy {
                                self.allDone.toggle()
                            } else if self.selectedAll {
                                self.gamesVM.moveOntoDoubleJeopardy()
                            }
                            self.participantsVM.getNextPlayer()
                            self.participantsVM.resetSubtracts()
                        }
                }
                if allDone {
                    HStack {
                        Text("Final Jeopardy")
                            .font(Font.custom("Avenir Next Bold", size: 50))
                            .foregroundColor(Color("Darkened"))
                            .shadow(color: Color.black.opacity(0.2), radius: 5)
                            .multilineTextAlignment(.center)
                            .padding()
                            .onTapGesture {
                                self.finalJeopardySelected.toggle()
                            }
                    }
                    .background(Color.white)
                    .cornerRadius(5)
                    .opacity(self.finalJeopardySelected ? 0 : 1)
                }
                if finalJeopardySelected {
                    FinalJeopardyView(finalJeopardySelected: $finalJeopardySelected)
                        .onDisappear {
                            self.allDone.toggle()
                        }
                }
                if showInfoView {
                    InfoView(showInfoView: $showInfoView)
                        .shadow(radius: 20)
                }
            }
        }
        .padding()
    }
    
    func getIndex(name: String) -> Int {
        for i in 0..<self.participantsVM.teams.count {
            if self.participantsVM.teams[i].name == name {
                return i
            }
        }
        return 0
    }
    
    func updateDailyDouble(i: Int, j: Int) {
        let toCheck = [i, j]
        if !self.gamesVM.isDoubleJeopardy {
            self.isDailyDouble = toCheck == self.gamesVM.jeopardyDailyDoubles
        } else {
            self.isDailyDouble = toCheck == self.gamesVM.djDailyDoubles1 || toCheck == self.gamesVM.djDailyDoubles2
        }
    }
    
    func updateTripleStumper(i: Int, j: Int) {
        let toCheck = [i, j]
        if !self.gamesVM.isDoubleJeopardy {
            self.isTripleStumper = self.gamesVM.jTripleStumpers.contains(toCheck)
        } else {
            self.isTripleStumper = self.gamesVM.djTripleStumpers.contains(toCheck)
        }
    }
}

struct InfoView: View {
    @EnvironmentObject var gamesVM: GamesViewModel
    @Binding var showInfoView: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    self.showInfoView.toggle()
                }
            VStack (alignment: .leading) {
                Text("Date of Episode: " + "\(self.gamesVM.date)")
                Text("Show Number: " + "\(self.gamesVM.showNo)")
                Text("Scores at the end of \(self.gamesVM.isDoubleJeopardy ? "the Double Jeopardy Round" : "the Jeopardy Round")")
                HStack {
                    let scores = self.gamesVM.isDoubleJeopardy ? self.gamesVM.djRoundScores : self.gamesVM.jRoundScores
                    ForEach(scores, id: \.self) { score in
                        Text(score)
                            .font(Font.custom("Avenir Next Bold", size: 20))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("Darkened"))
                            .cornerRadius(5)
                    }
                }
                Spacer()
            }
            .font(Font.custom("Avenir Next Bold", size: 20))
            .foregroundColor(Color.white)
            .padding()
            .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height / 2)
            .background(Color("MainFG"))
            .cornerRadius(20)
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    @ObservedObject static var gamesVM = GamesViewModel()
    @ObservedObject static var participantsVM = ParticipantsViewModel()
    @ObservedObject static var trackerVM = TrackerViewModel()
    
    static var previews: some View {
        CategoriesView()
            .environmentObject(self.participantsVM)
            .environmentObject(self.gamesVM)
            .environmentObject(self.trackerVM)
    }
}

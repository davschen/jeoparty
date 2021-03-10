//
//  AnswerView.swift
//  Jeoparty
//
//  Created by David Chen on 2/4/21.
//

import Foundation
import SwiftUI
import AVFoundation

struct AnswerView: View {
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var trackerVM: TrackerViewModel
    
    @Binding var answer: String
    @Binding var response: String
    @Binding var amount: Int
    @Binding var selectedTeam: String
    @Binding var nobodyGotItSelected: Bool
    
    @State var isDailyDouble: Bool
    @State var timeRemaining: Double = 15
    @State var showResponse = false
    @State var wager: Double = 0
    @State var doneSelecting = false
    @State var ddCorrect = true
    @State var audioPlayer: AVAudioPlayer!
    @State var isTripleStumper: Bool
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var maxScore: Int {
        return gamesVM.isDoubleJeopardy ? 2000 : 1000
    }
    
    var utterance: AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: self.answer)
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Daniel-compact")
        utterance.rate = 0.55
        return utterance
    }
    
    let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        ZStack {
            VStack {
                GeometryReader { geometry in
                    Rectangle()
                        .frame(width: timeRemaining > 0 ? geometry.size.width * CGFloat(Double(timeRemaining) / 15) : 0, height: 50)
                        .foregroundColor(Color("MainAccent"))
                        .animation(.easeInOut)
                }
                .frame(height: 50)
                .padding()
                
                ZStack {
                    Color(self.timeRemaining == 0 ? "Darkened" : "MainFG")
                    VStack {
                        Text(answer.uppercased())
                            .font(Font.custom("Avenir Next Bold", size: 40))
                            .foregroundColor(Color("MainAccent"))
                            .shadow(color: Color.black.opacity(0.2), radius: 5)
                            .multilineTextAlignment(.center)
                            .padding()
                        if self.showResponse {
                            VStack (spacing: 0) {
                                Text(response.uppercased())
                                    .font(Font.custom("Avenir Next Bold", size: 50))
                                    .foregroundColor(self.isTripleStumper ? Color.red : Color.white)
                                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                                    .multilineTextAlignment(.center)
                                if isTripleStumper {
                                    Text("(Triple Stumper)")
                                        .font(Font.custom("Avenir Next Bold", size: 20))
                                        .foregroundColor(Color.red)
                                        .shadow(color: Color.black.opacity(0.2), radius: 5)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                    }
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            if self.isDailyDouble {
                                HStack {
                                    Text("\(self.selectedTeam) (Wager: \(Int(self.wager)))")
                                        .font(Font.custom("Avenir Next Bold", size: 20))
                                        .foregroundColor(Color("MainAccent"))
                                    Image(systemName: "xmark")
                                        .font(.title3)
                                }
                                .shadow(color: Color.black.opacity(0.2), radius: 5)
                                .padding()
                                .background(Color.red.opacity(self.ddCorrect ? 0 : 0.5))
                                .background(Color.gray.opacity(0.4))
                                .cornerRadius(5.0)
                                .padding(5)
                                .onTapGesture {
                                    let teamIndex = self.participantsVM.getIDByName(name: self.selectedTeam)
                                    let wager = Int(self.ddCorrect ? -self.wager : self.wager)
                                    
                                    self.participantsVM.editScore(index: teamIndex, amount: wager)
                                    self.ddCorrect.toggle()
                                }
                            } else {
                                ScrollView (.horizontal) {
                                    HStack {
                                        ForEach(self.participantsVM.teams) { team in
                                            HStack {
                                                Text("\(team.name)")
                                                    .font(Font.custom("Avenir Next Bold", size: 20))
                                                    .foregroundColor(Color("MainAccent"))
                                                Image(systemName: "xmark")
                                                    .font(.title3)
                                            }
                                            .shadow(color: Color.black.opacity(0.2), radius: 5)
                                            .padding()
                                            .background(Color.red.opacity(self.participantsVM.toSubtracts[team.index] ? 0.5 : 0))
                                            .background(Color.gray.opacity(0.4))
                                            .cornerRadius(5.0)
                                            .padding(5)
                                            .onTapGesture {
                                                self.participantsVM.toSubtracts[team.index].toggle()
                                                let amount = self.participantsVM.toSubtracts[team.index] ? -self.amount : self.amount
                                                self.participantsVM.editScore(index: team.index, amount: amount)
                                                self.trackerVM.editScore(index: team.index, score: team.score + amount)
                                            }
                                        }
                                    }
                                }
                            }
                            if !self.isDailyDouble {
                                Text("Unsolved")
                                    .font(Font.custom("Avenir Next Bold", size: 20))
                                    .foregroundColor(Color("MainAccent"))
                                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                                    .padding()
                                    .background(Color.gray.opacity(self.nobodyGotItSelected ? 1 : 0.4))
                                    .cornerRadius(5.0)
                                    .padding(5)
                                    .onTapGesture {
                                        self.nobodyGotItSelected.toggle()
                                    }
                            }
                            Text("\(self.showResponse ? "Hide" : "Show") Response")
                                .font(Font.custom("Avenir Next Bold", size: 20))
                                .foregroundColor(Color("MainAccent"))
                                .shadow(color: Color.black.opacity(0.2), radius: 5)
                                .padding()
                                .background(Color.gray.opacity(self.showResponse ? 1 : 0.4))
                                .cornerRadius(5.0)
                                .padding(5)
                                .onTapGesture {
                                    self.showResponse.toggle()
                                }
                        }
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.2), radius: 10)
                .padding()
            }
            .padding(20)
            .onTapGesture {
                self.answer = ""
                if !self.nobodyGotItSelected {
                    self.trackerVM.addSolved()
                }
                synthesizer.stopSpeaking(at: .immediate)
                if self.ddCorrect && self.participantsVM.teams.count > 0 {
                    let teamIndex = self.participantsVM.getIDByName(name: self.selectedTeam)
                    self.participantsVM.editScore(index: teamIndex, amount: Int(self.wager))
                }
            }
            .onAppear {
                if !self.isDailyDouble {
                    synthesizer.speak(utterance)
                }
            }
            .onReceive(timer) { time in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                }
            }
            if self.isDailyDouble {
                VStack {
                    let currentScore = self.participantsVM.teams.count > 0 ? self.participantsVM.teams[self.participantsVM.getIDByName(name: self.selectedTeam)].score : 0
                    Text("DAILY DOUBLE")
                        .font(Font.custom("Avenir Next Bold", size: 80))
                        .foregroundColor(Color.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 5)
                        .multilineTextAlignment(.center)
                        .padding()
                    VStack {
                        Slider(value: $wager, in: 0...Double(max(maxScore, currentScore)), step: 100)
                            .accentColor(Color("MainAccent"))
                        HStack {
                            Text("Wager: \(Int(self.wager))")
                                .font(Font.custom("Avenir Next Bold", size: 30))
                                .foregroundColor(Color.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 5)
                                .multilineTextAlignment(.center)
                            Spacer(minLength: 30)
                            Text("Done")
                                .font(Font.custom("Avenir Next Bold", size: 20))
                                .foregroundColor(Color("MainAccent"))
                                .shadow(color: Color.black.opacity(0.2), radius: 5)
                                .padding()
                                .background(Color.gray.opacity(0.4))
                                .cornerRadius(5.0)
                                .padding(5)
                                .onTapGesture {
                                    self.doneSelecting.toggle()
                                    self.timeRemaining = 15
                                    synthesizer.speak(utterance)
                                }
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width / 2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("MainFG"))
                .cornerRadius(20)
                .padding(20)
                .opacity(self.doneSelecting ? 0 : 1)
                .onAppear {
                    playSounds("dailyDouble.m4a")
                }
            }
        }
    }
    func playSounds(_ soundFileName : String) {
        guard let soundURL = Bundle.main.url(forResource: soundFileName, withExtension: nil) else {
            fatalError("Unable to find \(soundFileName) in bundle")
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
        } catch {
            print(error.localizedDescription)
        }
        audioPlayer.play()
    }
}

struct AnswerView_Previews: PreviewProvider {
    @State static var answer = "Hello this is a fake answer"
    @State static var response = "fake response"
    @State static var team = ""
    @State static var nobodyGotItSelected = false
    @State static var amount = 0
    @ObservedObject static var participantsVM = ParticipantsViewModel()
    @ObservedObject static var gamesVM = GamesViewModel()
    
    static var previews: some View {
        AnswerView(answer: $answer, response: $response, amount: $amount, selectedTeam: $team, nobodyGotItSelected: $nobodyGotItSelected, isDailyDouble: true, isTripleStumper: true)
            .environmentObject(self.participantsVM)
            .environmentObject(self.gamesVM)
    }
}

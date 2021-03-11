//
//  FinalJeopardyView.swift
//  Jeoparty
//
//  Created by David Chen on 2/9/21.
//

import Foundation
import SwiftUI
import AVFoundation

struct FinalJeopardyView: View {
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var trackerVM: TrackerViewModel
    
    @Binding var finalJeopardySelected: Bool
    
    @State var finalJeopardyReveal = false
    @State var timeRemaining: Double = 30
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var utterance: AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: self.gamesVM.fj_clue)
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
                        .frame(width: timeRemaining > 0 ? geometry.size.width * CGFloat(Double(timeRemaining) / 60) : 0, height: 50)
                        .foregroundColor(Color("MainAccent"))
                        .animation(.easeInOut)
                }
                .frame(height: 50)
                .padding()
                .onAppear {
                    self.timeRemaining = 60
                }
                .onReceive(timer) { time in
                    if self.timeRemaining > 0 {
                        self.timeRemaining -= 1
                    }
                }
                ScrollView (.vertical) {
                    VStack {
                        HStack {
                            Text("Final Jeopardy Round")
                                .foregroundColor(Color.white)
                                .font(Font.custom("Avenir Next Bold", size: 50))
                                .padding()
                            Text("Reveal")
                                .font(Font.custom("Avenir Next Bold", size: 30))
                                .foregroundColor(Color.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 5)
                                .padding()
                                .background(Color.gray.opacity(self.finalJeopardyReveal ? 1 : 0.4))
                                .cornerRadius(5.0)
                                .padding(5)
                                .onTapGesture {
                                    self.finalJeopardyReveal.toggle()
                                }
                            Spacer()
                        }
                        Text(self.gamesVM.fj_clue)
                            .foregroundColor(Color("MainAccent"))
                            .font(Font.custom("Avenir Next Bold", size: 30))
                            .padding()
                        if self.finalJeopardyReveal {
                            HStack {
                                Text("Correct Response: \(self.gamesVM.fj_response)")
                                    .font(Font.custom("Avenir Next Bold", size: 30))
                                    .padding()
                                Text("Finish Game")
                                    .font(Font.custom("Avenir Next Bold", size: 30))
                                    .foregroundColor(Color("Darkened"))
                                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(5)
                                    .onTapGesture {
                                        self.finalJeopardySelected.toggle()
                                        print(trackerVM.scores)
                                        for team in self.participantsVM.teams {
                                            self.trackerVM.editScore(index: team.index, score: team.score)
                                        }
                                        print(trackerVM.scores)
                                        self.trackerVM.writeToFirestore(showNo: self.gamesVM.showNo)
                                        self.participantsVM.resetScores()
                                        self.gamesVM.reset()
                                    }
                            }
                        }
                    }
                    ForEach(0..<self.participantsVM.teams.count) { i in
                        let team = self.participantsVM.teams[i]
                        HStack (alignment: .bottom) {
                            HStack {
                                Text("\(team.name): ")
                                    .font(Font.custom("Avenir Next Bold", size: 30))
                                    .foregroundColor(.white)
                                Text(String("$" + String(team.score)))
                                    .font(Font.custom("Avenir Next Bold", size: 30))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 300)
                            .padding()
                            .background(ColorMap().getColor(color: team.color))
                            .cornerRadius(5)
                            VStack (alignment: .leading) {
                                Text("Answer")
                                    .font(Font.custom("Avenir Next Bold", size: 30))
                                    .foregroundColor(.white)
                                HStack {
                                    TextField("Final Answer", text: $participantsVM.finalJeopardyAnswers[i])
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(5)
                                        .foregroundColor(.black)
                                }
                            }
                            VStack (alignment: .leading) {
                                Text("Wager")
                                    .font(Font.custom("Avenir Next Bold", size: 30))
                                    .foregroundColor(.white)
                                HStack {
                                    TextField("Enter Wager", text: $participantsVM.wagers[i])
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(5)
                                        .foregroundColor(.black)
                                    Image(systemName: "checkmark")
                                        .font(.title)
                                        .padding(10)
                                        .foregroundColor(Color("Darkened"))
                                        .background(Color.white.opacity(self.participantsVM.fjCorrects[team.index] ? 1 : 0.4))
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            if self.participantsVM.toSubtracts[team.index] {
                                                self.participantsVM.addFJIncorrect(index: team.index)
                                            }
                                            self.participantsVM.addFJCorrect(index: team.index)
                                        }
                                    Image(systemName: "xmark")
                                        .font(.title)
                                        .padding(10)
                                        .foregroundColor(Color("Darkened"))
                                        .background(Color.white.opacity(self.participantsVM.toSubtracts[team.index] ? 1 : 0.4))
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            if self.participantsVM.fjCorrects[team.index] {
                                                self.participantsVM.addFJCorrect(index: team.index)
                                            }
                                            self.participantsVM.addFJIncorrect(index: team.index)
                                        }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color("MainFG"))
            .cornerRadius(10)
            .padding(.horizontal)
            .onAppear {
                synthesizer.speak(utterance)
                self.trackerVM.progressGame()
                // self.trackerVM.incrementStep()
            }
        }
        .padding(20)
    }
}

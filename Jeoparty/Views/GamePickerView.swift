//
//  GamePickerView.swift
//  Jeoparty
//
//  Created by David Chen on 2/8/21.
//

import Foundation
import SwiftUI
import AVFoundation

struct GamePickerView: View {
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var trackerVM: TrackerViewModel
    @State var showEpisodes = -1
    @State var selectedEpisode = -1
    @State var selectedSeason = -1
    @State var episodeNumber = 0
    @State var audioPlayer: AVAudioPlayer!
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            Color("MainBG")
                .edgesIgnoringSafeArea(.all)
            ScrollView (.vertical) {
                VStack (alignment: .leading) {
                    Text("Seasons")
                        .font(Font.custom("Avenir Next Bold", size: 50))
                        .padding(.horizontal)
                    let seasonColumnGrid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
                    
                    LazyVGrid(columns: seasonColumnGrid) {
                        ForEach(gamesVM.seasons, id: \.self) { season in
                            let i = Int(season) ?? -1
                            ZStack {
                                Text("\(i)")
                                    .font(Font.custom("Avenir Next Bold", size: 30))
                                    .foregroundColor(Color("MainAccent"))
                                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                            }
                            .frame(maxWidth: .infinity)
                            .shadow(color: Color.black.opacity(0.2), radius: 10)
                            .padding(10)
                            .onTapGesture {
                                self.gamesVM.getEpisodes(seasonID: String(i), isSelected: self.selectedSeason == i)
                                selectedSeason = i
                                self.gamesVM.setSeason(season: season)
                            }
                            .background(Color.gray.opacity(self.selectedSeason == i ? 1 : 0.3))
                            .clipShape(Circle())
                            .id(UUID())
                        }
                    }
                    
                    let episodeColumnGrid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
                    Text("Episodes (\(self.gamesVM.episodes.count))")
                        .font(Font.custom("Avenir Next Bold", size: 50))
                        .padding(.horizontal)
                    LazyVGrid(columns: episodeColumnGrid) {
                        ForEach(gamesVM.episodes, id: \.self) { episode in
                            let episode_index = Int(episode) ?? -1
                            ZStack {
                                Color(self.selectedEpisode == episode_index ? "Darkened" : "MainFG")
                                Text("\(episode_index)")
                                    .font(Font.custom("Avenir Next Bold", size: 50))
                                    .foregroundColor(Color("MainAccent"))
                                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .cornerRadius(5)
                            .shadow(color: Color.black.opacity(0.2), radius: 10)
                            .padding(3)
                            .onTapGesture {
                                self.selectedEpisode = episode_index
                                self.gamesVM.getEpisodeData(seasonID: String(self.selectedSeason), episodeID: String(episode))
                                self.gamesVM.setEpisode(ep: episode)
                                self.participantsVM.resetScores()
                                self.trackerVM.resetGame()
                            }
                            .padding(5)
                            .id(UUID())
                        }
                    }
                }
                .padding(25)
            }
        }
        .onAppear {
            self.selectedSeason = Int(self.gamesVM.selectedSeason) ?? -1
            self.selectedEpisode = Int(self.gamesVM.selectedEpisode) ?? -1
            playSounds("Jeopardy-theme-song.mp3")
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

struct GamePickerView_Previews: PreviewProvider {
    @ObservedObject static var gamesVM = GamesViewModel()
    @ObservedObject static var participantsVM = ParticipantsViewModel()
    
    static var previews: some View {
        GamePickerView()
            .environmentObject(gamesVM)
            .environmentObject(participantsVM)
    }
}

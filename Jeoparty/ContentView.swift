//
//  ContentView.swift
//  Jeoparty
//
//  Created by David Chen on 2/3/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @ObservedObject var participantsVM = ParticipantsViewModel()
    @ObservedObject var gamesVM = GamesViewModel()
    @ObservedObject var trackerVM = TrackerViewModel()
    @ObservedObject var reportVM = ReportViewModel()
    
    @State var menuChoice = "gamepicker"
    @State var isLoggedIn = UserDefaults.standard.value(forKey: "isLoggedIn") as? Bool ?? false
    
    var body: some View {
        ZStack {
            if true {
                VStack {
                    ZStack {
                        if self.menuChoice == "game" {
                            ZStack {
                                Color("MainBG")
                                    .edgesIgnoringSafeArea(.all)
                                CategoriesView()
                                    .environmentObject(participantsVM)
                                    .environmentObject(gamesVM)
                                    .environmentObject(trackerVM)
                            }
                        } else if self.menuChoice == "participants" {
                            ParticipantsView()
                                .environmentObject(participantsVM)
                                .environmentObject(trackerVM)
                        } else if self.menuChoice == "gamepicker" {
                            GamePickerView()
                                .environmentObject(gamesVM)
                                .environmentObject(participantsVM)
                                .environmentObject(trackerVM)
                        } else if self.menuChoice == "reports" {
                            ReportsView()
                                .environmentObject(reportVM)
                        }
                    }
                    HStack (spacing: 30) {
                        Image(systemName: menuChoice == "gamepicker" ? "square.grid.3x2.fill" : "square.grid.3x2")
                            .foregroundColor(menuChoice == "gamepicker" ? .blue : .gray)
                            .onTapGesture {
                                self.menuChoice = "gamepicker"
                            }
                        Image(systemName: menuChoice == "participants" ? "person.3.fill" : "person.3")
                            .foregroundColor(menuChoice == "participants" ? .blue : .gray)
                            .onTapGesture {
                                self.menuChoice = "participants"
                            }
                        Image(systemName: menuChoice == "game" ? "gamecontroller.fill" : "gamecontroller")
                            .foregroundColor(menuChoice == "game" ? .blue : .gray)
                            .onTapGesture {
                                self.menuChoice = "game"
                            }
                        Image(systemName: menuChoice == "reports" ? "bookmark.fill" : "bookmark")
                            .foregroundColor(menuChoice == "reports" ? .blue : .gray)
                            .onTapGesture {
                                self.menuChoice = "reports"
                            }
                    }
                    .frame(height: 70)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .shadow(color: Color.black.opacity(0.1), radius: 10)
                }
                .animation(.easeInOut)
                .edgesIgnoringSafeArea(.all)
            } else {
                SignInView()
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("LogInStatusChange"), object: nil, queue: .main) { (_) in
                let isLoggedIn = UserDefaults.standard.value(forKey: "isLoggedIn") as? Bool ?? false
                self.isLoggedIn = isLoggedIn
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

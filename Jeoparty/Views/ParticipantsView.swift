//
//  ParticipantsView.swift
//  Jeoparty
//
//  Created by David Chen on 2/4/21.
//

import Foundation
import SwiftUI

struct ParticipantsView: View {
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var trackerVM: TrackerViewModel
    @State var showsBuild = false
    @State var teamToEdit = Team(index: 0, name: "", members: [], score: 0, color: "")
    @State var isTeams = false
    					
    var body: some View {
        ZStack (alignment: .topLeading) {
            Color("MainBG")
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack (spacing: 15) {
                    Text("\(self.isTeams ? "Teams" : "Contestants") (\(self.participantsVM.teams.count))")
                        .font(Font.custom("Avenir Next Bold", size: 50))
                        .onTapGesture {
                            self.isTeams.toggle()
                        }
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color("MainFG"))
                        .clipShape(Circle())
                        .onTapGesture {
                            self.participantsVM.addTeam(index: self.participantsVM.teams.count, name: "", members: [], score: 0, color: "")
                            self.trackerVM.addTeam(team: self.participantsVM.teams.last!)
                            self.teamToEdit = self.participantsVM.teams.last!
                            self.showsBuild.toggle()
                        }
                    Spacer()
                }
                HStack (alignment: .top) {
                    ForEach(self.participantsVM.teams) { team in
                        VStack {
                            HStack {
                                Text(team.name.isEmpty ? "" : team.name + (self.isTeams ? " (\(team.members.count))" : ""))
                                    .font(Font.custom("Avenir Next Bold", size: 30))
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .background(ColorMap().getColor(color: team.color))
                            .cornerRadius(5)
                            .onTapGesture {
                                self.teamToEdit = team
                                self.showsBuild.toggle()
                            }
                            ScrollView (.vertical) {
                                ForEach(team.members, id: \.self) { member in
                                    HStack {
                                        Text(member.isEmpty ? "" : member)
                                            .font(Font.custom("Avenir Next Bold", size: 30))
                                        Spacer()
                                        Image(systemName: "minus.circle.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(Color("MainFG"))
                                            .onTapGesture {
                                                self.participantsVM.removeMember(index: team.index, name: member)
                                            }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color("MainAccent"))
                                    .cornerRadius(5)
                                }
                            }
                        }
                        .frame(maxHeight: .infinity)
                    }
                }
            }
            .padding(40)
            TeamBuildView(showsBuild: $showsBuild, team: $teamToEdit, isTeams: $isTeams)
        }
        .animation(.easeInOut)
    }
}

struct TeamBuildView: View {
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var trackerVM: TrackerViewModel
    
    @Binding var showsBuild: Bool
    @Binding var team: Team
    @Binding var isTeams: Bool
    
    @State var nameToAdd = ""
    @State var teamNameToAdd = ""
    @State var scoreToAdd = ""
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(self.showsBuild ? 0.5 : 0)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    self.showsBuild.toggle()
                }
            
            VStack {
                Spacer()
                ZStack (alignment: .top) {
                    VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                    
                    VStack (alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Editing: \(self.teamNameToAdd)")
                                .font(Font.custom("Avenir Next Bold", size: 40))
                            Image(systemName: "minus.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .background(Color("MainFG"))
                                .clipShape(Circle())
                                .onTapGesture {
                                    self.participantsVM.removeTeam(index: team.index)
                                    self.trackerVM.removeTeam(index: team.index)
                                }
                        }
                        HStack {
                            ColorPickerView(color: .orange, colorString: "orange", team: $team)
                            ColorPickerView(color: .yellow, colorString: "yellow", team: $team)
                            ColorPickerView(color: .purple, colorString: "purple", team: $team)
                            ColorPickerView(color: .red, colorString: "red", team: $team)
                            ColorPickerView(color: .pink, colorString: "pink", team: $team)
                            ColorPickerView(color: .blue, colorString: "blue", team: $team)
                        }
                        .frame(height: 50)
                        HStack {
                            VStack (alignment: .leading) {
                                Text("\(self.isTeams ? "Teams" : "Participant") Name")
                                    .font(Font.custom("Avenir Next Bold", size: 25))
                                HStack {
                                    TextField("Add Name", text: $teamNameToAdd)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(5)
                                        .foregroundColor(.black)
                                    Image(systemName: "checkmark")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Color("MainFG"))
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            self.participantsVM.editName(index: self.team.index, name: self.teamNameToAdd)
                                            self.trackerVM.editName(id: self.team.id, name: self.teamNameToAdd)
                                            self.teamNameToAdd = ""
                                        }
                                    Spacer()
                                }
                            }
                            if self.isTeams {
                                Spacer(minLength: 20)
                                VStack (alignment: .leading) {
                                    Text("Add Member Name")
                                        .font(Font.custom("Avenir Next Bold", size: 25))
                                    HStack {
                                        TextField("Add Member Name", text: $nameToAdd)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(5)
                                            .foregroundColor(.black)
                                        Image(systemName: "plus")
                                            .font(.largeTitle)
                                            .foregroundColor(.white)
                                            .padding(10)
                                            .background(Color("MainFG"))
                                            .clipShape(Circle())
                                            .onTapGesture {
                                                if !self.nameToAdd.isEmpty {
                                                    self.participantsVM.addMember(index: team.index, name: nameToAdd)
                                                    self.nameToAdd = ""
                                                }
                                            }
                                        Spacer()
                                    }
                                }
                            }
                        }
                        VStack (alignment: .leading) {
                            Text("Edit Score (\(team.score))")
                                .font(Font.custom("Avenir Next Bold", size: 25))
                            HStack {
                                TextField("Score to Add", text: $scoreToAdd)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(5)
                                    .foregroundColor(.black)
                                    .keyboardType(.numberPad)
                                Image(systemName: "checkmark")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color("MainFG"))
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        if !self.scoreToAdd.isEmpty {
                                            self.participantsVM.editScore(index: self.team.index, amount: Int(scoreToAdd) ?? 0)
                                            self.scoreToAdd = ""
                                        }
                                    }
                                Spacer()
                            }
                        }
                    }
                    .padding(40)
                }
                .frame(height: UIScreen.main.bounds.height * 0.5)
                .clipShape(RoundedCorners(tl: 20, tr: 20, bl: 0, br: 0))
                .offset(y: self.showsBuild ? 0 : UIScreen.main.bounds.height)
            }
        }
    }
}

struct ColorPickerView: View {
    @State var color: Color
    @State var colorString: String
    @Binding var team: Team
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var trackerVM: TrackerViewModel
    
    var body: some View {
        VStack {
            Circle().foregroundColor(color)
                .background(Circle().stroke(Color.blue, lineWidth: team.color == colorString ? 10 : 0))
                .onTapGesture {
                    self.team.color = colorString
                    self.participantsVM.editColor(index: team.index, color: colorString)
                    self.trackerVM.editColor(id: team.id, color: colorString)
                }
        }
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct ColorMap {
    func getColor(color: String) -> Color {
        switch color {
        case "orange":
            return Color.orange
        case "yellow":
            return Color.yellow
        case "purple":
            return Color.purple
        case "red":
            return Color.red
        case "pink":
            return Color.pink
        default:
            return Color.blue
        }
    }
}

struct RoundedCorners: Shape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0

    func path(in rect: CGRect) -> Path {
        Path { path in
            let w = rect.size.width
            let h = rect.size.height

            let tr = min(min(self.tr, h/2), w/2)
            let tl = min(min(self.tl, h/2), w/2)
            let bl = min(min(self.bl, h/2), w/2)
            let br = min(min(self.br, h/2), w/2)

            path.move(to: CGPoint(x: w / 2.0, y: 0))
            path.addLine(to: CGPoint(x: w - tr, y: 0))
            path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
            path.addLine(to: CGPoint(x: w, y: h - br))
            path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
            path.addLine(to: CGPoint(x: bl, y: h))
            path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
            path.addLine(to: CGPoint(x: 0, y: tl))
            path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        }
    }
}

struct ParticipantsView_Previews: PreviewProvider {
    @ObservedObject static var participantsVM = ParticipantsViewModel()
    @ObservedObject static var trackerVM = TrackerViewModel()
    
    static var previews: some View {
        ParticipantsView()
            .environmentObject(participantsVM)
            .environmentObject(self.trackerVM)
    }
}

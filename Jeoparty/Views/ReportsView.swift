//
//  ReportsView.swift
//  Jeoparty
//
//  Created by David Chen on 3/7/21.
//

import Foundation
import SwiftUI

struct ReportsView: View {
    @EnvironmentObject var reportVM: ReportViewModel
    @State var id = ""
    
    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .long
        return df
    }
    
    var body: some View {
        ZStack {
            Color("MainBG")
                .edgesIgnoringSafeArea(.all)
            HStack {
                VStack (alignment: .leading, spacing: 5) {
                    Text("All Games")
                        .font(Font.custom("Avenir Next Bold", size: 40))
                        .foregroundColor(Color("MainAccent"))
                    ScrollView (.vertical) {
                        ForEach(reportVM.allGames, id: \.self) { game in
                            VStack (alignment: .leading) {
                                HStack {
                                    Text("#" + game.episode_played + ", " + "\(dateFormatter.string(from: game.date))")
                                        .font(Font.custom("Avenir Next Bold", size: 25))
                                        .foregroundColor(Color.white)
                                    Spacer()
                                }
                                HStack {
                                    ForEach(game.getNames(), id: \.self) { name in
                                        Text(name.uppercased())
                                            .font(Font.custom("Avenir Next Bold", size: 10))
                                            .foregroundColor(Color("MainAccent"))
                                    }
                                }
                            }
                            .padding(.horizontal, 15).padding(.vertical, 10)
                            .background(Color.gray.opacity(self.id == game.id! ? 0.3 : 0))
                            .cornerRadius(5)
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                if gameSelected(id: game.id!) {
                                    self.id = ""
                                } else {
                                    self.reportVM.getGameInfo(id: game.id!)
                                    self.id = game.id!
                                }
                            }
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.25)
                }
                Rectangle()
                    .frame(width: 1)
                    .padding()
                VStack {
                    HStack {
                        if !self.id.isEmpty {
                            AnalysisView()
                            Spacer()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(30)
        }
    }
    
    func gameSelected(id: String) -> Bool {
        return self.id == id
    }
}

struct AnalysisView: View {
    @EnvironmentObject var reportVM: ReportViewModel
    
    var body: some View {
        ZStack {
            if let game = reportVM.currentGame {
                VStack (alignment: .leading) {
                    Text("Game Analysis")
                        .font(Font.custom("Avenir Next Bold", size: 50))
                    HStack {
                        ForEach(game.team_ids, id: \.self) { id in
                            if let name = game.name_id_map[id], let color = game.color_id_map[id] {
                                HStack {
                                    Circle()
                                        .foregroundColor(ColorMap().getColor(color: color))
                                        .frame(width: 10)
                                    Text(name)
                                        .font(Font.custom("Avenir Next Bold", size: 20))
                                        .foregroundColor(self.reportVM.selectedID == id ? .white : Color("MainAccent"))
                                }
                                .padding()
                                .frame(height: 50)
                                .background(Color.gray.opacity(self.reportVM.selectedID == id ? 1 : 0.4))
                                .cornerRadius(5)
                                .onTapGesture {
                                    self.reportVM.selectedID = (self.reportVM.selectedID == id) ? "" : id
                                }
                            }
                        }
                    }
                    HStack {
                        // y axis
                        VStack {
                            ForEach(self.reportVM.yAxis.reversed(), id: \.self) { yVal in
                                Text("\(yVal)")
                                    .font(Font.custom("Avenir Next Bold", size: 10))
                                    .frame(maxHeight: .infinity)
                            }
                            .frame(width: 50)
                            .frame(maxHeight: .infinity)
                        }
                        VStack {
                            ChartView(min: reportVM.min, max: reportVM.max)
                            // x axis
                            HStack {
                                ForEach(self.reportVM.xAxis, id: \.self) { xVal in
                                    Text("\(xVal)")
                                        .font(Font.custom("Avenir Next Bold", size: 10))
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .frame(height: 15)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

struct ChartView: View {
    @EnvironmentObject var reportVM: ReportViewModel
    @State var on = true
    
    var min: CGFloat
    var max: CGFloat
    var newMax: CGFloat {
        return max - min
    }
    var newMin: CGFloat {
        return min - min
    }
    
    var body: some View {
        VStack {
            ZStack {
                if let currentGame = reportVM.currentGame {
                    ForEach(currentGame.team_ids, id: \.self) { id in
                        if let scores = reportVM.scores[id] {
                            LineGraph(dataPoints: scores.map { CGFloat($0) }, min: min, max: max)
                                .stroke(style: StrokeStyle(lineCap: .round, lineJoin: .round))
                                .stroke(ColorMap().getColor(color: currentGame.color_id_map[id]!), lineWidth: 2)
                                .opacity((reportVM.selectedID == id || reportVM.selectedID.isEmpty) ? 1 : 0.25)
                                .border(Color.gray, width: 1)
                        }
                    }
                }
            }
        }
    }
}

struct LineGraph: Shape {
    var dataPoints: [CGFloat]
    var min: CGFloat
    var max: CGFloat
    var newMax: CGFloat {
        return max - min
    }
    var newMin: CGFloat {
        return min - min
    }
    
    func path(in rect: CGRect) -> Path {
        func point(at ix: Int) -> CGPoint {
            let point = dataPoints[ix] - min
            let x = rect.width * CGFloat(ix) / CGFloat(dataPoints.count - 1)
            let y = ((newMax-point) / (newMax - newMin)) * rect.height
            return CGPoint(x: x, y: y)
        }

        return Path { p in
            guard dataPoints.count > 1 else { return }
            let start = dataPoints[0] - min
            p.move(to: CGPoint(x: 0, y: ((newMax-start) / (newMax - newMin)) * rect.height))
            for idx in dataPoints.indices {
                p.addLine(to: point(at: idx))
            }
        }
    }
}

struct ReportsView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsView()
    }
}

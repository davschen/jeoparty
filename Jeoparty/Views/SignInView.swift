//
//  SignInView.swift
//  Jeoparty
//
//  Created by David Chen on 3/2/21.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth

struct SignInView: View {
    @State var isShowingVerify = false
    @State var countryCode = "1"
    @State var number = ""
    @State var code = ""
    @State var alertMessage = ""
    @State var ID = ""
    @State var alert = false
    @State var signedIn = false
    @State var name = ""
    @State var showGame = false
    
    private var db = Firestore.firestore()
    
    var body: some View {
        ZStack {
            Color("MainFG")
                .edgesIgnoringSafeArea(.all)
            HStack {
                HStack {
                    Spacer()
                    Text("Welcome to Jeoparty!")
                        .font(Font.custom("Avenir Next Bold", size: 50))
                        .foregroundColor(Color("MainAccent"))
                    Spacer()
                }
                Spacer()
                ZStack {
                    VisualEffectView(effect: UIBlurEffect(style: .dark))
                    VStack (alignment: .leading, spacing: 15) {
                        HStack {
                            if isShowingVerify{
                                Image(systemName: "chevron.left")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .onTapGesture {
                                        self.isShowingVerify.toggle()
                                    }
                            }
                            Text(self.isShowingVerify ? "Enter Code" : "Login/Sign In")
                                .font(Font.custom("Avenir Next Bold", size: 30))
                                .foregroundColor(Color.white)
                        }
                        if !isShowingVerify {
                            ZStack {
                                ZStack (alignment: .leading) {
                                    if number.isEmpty {
                                        Text("Enter Your Number")
                                            .foregroundColor(.gray)
                                    }
                                    TextField("Enter Your Number", text: $number)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .foregroundColor(.white)
                                        .keyboardType(.numberPad)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 15)
                                .font(Font.custom("Avenir Next Medium", size: 14))
                                .background(RoundedRectangle(
                                    cornerRadius: 5, style: .continuous
                                ).stroke(Color.white, lineWidth: 2))
                                .accentColor(.white)
                                HStack {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Color.green.opacity(hasValidEntry() ? 1 : 0.3))
                                        .clipShape(Circle())
                                        .padding(.horizontal, 7)
                                        .background(Circle().stroke(Color.white, lineWidth: 0.5))
                                }
                            }
                            ZStack (alignment: .leading) {
                                if name.isEmpty {
                                    Text("Enter Your Name")
                                        .foregroundColor(.white)
                                }
                                TextField("Enter Your Name", text: $name)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 15)
                            .font(Font.custom("Avenir Next Medium", size: 14))
                            .background(RoundedRectangle(
                                cornerRadius: 5, style: .continuous
                            ).stroke(Color.white, lineWidth: 2))
                            .accentColor(.white)
                        } else {
                            ZStack {
                                ZStack (alignment: .leading) {
                                    if number.isEmpty {
                                        Text("Enter Valid Code")
                                            .foregroundColor(.gray)
                                    }
                                    TextField("Enter Valid Code", text: $code)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .foregroundColor(.white)
                                        .keyboardType(.numberPad)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 15)
                                .font(Font.custom("Avenir Next Medium", size: 14))
                                .background(RoundedRectangle(
                                    cornerRadius: 5, style: .continuous
                                ).stroke(Color.white, lineWidth: 2))
                                .accentColor(.white)
                                HStack {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Color.green.opacity(hasValidCode() ? 1 : 0.3))
                                        .clipShape(Circle())
                                        .padding(.horizontal, 7)
                                        .background(Circle().stroke(Color.white, lineWidth: 0.5))
                                }
                            }
                        }
                        
                        Button(action: {
                            if !isShowingVerify {
                                if hasValidEntry() {
                                    self.isShowingVerify.toggle()
                                    PhoneAuthProvider.provider().verifyPhoneNumber("+" + self.countryCode + self.number, uiDelegate: nil) { (ID, err) in
                                        if err != nil {
                                            self.alertMessage = (err?.localizedDescription)!
                                            self.alert.toggle()
                                            return
                                        }
                                        self.ID = ID!
                                    }
                                }
                            } else {
                                let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.ID, verificationCode: self.code)
                                Auth.auth().signIn(with: credential) { (result, error) in
                                    if error != nil {
                                        self.alertMessage = (error?.localizedDescription)!
                                        self.alert.toggle()
                                        return
                                    }
                                    let docref = self.db.collection("users").document(Auth.auth().currentUser?.uid ?? "")
                                    docref.getDocument { (doc, error) in
                                        if error != nil {
                                            print(error!)
                                            return
                                        }
                                        if let doc = doc {
                                            NotificationCenter.default.post(name: NSNotification.Name("LogInStatusChange"), object: nil)
                                            if doc.exists {
                                                UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
                                                self.signedIn.toggle()
                                            } else {
                                                docref.setData([
                                                    "name" : self.name
                                                ])
                                            }
                                            showGame.toggle()
                                        }
                                    }
                                }
                            }
                        }, label: {
                            Text("Continue")
                                .font(Font.custom("Avenir Next Bold", size: 20))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("MainFG")
                                                .opacity(hasValidEntry() && !isShowingVerify ? 1 : 0.7)
                                                .opacity(hasValidCode() && isShowingVerify ? 1 : 0.7))
                                .clipShape(Capsule())
                        })
                    }
                    .padding(.horizontal, 30)
                }
                .frame(width: UIScreen.main.bounds.width / 2)
                .cornerRadius(20)
            }
            .padding()
            .animation(.easeInOut)
            .alert(isPresented: $alert) {
                Alert(title: Text("Error"), message: Text(self.alertMessage), dismissButton: .default(Text("Got It")))
            }
        }
        if showGame {
            ContentView()
        }
    }
    
    func hasValidEntry() -> Bool {
        return self.countryCode.count >= 1 && self.number.count >= 10
    }
    
    func hasValidCode() -> Bool {
        return self.code.count == 6
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}

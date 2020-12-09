//
//  ContentView.swift
//  Contact_Tracing
//
//  Created by Haider Tariq on 10/23/20.
//

import SwiftUI
import Foundation
import CoreBluetooth
import MessageUI
import UIKit
import os

struct ContentView: View {
    var body: some View {
        // User must finish the whole demo once, providing and verifying their email,
        // else repeat Demo until done.
        if(UserDefaults.standard.bool(forKey: "DemoDone?") == false) { // default: false
            ageRequirement()
        }
        
        else {
            //Demo has been fdone once before, email has been set.
            Home(email: UserDefaults.standard.string(forKey: "Email")!)
        }
    }
}

struct ageRequirement: View {
    var body: some View {
        NavigationView() {
            ZStack() {
                Color(red: 232 / 255, green: 117 / 255, blue: 17 / 255).ignoresSafeArea()
                
                VStack() {
                    Image("5-with")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 500.0, height: 500.0)
                        .ignoresSafeArea()
                    
                    Spacer()
                    
                    Text("You must be 18 and above to use G-COVIDWISE.")
                        .fontWeight(.semibold)
                        .font(.custom("Helvetica Neue", size: 25.0))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 2)
                    
                    NavigationLink(destination: NavigationLazyView(Introduction()).navigationBarTitle("").navigationBarHidden(true)) {
                        Text("I am 18 and above")
                            .fontWeight(.bold)
                            .font(.custom("Helvetica Neue", size: 25.0))
                            .padding()
                            .foregroundColor(.white)
                            .background(LinearGradient(gradient: Gradient(colors: [Color(red: 232 / 255, green: 117 / 255, blue: 17 / 255), Color(red: 0 / 255, green: 63 / 255, blue: 135 / 255)]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(35)
                            .overlay(RoundedRectangle(cornerRadius: 35).stroke(Color.black, lineWidth: 3))
                    }.padding(.bottom, 3)
                    
                    NavigationLink(destination: Below18()) {
                        Text("I am under 18")
                            .fontWeight(.bold)
                            .font(.custom("Helvetica Neue", size: 25.0))
                            .padding()
                            .foregroundColor(.white)
                            .background(LinearGradient(gradient: Gradient(colors: [Color(red: 232 / 255, green: 117 / 255, blue: 17 / 255), Color(red: 0 / 255, green: 63 / 255, blue: 135 / 255)]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(35)
                            .overlay(RoundedRectangle(cornerRadius: 35).stroke(Color.black, lineWidth: 3))
                    }.padding(.bottom, 17)
                }
            }.navigationBarHidden(true)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct Below18: View {
    var body: some View {
        ZStack() {
            Color(red: 232 / 255, green: 117 / 255, blue: 17 / 255).ignoresSafeArea()
            
            VStack(spacing: 15) {
                Text("Thank you for your interest in keeping the Gettysburg Community safe. In accordance with Federal Law, you are too young to participate in this app. Here are some resource(s) on how you can help out.\n")
                    .font(.custom("Helvetica Neue", size: 22.0))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                
                Link("CDC Guidelines", destination: URL(string: "https://www.cdc.gov/coronavirus/2019-ncov/index.html")!)
                    .font(.custom("Helvetica Neue", size: 25.0))
                    .foregroundColor(Color(red: 0 / 255, green: 63 / 255, blue: 135 / 255))
                
                Text("\nStay safe by social distancing, wearing masks when in public spaces, and washing hands frequently. \n\n\nIf you selected your age incorrectly, please use the back button at the top.")
                    .font(.custom("Helvetica Neue", size: 22.0))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
            }
        }
    }
}

struct Introduction: View {
    var body: some View {
        NavigationView() {
            ZStack() {
                Color(red: 232 / 255, green: 117 / 255, blue: 17 / 255).ignoresSafeArea()
                
                GeometryReader { geo in
                    VStack(spacing: geo.size.height * 0.01) {
                        Text("G-COVIDWISE")
                            .font(.custom("Helvetica Neue", size: geo.size.width * 0.08)).fontWeight(.bold)
                        
                        Image("k2-removebg-preview")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geo.size.width * 0.50, height: geo.size.width * 0.50)
                        
                        Text("WELCOME TO G-COVIDWISE")
                            .font(.custom("Helvetica Neue", size: geo.size.width * 0.04))
                            .fontWeight(.bold)
                        
                        Text("Thank you for downloading G-COVIDWISE. G-COVIDWISE will help Gettysburg College combat COVID-19 and keep its community safe.\n\n How It Works: Your device will exchange and receive Bluetooth tokens from other members of the community using G-COVIDWISE. These tokens are stored on your phone and cannot be accessed by anyone. Only if you test positive, your Health Authority may request you to use the release feature in the app to let them access stored tokens for the purpose of contact tracing.\n\nUsing G-COVIDWISE is completely voluntary.")
                            .font(.custom("Helvetica Neue", size: geo.size.width * 0.032))
                            .foregroundColor(Color(red: 0 / 255, green: 63 / 255, blue: 135 / 255))
                            .multilineTextAlignment(.center)
                            .padding(10)
                        
                        NavigationLink(destination: NavigationLazyView(enterAndVerifyEmail().navigationBarTitle("").navigationBarHidden(true))) {
                            Text("Do Great Work")
                                .fontWeight(.bold)
                                .font(.custom("Helvetica Neue", size: geo.size.width * 0.04))
                                .padding()
                                .foregroundColor(.white)
                                .background(LinearGradient(gradient: Gradient(colors: [Color(red: 232 / 255, green: 117 / 255, blue: 17 / 255), Color(red: 0 / 255, green: 63 / 255, blue: 135 / 255)]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(35)
                                .overlay(RoundedRectangle(cornerRadius: 35).stroke(Color.black, lineWidth: 3))
                        }
                    }
                }
            }.navigationBarHidden(true)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct enterAndVerifyEmail: View {
    @State private var email: String = ""
    
    @State private var generatedCode: String = ""
    @State private var userEnteredCode: String = ""
    
    @State var enteredValidEmail: Bool = false
    
    // length: length of the code to be generated.
    private func genRandomAlphaNumericCode(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< length).map{ _ in letters.randomElement()! })
    }
    
    var body: some View {
        if(enteredValidEmail == false) {
            NavigationView() {
                ZStack() {
                    Color(red: 232 / 255, green: 117 / 255, blue: 17 / 255).ignoresSafeArea()
                    
                    Image("0-without")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 400.0, height: 400.0)
                    
                    VStack(spacing: 10) {
                        TextField("Enter College Email...", text: $email, onEditingChanged: { (changed) in
                            print("Email onEditingChanged - \(changed)")
                            print("Entered email - \(email)")
                        })
                        .font(.headline)
                        .padding(10)
                        .foregroundColor(.black)
                        .background(Color.white)
                        .frame(width: 227, height: 40, alignment: .center)
                        .cornerRadius(35)
                        .overlay(RoundedRectangle(cornerRadius: 35).stroke(Color.black, lineWidth: 2))
                        
                        Button(action: {
                            self.generatedCode = genRandomAlphaNumericCode(length: 5)
                            print(generatedCode)
                            
                            let json: [String: Any] = ["id" : "196bcd9c-23c4-11eb-adc1-0242ac120002", "code" : generatedCode, "email" : email]
                            let jsonData = try? JSONSerialization.data(withJSONObject: json)
                            
                            let url = URL(string: "http://p4pproto.sites.gettysburg.edu/GBContactTracing/verify.php")!
                            var request = URLRequest(url: url)
                            request.httpMethod = "POST"
                            request.httpBody = jsonData
                            
                            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                                guard let data = data,
                                      let response = response as? HTTPURLResponse,
                                      error == nil else {                                            // check for fundamental networking error
                                    print("Error", error ?? "Unknown error")
                                    return
                                }
                                
                                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                                    print("statusCode should be 5xx, but is \(response.statusCode)")
                                    print("response = \(response)")
                                    return
                                }
                                
                                let responseString = String(data: data, encoding: .utf8)
                                print("responseString: \(responseString!)")
                            }
                            
                            task.resume()
                            self.enteredValidEmail.toggle()
                        }) {
                            enableDisableViewButton(isDisabled: self.email.count != 23, toDisplay: "Verify")
                                .padding()
                                .background(LinearGradient(gradient: Gradient(colors: [Color(red: 232 / 255, green: 117 / 255, blue: 17 / 255), Color(red: 0 / 255, green: 63 / 255, blue: 135 / 255)]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(35)
                                .overlay(RoundedRectangle(cornerRadius: 35).stroke(Color.black, lineWidth: 3))
                        }.disabled(self.email.count != 23)                                                // email must be in xxxxxx01@gettysburg.edu i.e 23 char long
                    }.offset(y: 10)
                }.navigationBarHidden(true)
            }.navigationViewStyle(StackNavigationViewStyle())
        }
        
        else {
            NavigationView() {
                ZStack() {
                    Color(red: 232 / 255, green: 117 / 255, blue: 17 / 255).ignoresSafeArea()
                    
                    Image("0-without")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 400.0, height: 400.0)
                    
                    VStack(spacing: 10) {
                        TextField("Enter Code...", text: $userEnteredCode, onEditingChanged: { (changed) in
                            print("Username onEditingChanged - \(changed)")
                            print("Entered code - \(userEnteredCode)")
                        })
                        .font(.headline)
                        .padding(10)
                        .foregroundColor(.black)
                        .background(Color.white)
                        .frame(width:200, height: 40, alignment: .center)
                        .overlay(Rectangle().stroke(Color.black, lineWidth: 3))
                        
                        NavigationLink(destination: NavigationLazyView(Home(email: email, wasDemoOnceCompleted: false).navigationBarTitle("").navigationBarHidden(true))) {
                            enableDisableViewButton(isDisabled: userEnteredCode != generatedCode, toDisplay: "Authenticate")
                                .padding()
                                .background(LinearGradient(gradient: Gradient(colors: [Color(red: 232 / 255, green: 117 / 255, blue: 17 / 255), Color(red: 0 / 255, green: 63 / 255, blue: 135 / 255)]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(35)
                                .overlay(RoundedRectangle(cornerRadius: 35).stroke(Color.black, lineWidth: 3))
                        }.disabled(userEnteredCode != generatedCode)
                
                        VStack() {
                            Button(action: {
                                self.email = ""
                                self.generatedCode = ""
                                self.userEnteredCode = ""
                                
                                self.enteredValidEmail.toggle() //switch back to first view
                            }) {
                                Text("Entered Incorrect Email?")
                                    .fontWeight(.bold)
                                    .font(.custom("Helvetica Neue", size: 25.0))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(LinearGradient(gradient: Gradient(colors: [Color(red: 232 / 255, green: 117 / 255, blue: 17 / 255), Color(red: 0 / 255, green: 63 / 255, blue: 135 / 255)]), startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(35)
                                    .overlay(RoundedRectangle(cornerRadius: 35).stroke(Color.black, lineWidth: 3))
                            }
                        }.offset(y: 360)
                    }.offset(y: 55).padding(.bottom, 17)
                }.navigationBarHidden(true)
            }.navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct Home: View {
    @ObservedObject private var centralController: CentralController
    @ObservedObject private var peripheralController: PeripheralController
    
    private var email: String
    
    private var isContactedByHA = ["NO", "YES"]
    @State private var contactedIndex = 0
    
    @State private var signatureName = ""
    
    init(email: String, wasDemoOnceCompleted: Bool = true) {
        print("wasDemoOnceCompleted", wasDemoOnceCompleted)
        print("Email from parameter:", email)
        
        self.email = email
        
        // Demo finished for the first time, update Defaults
        if(wasDemoOnceCompleted == false) {
            UserDefaults.standard.set(true, forKey: "DemoDone?")
            UserDefaults.standard.set(email, forKey: "Email")
        }
        
        centralController = CentralController()
        peripheralController = PeripheralController(email: self.email)
    }
    
    var body: some View {
        TabView {
            ZStack() {
                Color(red: 232 / 255, green: 117 / 255, blue: 17 / 255).opacity(0.95).ignoresSafeArea()
                
                Circle().fill(Color(red: 0 / 255, green: 63 / 255, blue: 135 / 255).opacity(1)).position(CGPoint(x: 775, y: 1200.0))
                Circle().fill(Color(red: 0 / 255, green: 63 / 255, blue: 135 / 255).opacity(1)).position(CGPoint(x: 35, y: -175))
                
                if centralController.isSwitchedOn {
                    VStack {
                        Image("k_copy-removebg")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 550.0)
                        
                        Text("Contact Tracing Active")
                            .font(.custom("Helvetica Neue", size: 20.0))
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    VStack {
                        Image("k_copy-removebg 2")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 550.0)
                        
                        Text("Bluetooth Switched Off!\n Contact Tracing Inactive")
                            .font(.custom("Helvetica Neue", size: 20.0))
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                }
            }.tabItem {
                Image(systemName: "house.fill")
                Text("Home").fontWeight(.bold).font(.custom("Helvetica Neue", size: 20.0))
            }
            
            ZStack() {
                Color(red: 232 / 255, green: 117 / 255, blue: 17 / 255).ignoresSafeArea()
                
                VStack() {
                    Image("0-without")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 300.0, height: 300.0)
                        .padding(.bottom, 30)
                    
                    Text("Using this feature of G-COVIDWISE, you can release your stored contacts to the Health Authority.")
                        .font(.custom("Helvetica Neue", size: 22.0))
                        .foregroundColor(Color(red: 0 / 255, green: 63 / 255, blue: 135 / 255))
                        .multilineTextAlignment(.center)
                        .padding(.leading, 25)
                        .padding(.trailing, 25)
                    
                    Text("\n\nYou must have been contacted by your Health Authority and ordered to do so!")
                        .fontWeight(.bold)
                        .font(.custom("Helvetica Neue", size: 22.0))
                        .foregroundColor(Color(red: 0 / 255, green: 63 / 255, blue: 135 / 255))
                        .multilineTextAlignment(.center)
                        .padding(.leading, 25)
                        .padding(.trailing, 25)
                  
                    Picker(selection: $contactedIndex, label: Text("")) {
                        ForEach(0 ..< isContactedByHA.count) {
                            Text(self.isContactedByHA[$0]).bold()
                        }
                    }
                    
                    Text("Release Close Contacts: \(isContactedByHA[contactedIndex])").bold()
                    
                    TextField("Enter Your Name As Signature:", text: $signatureName, onEditingChanged: { (changed) in
                        print("Name onEditingChanged - \(changed)")
                        print("Entered Name - \(signatureName)")
                    })
                    .font(.headline)
                    .padding(10)
                    .foregroundColor(.black)
                    .background(Color.white)
                    .frame(width: 275, height: 40, alignment: .center)
                    .overlay(Rectangle().stroke(Color.black, lineWidth: 3))
                    
                    Button(action: {
                        centralController.getDB().deleteOldData(currentUnixTime: Date().timeIntervalSince1970) // Assume didDiscover has not been called and database is not up to date. Update with call before releasing.
                        
                        let contacts = centralController.getDB().readAndReleaseAllData()
                        
                        let json: [String: Any] = ["id" : "196bcd9c-23c4-11eb-adc1-0242ac120002", "data" : contacts, "user" : self.email]
                        let jsonData = try? JSONSerialization.data(withJSONObject: json)
                        
                        let url = URL(string: "http://p4pproto.sites.gettysburg.edu/GBContactTracing/release.php")!
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        request.httpBody = jsonData
                        
                        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                            guard let data = data,
                                  let response = response as? HTTPURLResponse,
                                  error == nil else {                                            // check for fundamental networking error
                                print("Error", error ?? "Unknown error")
                                return
                            }
                            
                            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                                print("statusCode should be 5xx, but is \(response.statusCode)")
                                print("response = \(response)")
                                return
                            }
                            
                            let responseString = String(data: data, encoding: .utf8)
                            print("responseString: \(responseString!)")
                        }
                        
                        task.resume()
                        self.contactedIndex = 0
                        self.signatureName = ""
                    }) {
                        enableDisableViewButton(isDisabled: (contactedIndex == 0 || signatureName == ""), toDisplay: "Release")
                            .font(.custom("Helvetica Neue", size: 25.0))
                            .foregroundColor(.white)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color(red: 232 / 255, green: 117 / 255, blue: 17 / 255), Color(red: 0 / 255, green: 63 / 255, blue: 135 / 255)]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(35)
                            .overlay(RoundedRectangle(cornerRadius: 35).stroke(Color.black, lineWidth: 3))
                    }.disabled(contactedIndex == 0 || signatureName == "")
                }
            }.tabItem {
                Image(systemName: "exclamationmark.bubble.fill")
                Text("Release")
            }
            
            ZStack() {
                Color(red: 232 / 255, green: 117 / 255, blue: 17 / 255).ignoresSafeArea()
                
                VStack() {
                    Image("0-without")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 300.0, height: 300.0)
                        .padding(.bottom, 30)
                    
                    Text("Gettysburg Email In Use:")
                        .font(.custom("Helvetica Neue", size: 22.0))
                        .foregroundColor(Color(red: 0 / 255, green: 63 / 255, blue: 135 / 255))
                        .multilineTextAlignment(.center)
                    
                    Text(self.email)
                        .fontWeight(.bold)
                        .font(.custom("Helvetica Neue", size: 22.0))
                        .foregroundColor(Color(red: 0 / 255, green: 63 / 255, blue: 135 / 255))
                        .multilineTextAlignment(.center)
                    
                    Text("\nThank you for downloading G-COVIDWISE. G-COVIDWISE will help Gettysburg College combat COVID-19 and keep its community safe.\n\n How It Works: Your device will exchange and receive Bluetooth tokens from other members of the community using G-COVIDWISE. These tokens are stored on your phone and cannot be accessed by anyone. Only if you test positive, the Health Authority may request you to use the release feature in the app to let them access these tokens for the purpose of contact tracing.\n\nUsing G-COVIDWISE is completely voluntary.")
                        .font(.custom("Helvetica Neue", size: 22.0))
                        .foregroundColor(Color(red: 0 / 255, green: 63 / 255, blue: 135 / 255))
                        .multilineTextAlignment(.center)
                        .padding(.leading, 25)
                        .padding(.trailing, 25)
                        .padding(10)
                }
            }.tabItem {
                Image(systemName: "info.circle.fill")
                Text("Info")
            }
        }
    }
}

// Prevents initalization of the View before the actual call
struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}

// Customizes the button based on if it is enabled or disabled
func enableDisableViewButton(isDisabled: Bool, toDisplay: String) -> some View {
    if(isDisabled == false) {
        return Text(toDisplay)
            .fontWeight(.bold)
            .font(.custom("Helvetica Neue", size: 25.0))
            .foregroundColor(.white)
    }
    
    else {
        return Text(toDisplay)
            .fontWeight(.bold)
            .font(.custom("Helvetica Neue", size: 25.0))
            .foregroundColor(.gray)
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

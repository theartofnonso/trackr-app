//
//  MonitorView.swift
//  TRKRWear Watch App
//
//  Created by Nonso Emmanuel Biose on 15/04/2024.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var watchConnectivity: WatchConnectivity = WatchConnectivity()
    
    @State var hasHealthKitStore: Bool = false
    
    @State var requestingHealthKitStoreAccess: Bool = false
    
    @State private var currentDate = Date.now
    
    @State private var startDate = Date.now
    
    @State private var setStartDate = Date.now
    
    @State private var setStarted: Bool = false
    
    let heartRateMonitor: HeartRateMonitor = HeartRateMonitor()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [AppColor.sapphireLight, AppColor.sapphireDark], startPoint: UnitPoint.top, endPoint: UnitPoint.bottom).edgesIgnoringSafeArea(Edge.Set.all).onAppear {
                Task(operation: {
                    await heartRateMonitor.checkAuthorization { result in
                        hasHealthKitStore = result
                    }
                })
            }.onReceive(watchConnectivity.$isAnalysing, perform: { _ in
                setStarted = watchConnectivity.isAnalysing
            })
            
            if hasHealthKitStore {
                VStack(alignment: .leading, content: {
                    Spacer()
                    Text("\(formatElapsedTime(time: Int(currentDate.timeIntervalSince(startDate))))")
                        .onReceive(timer) { input in
                            currentDate = input
                        }.font(.system(size: 24, weight: .bold)).foregroundColor(AppColor.vibrantGreen)
                    Spacer().frame(height: 3)
                    HStack(alignment: .bottom, content: {
                        
                        Text(setStarted ? "Analysing" : watchConnectivity.sessionName).font(.system(size: 16, weight: .regular)).foregroundStyle(watchConnectivity.sessionName == Constants.NO_SESSION ? .gray : .white)
                        Spacer()
                    })
                    Spacer().frame(height: 10)
                    Image(systemName: setStarted ? "stop.circle" : "play.circle.fill")
                        .font(.system(size: 40)).foregroundStyle(setStarted ? .gray : AppColor.vibrantGreen)
                        .onTapGesture(perform: {
                            if watchConnectivity.sessionName != Constants.NO_SESSION {
                                setStarted = !setStarted
                                setStartDate = Date.now
                                // Start accelerometer
                            }
                        })
                }).padding(Edge.Set.horizontal, 12)
                
            } else {
                VStack(alignment: .leading, content: {
                    Text("We need to read your heart rate to calculate workout your intensity.").font(.system(size: 12, weight: .light))
                    Spacer().frame(height: 5)
                    Button(action: {
                        Task(operation: {
                            await heartRateMonitor.requestAuthorization { result in
                                hasHealthKitStore = result
                            }
                        })
                    }, label: {
                        
                        Text("Grant Access")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.black)
                    })
                    .frame(width: 120, height: 20)
                    .background(AppColor.vibrantGreen)
                    .cornerRadius(3)
                }).padding(Edge.Set.horizontal, 12)
            }
            
            if requestingHealthKitStoreAccess {
                ZStack {
                    Color.black.opacity(0.6)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView()
                }
            }
            
        }
    }
    
    func formatElapsedTime(time: Int) -> String {
        let hours = twoDigits(time / 3600)
        let minutes = twoDigits((time % 3600) / 60)
        let seconds = twoDigits(time % 60)
        return "\(hours):\(minutes):\(seconds)";
        
    }
    
    func twoDigits(_ n: Int) -> String {
        return String(format: "%02d", n)
    }
    
}

#Preview {
    ContentView()
}

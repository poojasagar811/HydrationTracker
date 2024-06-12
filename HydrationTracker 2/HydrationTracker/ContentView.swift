//
//  ContentView.swift
//  HydrationTracker
//
//  Created by Crescendo Worldwide India on 11/06/24.
//

import SwiftUI
import CoreData
//import RiveRuntime


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var amountText = ""
        @State private var selectedUnit = 0
        @State private var target: Double = 2.0 // Default target set to 2.0 L
        @State private var consumption: Double = 0.0 // Consumed water amount
        @State private var showListView = false // State to control pop-up presentation
        
    @FetchRequest(
           sortDescriptors: [NSSortDescriptor(keyPath: \HydrationLog.date, ascending: false)],
           predicate: NSPredicate(format: "amount > 0"),
           animation: .default)
       private var hydrationLogs: FetchedResults<HydrationLog>
       
       var body: some View {
           NavigationView {
               ZStack {
                   // Background Color
                   Color.blue.opacity(0.3).edgesIgnoringSafeArea(.all)
                   
                   WaterView(level: consumption / target)
                       .edgesIgnoringSafeArea(.all)
                       .overlay(BlurView().edgesIgnoringSafeArea(.all))
                   
                   VStack {
                       Text("Hydration Tracker")
                           .padding(.top, 50)
                           .fontWeight(.bold)
                           .foregroundColor(.black)
                       
                       VStack(spacing: 8) {
                           TextField("Enter amount (L)", text: $amountText)
                               .customTextField(image: Image(systemName: "water.waves"))
                               .padding(.horizontal)
                               .foregroundColor(.blue)
                           
                           Picker(selection: $selectedUnit, label: Text("Unit")) {
                               Image("glass-of-water (3)")
                                   .tag(0)
                               Image("icons8-plastic-30")
                                   .padding()
                                   .tag(1)
                           }
                           .pickerStyle(SegmentedPickerStyle())
                           .padding(.horizontal)
                           .frame(maxWidth: 200) // Set fixed width for the picker
                           .foregroundColor(.blue)
                       }
                       .padding()
                       Button {
                           addLog()
                       } label: {
                           HStack {
                               Text("Log")
                                   .customFont(.headline)
                                   .padding(10)
                                   .frame(maxWidth: 150)
                                   .background(Color("Secoundary"))
                                   .foregroundColor(.white)
                                   .mask(RoundedCorner(radius: 20, corners: [.topRight, .bottomLeft, .bottomRight]))
                                   .mask(RoundedRectangle(cornerRadius: 8))
                                   .shadow(color: Color("Secoundary").opacity(0.5), radius: 5, x: 0, y: 10)
                           }
                       }
                       .padding(5)
                      
                       VStack {
                          
                           Text("Daily Target")
                               .padding()
                               .font(.system(.title2, design: .rounded))
                               .shadow(radius: 5)
                           
                           CircularSlider(value: $target)
                               .frame(width: 150, height: 150)
                               .padding()
                       }
                       
                       Text("Total Intake Today: \(String(format: "%.1f", totalAmountToday())) L")
                           .padding()
                           .font(.system(.title2, design: .rounded))
                           .shadow(radius: 5)
                       
                       Spacer()
                       
                       Button(action: {
                           showListView.toggle()
                       }) {
                           Image(systemName: "chevron.up")
                               .resizable()
                               .frame(width: 30, height: 15)
                               .foregroundColor(Color("Primary"))
                               .padding()
                       }
                   }
                   .foregroundColor(.blue)
                   .background(Color.clear)
                   
                   if showListView {
                       HydrationListView(show: $showListView)
                           .environment(\.managedObjectContext, viewContext)
                           .transition(.move(edge: .bottom))
                           .animation(.spring())
                   }
               }
               .accentColor(.blue)
               .onAppear {
                   consumption = totalAmountToday()
               }
               .onReceive(hydrationLogs.publisher.collect()) { _ in
                   consumption = totalAmountToday()
               }
           }
       }
       
       private func addLog() {
           guard let amount = Double(amountText), amount > 0 else {
               return
           }
           
           let newLog = HydrationLog(context: viewContext)
           newLog.amount = amount
           newLog.unit = selectedUnit == 0 ? "Glass" : "Bottle"
           newLog.date = Date()
           
           do {
               try viewContext.save()
           } catch {
               let nsError = error as NSError
               fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
           }
           
           amountText = ""
       }
       
       private func totalAmountToday() -> Double {
           let calendar = Calendar.current
           let today = calendar.startOfDay(for: Date())
           let predicate = NSPredicate(format: "date >= %@", today as NSDate)
           
           let fetchRequest: NSFetchRequest<HydrationLog> = HydrationLog.fetchRequest()
           fetchRequest.predicate = predicate
           
           do {
               let logs = try viewContext.fetch(fetchRequest)
               return logs.reduce(0) { $0 + $1.amount }
           } catch {
               let nsError = error as NSError
               fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
           }
       }
   }

   struct CircularSlider: View {
       @Binding var value: Double
       @State private var dragAmount: CGSize = .zero

       var body: some View {
           let dragGesture = DragGesture()
               .onChanged { value in
                   dragAmount = value.translation
                   updateValueFromDrag()
               }
               .onEnded { _ in
                   dragAmount = .zero
               }

           return ZStack {
               Circle()
                   .stroke(Color.blue, lineWidth: 20)
                   .overlay(Circle().stroke(Color.white, lineWidth: 5))
               Text("\(String(format: "%.1f", value)) L")
                   .font(.title)
                   .fontWeight(.bold)
                   .foregroundColor(.blue)
               Thumb()
                   .offset(x: 80, y: 0)
                   .rotationEffect(.degrees(-90))
                   .rotationEffect(.degrees((value / 10) * 360))
                   .gesture(dragGesture)
           }
       }
       
       private func updateValueFromDrag() {
           let radius = 100.0
           let vector = CGVector(dx: dragAmount.width, dy: dragAmount.height)
           let angle = atan2(vector.dy, vector.dx) + .pi / 2 // Adjusting for 12 o'clock position
           let normalizedAngle = (angle < 0 ? angle + 2 * .pi : angle) / (2 * .pi)
           let newValue = max(min(normalizedAngle * 10, 10), 0)
           value = newValue
       }
   }

   struct Thumb: View {
       var body: some View {
           ZStack {
               Circle()
                   .fill(Color.white)
                   .frame(width: 20, height: 20)
               Circle()
                   .stroke(Color.blue, lineWidth: 5)
                   .frame(width: 20, height: 20)
           }
       }
   }

   struct WaterView: View {
       var level: Double
       
       var body: some View {
           GeometryReader { geometry in
               ZStack(alignment: .bottom) {
                   Color.blue.opacity(0.3)
                   Color.blue
                       .frame(width: geometry.size.width, height: max(0, geometry.size.height * CGFloat(level)))
                       .animation(.easeInOut(duration: 0.5))
               }
           }
       }
   }

   struct BlurView: UIViewRepresentable {
       func makeUIView(context: Context) -> UIVisualEffectView {
           let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
           return view
       }
       
       func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
   }

   struct ContentView_Previews: PreviewProvider {
       static var previews: some View {
           ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
       }
    }

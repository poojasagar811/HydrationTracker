//
//  HydrationListView.swift
//  HydrationTracker
//
//  Created by Crescendo Worldwide India on 12/06/24.
//

import SwiftUI

struct HydrationListView: View {
    @Environment(\.managedObjectContext) private var viewContext
       @FetchRequest(
           sortDescriptors: [NSSortDescriptor(keyPath: \HydrationLog.date, ascending: false)],
           predicate: NSPredicate(format: "amount > 0"),
           animation: .default)
       private var hydrationLogs: FetchedResults<HydrationLog>
       
       @Binding var show: Bool

       var body: some View {
           VStack(spacing: 30) {
               Text("Hydration Logs")
                   //.customFont(.title3)
                   .fontWeight(.semibold)
                   .foregroundColor(Color("Primary"))
                   .shadow(radius: 20)
                   
               List {
                   ForEach(hydrationLogs, id: \.self) { log in
                       Text("Amount: \(String(format: "%.1f", log.amount)) L (\(log.unit ?? "Unit"))")
                           .foregroundColor(.primary)
                           .padding()
                   }
                   .onDelete(perform: deleteLog)
               }
               .listStyle(PlainListStyle())
               
               Button(action: {
                   withAnimation {
                       show.toggle()
                   }
               }) {
                   HStack {
                       Image(systemName: "chevron.down")
                           .foregroundColor(Color("Primary"))
                       Text("Close")
                           .customFont(.headline)
                           .foregroundColor(Color("Primary"))
                   }
                   .largeButton()
               }
           }
           .padding(40)
           .background(.regularMaterial)
           .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
           .shadow(color: Color("Shadow").opacity(0.3), radius: 5, x: 0, y: 3)
           .shadow(color: Color("Shadow").opacity(0.3), radius: 30, x: 0, y: 30)
           .overlay(
               RoundedRectangle(cornerRadius: 20, style: .continuous)
                   .stroke(.linearGradient(colors: [.white.opacity(0.8), .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
           )
           .padding()
       }
       
       private func deleteLog(offsets: IndexSet) {
           withAnimation {
               offsets.map { hydrationLogs[$0] }.forEach(viewContext.delete)
               
               do {
                   try viewContext.save()
               } catch {
                   let nsError = error as NSError
                   fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
               }
           }
       }
   }

   struct HydrationListView_Previews: PreviewProvider {
       static var previews: some View {
           HydrationListView(show: .constant(true))
               .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
       }
}

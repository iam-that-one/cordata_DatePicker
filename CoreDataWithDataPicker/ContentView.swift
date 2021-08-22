//
//  ContentView.swift
//  CoreDataWithDataPicker
//
//  Created by Abdullah Alnutayfi on 21/08/2021.
//

import SwiftUI

struct ContentView: View {
  
  @State var isEditing = false
  @State var showSeet = false
  @StateObject var vm = ViewModel()
  @State var currentNote = Date()
  @State var id = UUID()
 
    @FetchRequest(
        // To sort notes by date
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.date, ascending: true)],
        animation: .default)
     var notes : FetchedResults<Note> // Fetch notes

    var body: some View {
      
        VStack{
            DatePicker(
                 "Start Date",
                selection: $vm.date,
                displayedComponents: [.date,.hourAndMinute]
            ).datePickerStyle(WheelDatePickerStyle())
            
            
            TextField(" type your note here ...", text: $vm.note)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Text(vm.dateFormatter.string(from: vm.date))
            Button("save"){
                vm.save()
            }
            List{
                ForEach(notes){ note in
                    VStack(alignment: .leading){
                        
                        Button(action:{
                            currentNote = note.date!
                          //
                            vm.editedNote = note.note ?? ""
                            vm.editedDate = note.date!
                            showSeet.toggle()
                            isEditing = true
                             id = note.id!
                            
                        }){
                        Text(note.note ?? "")
                        }
                        .sheet(isPresented: $showSeet){
                            EditView(note: note, showSeet: $showSeet, date:  vm.editedDate, editeNote: vm.editedNote, id: $id)
                                .environment(\.managedObjectContext, vm.viewContext)
                        }
                        Text("\(note.date!, formatter: vm.dateFormatter)")
                        
                    }
                       
                
            }.onDelete(perform: removeNote)
            }
            Spacer()
        }.padding()
        .ignoresSafeArea()
        
        
    }


  
    func removeNote(offsets: IndexSet) {
       withAnimation {
           offsets.map { notes[$0] }.forEach(vm.viewContext.delete)
           
           do {
               try vm.viewContext.save()
               //
           } catch {
               let nsError = error as NSError
               fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
           }
       }
   }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class ViewModel: ObservableObject{
    @Published var viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @Published  var date = Date()
    @Published var note = ""
    @Published var editedNote = ""
    @Published var editedDate = Date()
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E, d MMM y"
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
       // formatter.locale = Locale(identifier: "en_sa")
        return formatter
    }()
    
    func save(){
        let newNote = Note(context: viewContext)
        newNote.note = note
        newNote.date = date
        newNote.id = UUID()
        do{
            try viewContext.save()
        }catch{print("Error in creating new note")}
    }
    func updateNote(note: Note) {
        let newNote = editedNote
        let newDate = editedDate
        viewContext.performAndWait {
            note.note = newNote
            note.date = newDate
            
            try? viewContext.save()
            
        }
        }

 
}

struct EditView: View {
    @StateObject var vm = ViewModel()
     @State var note : Note
    @Binding var showSeet : Bool
    @State var date : Date
    @State var editeNote : String
    @Binding var id : UUID
    var body: some View{
        VStack{
           
            TextEditor(text: $vm.editedNote)
                .frame(width: UIScreen.main.bounds.width - 100, height: 100)
              
                
                .overlay(RoundedRectangle(cornerRadius: 5).stroke())
                .onAppear{
                    vm.editedNote = editeNote
                    vm.editedDate = date
               
                }
            DatePicker(
                 "Start Date",
                selection: $vm.editedDate,
                displayedComponents: [.date,.hourAndMinute]
            )//.environment(\.locale, Locale.init(identifier: "en_us"))
            
            .datePickerStyle(WheelDatePickerStyle())
            .frame(width: 200)
           Spacer()
            HStack{
                Button(action:{
                    vm.updateNote(note: note)
                  //  vm.editedNote = ""
                    
                    showSeet.toggle()
                }){
                    Text("update ...")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
            }
        
        }.padding()
    }
}

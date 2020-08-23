//
//  ContentView.swift
//  WordScramble
//
//  Created by Design Work on 2020-08-22.
//  Copyright © 2020 Ling Lu. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var showingAlert = false
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var score = 0
    
    
    
    let nums = [1,2,4,6,3,3]
    var body: some View {
        NavigationView{
            ZStack{
//                Color(.red).edgesIgnoringSafeArea(.all)
                VStack{
                    TextField("Enter your new word", text: $newWord, onCommit: addNewWord).textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .autocapitalization(.none)
                    List(usedWords, id:\.self){
                        Image(systemName: "\($0.count).circle")
                        Text($0)
                    }
                    
                    
                }.navigationBarTitle(rootWord)
                    .navigationBarItems(leading: Text("Score: \(score)"), trailing: Button(action:{
                        self.usedWords = [String]()
                        self.startGame()
                    }){
                        Image(systemName: "arrow.clockwise")
                    })
                    .onAppear(perform: startGame)
                    .alert(isPresented: $showingAlert){
                        Alert(title: Text(errorTitle), message: Text(errorMessage))
                }
            }
        }

    }
    func wordError(title:String, message:String){
        errorTitle = title
        errorMessage = message
        showingAlert = true
        newWord=""
    }
    func isWord(word:String) -> Bool{
        if word.count < 3 || word == rootWord{
            return false
        }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
    
        return misspelledRange.location == NSNotFound
    }
    func isPossible(word:String) -> Bool{
        var copy = rootWord
        for letter in word{
            if let pos = copy.firstIndex(of: letter){
                copy.remove(at: pos)
            } else{
                return false
            }
        }
        return true
    }
    func isOriginal(word:String) -> Bool {
        return !usedWords.contains(word)
    }
    func addNewWord(){
        score += newWord.count
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if answer.count == 0{
            return
        }
        
        guard isOriginal(word: answer) else{
            wordError(title:"Invalid word", message: "You already used \(answer)")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "No can do", message:"You cannot spell '\(answer)' from '\(self.rootWord)'")
            return
        }
        
        guard isWord(word: answer) else{
            wordError(title: "Can't use that word", message: "Try again")
            return
        }
        
        
        
        usedWords.insert(answer, at:0)
        newWord=""
        
    }
    func startGame(){
//        UITableViewCell.appearance().backgroundColor = .green
//        UITableView.appearance().backgroundColor = .green
        score = 0
        if let fileURL = Bundle.main.url(forResource: "start", withExtension: ".txt"){
            if let startString = try? String(contentsOf: fileURL){
                let allWords = startString.components(separatedBy: "\n")
                
                rootWord = allWords.randomElement() ?? "silkworm"
                return
                
            }
        }
        fatalError("Could not load starting assets")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

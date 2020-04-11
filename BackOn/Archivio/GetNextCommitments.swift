//
//  GetNextCommitments.swift
//  BackOn
//
//  Created by Vincenzo Riccio on 31/03/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

/*
 

 //  Questo metodo da un array di commitment restituisce il più imminente assumendo che:
 func getNextCommitment(dataDictionary: [Int:Task]) -> Task? {
     if(dataDictionary.count == 0){
         return nil
     }
     let data = Array(dataDictionary.values)
     var toReturn = data[0]
     for c in data {
         if toReturn.date.compare(c.date) == ComparisonResult.orderedDescending {
             toReturn = c
         }
     }
     return toReturn
 }

 func getNextNotificableCommitment(dataDictionary: [Int:Task]) -> Task? {
     if(dataDictionary.count == 0){
         return nil
     }
     var data = Array(dataDictionary.values)
     var toReturn: Task?
     repeat{
         let i = data.removeFirst()
         if(i.timeRemaining() > TimeInterval(30*60)){
             toReturn = toReturn == nil ? i : toReturn
             if(toReturn!.timeRemaining() > i.timeRemaining()){
                 toReturn = i
             }
         }} while data.count>0
     return toReturn
 }

 func getNextFive(dataDictionary: [Int: Task]) -> [Task]{
     let data = Array(dataDictionary.values)
     var toReturn: [Task] = [data[0]]
     //   Mi serve a sapere se non ho ancora inserito i primi 5 elementi ordinatamente
     var last = 0
     
     for i in 1...data.count {
         for j in stride(from: last < 5 ? last : 4, through: 0, by: -1) {
             if toReturn[j].date.compare(data[i].date) == ComparisonResult.orderedDescending{
                 let toShift = toReturn[j]
                 toReturn[j] = data[i]
                 toReturn[j + 1] = toShift
             } else {
                 if last < 5 {
                     toReturn[last + 1] = data[i]
                 }
             }
             last += 1
         }
     }
     return toReturn
 }
 
 */

//ALGORITHM FOR GENERATING PLAYLIST

import UIKit

//RANDOM NUMBER GENERATOR
func random(x: Int) -> Int {
    return Int(arc4random_uniform(UInt32(x)))
}

var lou = ["Lou\t\t1", "Lou\t\t2", "Lou\t\t3", "Lou\t\t4", "Lou\t\t5", "Lou\t\t6"]
var nick = ["Nick\t1", "Nick\t2", "Nick\t3", "Nick\t4"]
var chantal = ["Chantal\t1", "Chantal\t2", "Chantal\t3", "Chantal\t4", "Chantal\t5", "Chantal\t6", "Chantal\t7", "Chantal\t8", "Chantal\t9"]
var caden = ["Caden\t1", "Caden\t2", "Caden\t3", "Caden\t4", "Caden\t5", "Caden\t6", "Caden\t7"]
var users = [lou, nick, chantal, caden]
var playlist = [String]()
var max = users[0].count

//FIND LONGEST PLAYLIST
for index in 1..<users.count {
    if(users[index].count > max) {
        max = users[index].count
    }
}


var count = 0
var s = 0

//LOOP THROUGH UNTIL ALL USER PLAYLIST ARRAYS ARE EMPTY
for _ in 0..<max {
        while(count < users.count) {
            
            if(users[count].count != 0) {
                let length = users[count].count
                let randomNum = random(x: length)
                
                playlist.append(users[count][randomNum])
                users[count].remove(at: randomNum)
                
                count += 1
            } else {
                count += 1
            }
        }
    
        count = 0
}

//PRINT FINAL PLAYLIST
for y in 0..<playlist.count {
    print("\(y + 1).\t\(playlist[y])")
}













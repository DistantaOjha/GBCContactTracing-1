//
//  Database.swift
//  Contact_Tracing
//
//  Created by Haider Tariq on 12/7/20.
//

import Foundation
import SQLite3

class DBHelper {
    
    private let dbPath: String = "TracedContacts.sqlite"
    private var db: OpaquePointer?
    
    private final let MAX_TIME_DIFF = 1209600  // 14 days = 1209600 Seconds
    
    init() {
        db = openDatabase()
        createTable()
    }
    
    func openDatabase() -> OpaquePointer? {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error: Opening Database")
            return nil
        }
        
        else {
            print("Successfully opened connection to database at \(dbPath)")
            return db
        }
    }
    
    func createTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS Contacts (ID VARCHAR(256) NOT NULL, startTime VARCHAR(256) NOT NULL, endTime VARCHAR(256) NOT NULL, avgDistance VARCHAR(256) NOT NULL, PRIMARY KEY(ID, startTime));" // Primary Key: ID, startTime
        var createTableStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Contacts table created")
            } else {
                print("Error: Contacts table could not be created")
            }
        } else {
            print("Error: CREATE TABLE statement could not be prepared.")
        }
        
        sqlite3_finalize(createTableStatement)
    }
    
    // Inserts a nearby user after MIN_EXPOSURE_TIME has passed.
    func insert(ID:String, startTime:Double, endTime:Double, avgDistance:Double)
    {
        let queryStatementString = "SELECT ID FROM Contacts WHERE ID = ? AND startTime = ?"
        var queryStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK //check if row returned
        {
            sqlite3_bind_text(queryStatement, 1, (ID as NSString).utf8String, -1, nil)
            sqlite3_bind_double(queryStatement, 2, startTime)
            
            let result = sqlite3_step(queryStatement)
            print("Result Code:", result)
            
            if result == SQLITE_ROW //Code: 100
            {
                let countStatementString = "SELECT Count(ID) FROM Contacts WHERE ID = ? AND startTime = ?"
                var countStatement: OpaquePointer? = nil
                
                var count = -1
                
                if sqlite3_prepare_v2(self.db, countStatementString, -1, &countStatement, nil) == SQLITE_OK
                {
                    sqlite3_bind_text(countStatement, 1, (ID as NSString).utf8String, -1, nil)
                    sqlite3_bind_double(countStatement, 2, startTime)
                    
                    while(sqlite3_step(countStatement) == SQLITE_ROW) {
                        count = Int(sqlite3_column_int(countStatement, 0))
                    }
                    
                    print("Count:", count) // Ensure only one row is returned based on the primary key query
                    
                    if count == 1
                    {
                        let insertStatementString = "UPDATE Contacts SET endTime = ?, avgDistance = ? WHERE ID = ? AND startTime = ?"
                        var insertStatement: OpaquePointer? = nil
                        
                        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                            sqlite3_bind_double(insertStatement, 1, endTime)
                            sqlite3_bind_double(insertStatement, 2, avgDistance)
                            sqlite3_bind_text(insertStatement, 3, (ID as NSString).utf8String, -1, nil)
                            sqlite3_bind_double(insertStatement, 4, startTime)
                            
                            if sqlite3_step(insertStatement) == SQLITE_DONE {
                                print("Successfully updated", ID)
                            }
                            
                            else {
                                print("Error: Couldn't update", ID)
                            }
                        }
                        
                        else {
                            print("Error: Update statement could not be prepared.")
                        }
                        
                        sqlite3_finalize(insertStatement)
                    }
                    
                    else {
                        print("Error: Count is not 1: Count:", count)
                    }
                }
                
                else {
                    print("Error: (SELECT * FROM TracedContacts) could not be prepared.")
                }
                
                sqlite3_finalize(countStatement)
            }
            
            else if result == SQLITE_DONE //Code: 101 //check if no row returned(is empty)
            {
                let insertStatementString = "INSERT INTO Contacts (ID, startTime, endTime, avgDistance) VALUES (?, ?, ?, ?);"
                var insertStatement: OpaquePointer? = nil
                
                if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                    sqlite3_bind_text(insertStatement, 1, (ID as NSString).utf8String, -1, nil)
                    sqlite3_bind_double(insertStatement, 2, startTime)
                    sqlite3_bind_double(insertStatement, 3, endTime)
                    sqlite3_bind_double(insertStatement, 4, avgDistance)
                    
                    if sqlite3_step(insertStatement) == SQLITE_DONE {
                        print("Successfully inserted newly found", ID, "after 10 sec passed")
                    }
                    
                    else {
                        print("Error: Couldn't insert newly found", ID, "after 10 sec passed")
                    }
                }
                
                else {
                    print("Error: INSERT statement could not be prepared for", ID, "after 10 sec passed")
                }
                
                sqlite3_finalize(insertStatement)
            }
            
            else {
                print("Error:")
                print(sqlite3_step(queryStatement))
            }
        }
        
        else {
            print("Error: Could not prepare top ID and StartTime statement")
        }
        
        sqlite3_finalize(queryStatement)
        
        print("\n")
        let queryStatementString2 = "SELECT * FROM Contacts;"
        var queryStatement2: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryStatementString2, -1, &queryStatement2, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement2) == SQLITE_ROW {
                let ID = String(describing: String(cString: sqlite3_column_text(queryStatement2, 0)))
                let startTime = sqlite3_column_double(queryStatement2, 1)
                let endTime = sqlite3_column_double(queryStatement2, 2)
                let avgDistance = sqlite3_column_double(queryStatement2, 3)
                print("Query Result:")
                print("\(ID) | \(startTime) | \(endTime) | \(avgDistance)")
            }
        } else {
            print("LAST SELECT * statement could not be prepared")
        }
        
        sqlite3_finalize(queryStatement2)
        print("\n")
    }
    
    // Deletes 14th day old data.
    func deleteOldData(currentUnixTime: Double) {
        let deleteStatementString = "DELETE FROM Contacts WHERE ? - endTime >= \(MAX_TIME_DIFF)" // If the row is older than 14 days.
        var deleteStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_double(deleteStatement, 1, currentUnixTime)
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                if sqlite3_changes(db) > 0 {
                    print("Successfully deleted row(s)")
                }
                else {
                    print("No delete needed")
                }
            } else {
                print("Error: Couldn't delete")
            }
        } else {
            print("Error: Delete statement could not be prepared.")
        }
        
        sqlite3_finalize(deleteStatement)
        
        print("\n")
        let queryStatementString = "SELECT * FROM Contacts;"
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let ID = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                let startTime = sqlite3_column_double(queryStatement, 1)
                let endTime = sqlite3_column_double(queryStatement, 2)
                let avgDistance = sqlite3_column_double(queryStatement, 3)
                print("Delete Method Query Result:")
                print("\(ID) | \(startTime) | \(endTime) | \(avgDistance)")
            }
        } else {
            print("LAST SELECT * statement could not be prepared")
        }
        
        sqlite3_finalize(queryStatement)
    }
    
    // Relase Function: Read from the database and make a HTML form to be sent.
    func readAndReleaseAllData() -> String {
        let queryStatementString = "SELECT * FROM Contacts;"
        
        var HTMLresult = "<table>"
        
        HTMLresult.append("<tr>")
        HTMLresult.append("<th>ID</th>")
        HTMLresult.append("<th>Interaction START Time</th>")
        HTMLresult.append("<th>Interaction END Time</th>")
        HTMLresult.append("<th> Duration </th>")
        HTMLresult.append("<th>Average Distance b/w Start & End Time</th>")
        HTMLresult.append("</tr>")
        
        var queryStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                HTMLresult.append("<tr>")
                HTMLresult.append("<td>\(String(describing: String(cString: sqlite3_column_text(queryStatement, 0))) + "@gettysburg.edu")</td>") //ID
                HTMLresult.append("<td>\(DateFormatter.localizedString(from: Date(timeIntervalSince1970: sqlite3_column_double(queryStatement, 1)), dateStyle: .long, timeStyle: .long)) </td>") //formart startTime
                HTMLresult.append("<td>\(DateFormatter.localizedString(from: Date(timeIntervalSince1970: sqlite3_column_double(queryStatement, 2)), dateStyle: .long, timeStyle: .long))</td>")
                
                //format time for duration
                let hours = Int(sqlite3_column_double(queryStatement, 2) - sqlite3_column_double(queryStatement, 1)) / 3600
                let minutes = Int(sqlite3_column_double(queryStatement, 2) - sqlite3_column_double(queryStatement, 1)) / 60 % 60
                let seconds = Int(sqlite3_column_double(queryStatement, 2) - sqlite3_column_double(queryStatement, 1)) % 60
               
                HTMLresult.append("<td>\(String(format:"%02i:%02i:%02i", hours, minutes, seconds))</td>")
                HTMLresult.append("<td>\(Double(round(sqlite3_column_double(queryStatement, 3)*1000))/1000)</td>")
                HTMLresult.append("</tr>")
            }
        } else {
            print("Error: Couldn't prepare readAllData() statement")
        }
        
        sqlite3_finalize(queryStatement)
        
        HTMLresult.append("</table>")
        
        return HTMLresult
    }
}

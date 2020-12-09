# GBCContactTracing

This project is a prototype iOS application for COVID-19 contact tracing, made in Gettysburg College and is part of the CS440 senior capstone course in Gettysburg College. 

**iOS level: 13.0+ \
Xcode: 11.0+ \
macOS: 10.15+ (if SwiftUI preview desired).**

The application implements Bluetooth Low Energy (BLE) technology to broadcast the college email address (a user's ID), which should be verified in the intro-screens, as the token. This token is exchanged between devices via bluetooth, while keeping track of the interaction time, distance, and the token. Through this, the application obtains the following information after post-processing of the raw-data and stores it in the **SQLite Database**. The standard iOS bluetooth library, Core Bluetooth, is used for the central and peripheral roles.
 
| Information      | Description |
| ----------- | ----------- |
| ID      | The user's verified college email. |
| startTime   | The interaction's start time. |
| endTime   | The interaction's start time. |
| avgDistance   | Average distance over the interaction in feet. |

The SQLite database has one table that captures this exact information. The ID and startTime (Unix time) is the primary key. Following is the specification and an example: 

Database name: **TracedContacts.sqlite**
Table Name: **Contacts**

| ID | startTime | endTime | avgDistance
| ----------- | ----------- | ----------- |  ----------- |
| example@email.com |  1607125639912 |  1607125732018 | 3.791 |

The application also stores two user defaults. One as a string under the key **Email** and second as a boolean under the name **DemoDone?**. 

We have the following the following parameters in the following files to tune the way application works:

File : **CentralController.swift**

| Field      | Description |
| ----------- | ----------- |
| MIN_EXPOSURE_TIME | Minimum time for an interaction to be considered as a sufficient exposure interaction. |
| DISAPPEAR_TIME   | Minimum time of dissappearnce of a device to be counted as end of interaction. |
| MIN_EXPOSURE_DISTANCE   | Minimum distance for an interaction to be considered as a sufficient exposure interaction.* |

File : **Database.swift**

| MAX_TIME_DIFF   | Time for which if the difference of endTime and current time is greater than or equal it, then the exposure record is deleted from the database. |

_*It is important to note that even if the average distance at the end of interaction is greater than **MIN_EXPOSURE_DISTANCE**, if there's any situation where average interaction distance is less than **MIN_EXPOSURE_DISTANCE** after **MIN_EXPOSURE_TIME** has passed, then the interaction will still be counted as an exposure._

The application also has a server but it merely accepts post request from the application in order to send the following respective infromation. The server has the following end points:

| End Points   | File  | Description |
| ----------- | -----------|----------- |
| verificationServerEndPoint | ContentView.swift | php endpoint that accepts post request to send a verification email. |
| releaseServerEndpoint | ContentView.swift | php endpoint that accepts post request to send data to the health authority. |


TODO: Background running permission completion.

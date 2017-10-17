# FantasyBasketball_iOS
## Intro
This app accesses basketball player data from a variety of online sources including [espn.com](espn.com), [rotoworld.com](rotoworld.com), [nba.com](nba.com), and more for the purpose of tracking and evaluating NBA player performance. This app has almost all of the features of the official ESPN fantasy app and also includes additinal player discoery / insight features such as advanced player news and metrics. 

In addition, this app tracks advanced metrics such as fantasy team win percentage based on players' historical fantasy performances and p-score probability aggregations. These probabilities update by the second as new stats come in and each real-life basketball game progresses. This system also takes into account injuries, including day-to-day and out statuses.

Finally, Core Data is selectivly used to store user settings as well as custom player watch lists and to speed up app performance in general.

## Installation
#### League setup
If you would like to track your own fantasy team's performance, make sure your league is an ESPN fantasy basketball league with default "custom" scoring settings. Also, it is suggested that your teams consist of between 10 and 15 players to ensure optimal performance.

#### Cocoapods
Make sure you have [CocoaPods](https://cocoapods.org) installed on your computer and that the pod is initialized in the FanstasyBasketball folder. When opening the project, make sure you open the .xcworkspace file and NOT the .xcodeproj file. Upon opening the project, 5 defualt fantasy teams (belonging to 2 leagues) and 1 watch list will be provided as a proof-of-concept. This app uses the following pods:
* [Hpple](https://github.com/topfunky/hpple) - website parsing
* [BEMLineGraph](https://github.com/Boris-Em/BEMSimpleLineGraph) - bar and line graphs
* [ZFDragableModalTransition](https://github.com/zoonooz/ZFDragableModalTransition) - popup screen views
* [RESideMenu](https://github.com/romaonthego/RESideMenu) - parallax side menu
* [Core Data](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/index.html) on-device data storage

## Images
#### Side menu
<img src="./Screenshots/Menu.png" alt="Drawing" width="300 px"/>

#### Weekly matchup
<img src="./Screenshots/Matchup.png" alt="Drawing" width="300 px"/>

#### Player detail
<img src="./Screenshots/Player.png" alt="Drawing" width="300 px"/>

#### Player discovery
<img src="./Screenshots/Players1.png" alt="Drawing" width="300 px"/>
<img src="./Screenshots/Players2.png" alt="Drawing" width="300 px"/>

#### Collective player / league news
<img src="./Screenshots/News.png" alt="Drawing" width="300 px"/>

#### My team
<img src="./Screenshots/MyTeam.png" alt="Drawing" width="300 px"/>

#### Cutsom watch list
<img src="./Screenshots/WatchList.png" alt="Drawing" width="300 px"/>

#### League scoreboard
<img src="./Screenshots/Scoreboard.png" alt="Drawing" width="300 px"/>

#### League standings
<img src="./Screenshots/Standings.png" alt="Drawing" width="300 px"/>

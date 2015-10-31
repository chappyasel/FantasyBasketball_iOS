//
//  FBPlayer.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/15/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FBGameState) {
    FBGameStateHasntStarted = 0,
    FBGameStateInProgress,
    FBGameStateEnded,
};

@interface FBPlayer : NSObject

@property bool isStarting;

@property NSString *firstName;
@property NSString *lastName;
@property NSString *team;
@property NSString *position;
@property NSString *injury;

@property NSString *type; //(FA...)

@property bool isPlaying;
@property bool isHome;
@property FBGameState gameState;
@property NSString *opponent;
@property NSString *score;
@property NSString *status;
@property NSString *gameLink;

@property float gp;
@property float gs;
@property float min;

@property float fgm;
@property float fga;
@property float ftm;
@property float fta;
@property float rebounds;
@property float assists;
@property float steals;
@property float blocks;
@property float turnovers;
@property float points;

@property float totalFantasyPoints;
@property float fantasyPoints;

@property float prk; //positional rank
@property float adp; //avg draft position

@property float percentOwned;
@property float plusMinus;

@property int playerID;

//29 fields total

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

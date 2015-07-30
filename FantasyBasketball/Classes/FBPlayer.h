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

@property bool isStarting; //(0) //MT only

@property NSString *firstName; //(1)
@property NSString *lastName; //(1)
@property NSString *team; //(2)
@property NSString *position; //(2)
@property NSString *injury; //(3)

@property NSString *type; //(4) //Not MT, MU (FA...)

@property bool isPlaying; //(6)
@property bool isHome; //(5)
@property FBGameState gameState; //(6)
@property NSString *opponent; //(5)
@property NSString *score; //(6)
@property NSString *status; //(6)
@property NSString *gameLink; //(7)

@property float gp;  //(8) //MU only
@property float gs;  //(9) //None
@property float min; //(10) //DL, MU only

@property float fgm; //(11)
@property float fga; //(12)
@property float ftm; //(13)
@property float fta; //(14)
@property float rebounds; //(15)
@property float assists; //(16)
@property float steals; //(17)
@property float blocks; //(18)
@property float turnovers; //(19)
@property float points; //(20)

@property float totalFantasyPoints; //(21) //FA Only
@property float fantasyPoints; //(22)

@property float prk;
@property float adp;

@property float percentOwned; //(23) //Not for DL
@property float plusMinus; //(24) //Not for DL

@property int playerID; //(25)

//29 fields total

- (instancetype)initWithData: (NSArray *) data;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

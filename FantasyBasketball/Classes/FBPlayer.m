//
//  FBPlayer.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/15/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "FBPlayer.h"

@implementation FBPlayer

/* NSDictionary possible entries:
 "isStarting" (0)
 "firstName+lastName"
 "team+position"
 "injury"
 "type"
 "isHome+opponent" (5)
 "isPlaying+gameState+score+status"
 "gameLink"
 "gp"
 "gs"
 "min" (10)
 "fgm"
 "fga"
 "ftm"
 "fta"
 "rebounds" (15)
 "assists"
 "steals"
 "blocks"
 "turnovers"
 "points" (20)
 "totalFantasyPoints"
 "fantasyPoints"
 "percentOwned"
 "plusMinus"
 "playerID" (25)
*/

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        if (![dict[@"isStarting"] isEqual:@"Bench"]) _isStarting = YES;
        else _isStarting = NO;
        NSArray *name = [dict[@"firstName+lastName"] componentsSeparatedByString:@" "];
        _firstName = name[0];
        if ([_firstName isEqualToString:@"Luc"]) { //special case: Luc Richard Mbah a Moute
            _firstName = @"Luc Richard";
            _lastName = @"Mbah a Moute";
        }
        else { //normal case
            _lastName = name[1];
            for (int i = 2; i < name.count; i++) _lastName = [NSString stringWithFormat:@"%@ %@",_lastName,name[i]];
        }
        _team = [[dict[@"team+position"] substringFromIndex:2] substringToIndex:3];
        _position = [dict[@"team+position"] substringFromIndex:6];
        _injury = dict[@"injury"];
        _type = dict[@"type"];
        if ([_type containsString:@"WA ("]) _type = [NSString stringWithFormat:@"WA-%@",[_type substringWithRange:NSMakeRange(4, 2)]];
        _opponent = dict[@"isHome+opponent"];
        if ([_opponent isEqualToString:@""]) _opponent = nil;
        if (_opponent) {
            _isPlaying = YES;
            NSString *status = dict[@"isPlaying+gameState+score+status"];
            if ([status containsString:@"AM"] || [status containsString:@"PM"]) { //game hasnt started
                _gameState = FBGameStateHasntStarted;
                _status = status;
                _score = @"";
            }
            else if ([[status substringToIndex:1] isEqual:@"W"] || [[status substringToIndex:1] isEqual:@"L"]) {
                _gameState = FBGameStateEnded;
                _status = [status substringToIndex:1];
                _score = [status substringFromIndex:2];
            }
            else {
                if (![status containsString:@"-"]) { //special case, game not being played (normal "0-0 12:00 1st")
                    _gameState = FBGameStateHasntStarted;
                    _score = @"";
                    _status = status;
                }
                else {
                    _gameState = FBGameStateInProgress;
                    _score = [status componentsSeparatedByString:@" "][0];
                    _status = [status substringFromIndex:_score.length+1];
                }
            }
            if ([_opponent containsString:@"@"]) _isHome = NO; //away
            else _isHome = YES;
            _gameLink = dict[@"gameLink"];
        }
        else _isPlaying = NO;
        _gp = [dict[@"gp"] floatValue];
        _gs = [dict[@"gs"] floatValue];
        _min = [dict[@"min"] floatValue];
        _fgm = [dict[@"fgm"] floatValue];
        _fga = [dict[@"fga"] floatValue];
        _ftm = [dict[@"ftm"] floatValue];
        _fta = [dict[@"fta"] floatValue];
        _rebounds = [dict[@"rebounds"] floatValue];
        _assists = [dict[@"assists"] floatValue];
        _steals = [dict[@"steals"] floatValue];
        _blocks = [dict[@"blocks"] floatValue];
        _turnovers = [dict[@"turnovers"] floatValue];
        _points = [dict[@"points"] floatValue];
        _totalFantasyPoints = [dict[@"totalFantasyPoints"] floatValue];
        _fantasyPoints = [dict[@"fantasyPoints"] floatValue];
        _percentOwned = [dict[@"percentOwned"] floatValue];
        _plusMinus = [dict[@"plusMinus"] floatValue];
        _playerID = [dict[@"playerID"] floatValue];
    }
    return self;
}

@end

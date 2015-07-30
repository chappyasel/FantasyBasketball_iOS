//
//  FBPlayer.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/15/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "FBPlayer.h"

@implementation FBPlayer

- (instancetype)initWithData:(NSArray *)data {
    if (self = [super init]) {
        if (![data[0] isEqual:@"Bench"]) _isStarting = YES;
        else _isStarting = NO;
        NSArray *name = [data[1] componentsSeparatedByString:@" "];
        _firstName = name[0];
        if ([_firstName isEqualToString:@"Luc"]) { //special case: Luc Richard Mbah a Moute
            _firstName = @"Luc Richard";
            _lastName = @"Mbah a Moute";
        }
        else { //normal case
            _lastName = name[1];
            for (int i = 2; i < name.count; i++) _lastName = [NSString stringWithFormat:@"%@ %@",_lastName,name[i]];
        }
        _team = [[data[2] substringFromIndex:2] substringToIndex:3];
        _position = [data[2] substringFromIndex:6];
        _injury = data[3];
        _type = data[4];
        if ([_type containsString:@"WA ("]) _type = [NSString stringWithFormat:@"WA-%@",[_type substringWithRange:NSMakeRange(4, 2)]];
        _opponent = data[5];
        if (![_opponent isEqual:@"--"]) {
            _isPlaying = YES;
            NSString *status = data[6];
            if ([status containsString:@"AM"] || [status containsString:@"PM"]) { //game hasnt started
                _gameInProgress = NO;
                _gameEnded = NO;
                _status = status;
                _score = @"";
            }
            else if ([[status substringToIndex:1] isEqual:@"W"] || [[status substringToIndex:1] isEqual:@"L"]) { //game ended
                _gameInProgress = NO;
                _gameEnded = YES;
                _status = [status substringToIndex:1];
                _score = [status substringFromIndex:2];
            }
            else {
                if (![status containsString:@"-"]) { //special case, game not being played (normal "0-0 12:00 1st")
                    _gameInProgress = NO;
                    _gameEnded = NO;
                    _score = @"";
                    _status = status;
                }
                else {
                    _gameInProgress = YES;
                    _gameEnded = NO;
                    _score = [status componentsSeparatedByString:@" "][0];
                    _status = [status substringFromIndex:_score.length+1];
                }
            }
            if ([_opponent containsString:@"@"]) _isHome = NO; //away
            else _isHome = YES;
            _gameLink = data[7];
        }
        else _isPlaying = NO;
        if (![data[8] isEqual:@"--"]) _gp = [data[8] floatValue];
        if (![data[9] isEqual:@"--"]) _gs = [data[9] floatValue];
        if (![data[10] isEqual:@"--"]) _min = [data[10] floatValue];
        if (![data[11] isEqual:@"--"]) _fgm = [data[11] floatValue];
        if (![data[12] isEqual:@"--"]) _fga = [data[12] floatValue];
        if (![data[13] isEqual:@"--"]) _ftm = [data[13] floatValue];
        if (![data[14] isEqual:@"--"]) _fta = [data[14] floatValue];
        if (![data[15] isEqual:@"--"]) _rebounds = [data[15] floatValue];
        if (![data[16] isEqual:@"--"]) _assists = [data[16] floatValue];
        if (![data[17] isEqual:@"--"]) _steals = [data[17] floatValue];
        if (![data[18] isEqual:@"--"]) _blocks = [data[18] floatValue];
        if (![data[19] isEqual:@"--"]) _turnovers = [data[19] floatValue];
        if (![data[20] isEqual:@"--"]) _points = [data[20] floatValue];
        if (![data[21] isEqual:@"--"]) _totalFantasyPoints = [data[21] floatValue];
        if (![data[22] isEqual:@"--"]) _fantasyPoints = [data[22] floatValue];
        if (![data[23] isEqual:@"--"]) _percentOwned = [data[23] floatValue];
        if (![data[24] isEqual:@"--"]) _plusMinus = [data[24] floatValue];
        if (![data[25] isEqual:@"--"]) _playerID = [data[25] floatValue];
    }
    return self;
}

@end

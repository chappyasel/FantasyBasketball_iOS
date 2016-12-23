//
//  FBNewsSelectorView.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/29/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import "FBNewsSelectorView.h"

@implementation FBNewsSelectorView {
    
}

+(FBNewsSelectorView *)loadViewFromNib{
    return (FBNewsSelectorView *)[[[NSBundle mainBundle] loadNibNamed:@"FBNewsSelectorView" owner:self options:0] objectAtIndex:0];
}

- (void)layoutSubviews {
    self.backgroundView.layer.cornerRadius = 10;
}

- (void) resetValues {
    [self.switch1 setOn:YES];
    [self.switch2 setOn:YES];
    [self.switch3 setOn:YES];
    [self.switch4 setOn:YES];
}

- (void)setValue: (BOOL) val ForSwitch: (int) row {
    if (row == 0) [self.switch1 setOn:val];
    if (row == 1) [self.switch2 setOn:val];
    if (row == 2) [self.switch3 setOn:val];
    if (row == 3) [self.switch4 setOn:val];
}

- (void)setValuesForAllRows: (NSArray *) values {
    [self.switch1 setOn:[values[0] boolValue]];
    [self.switch2 setOn:[values[1] boolValue]];
    [self.switch3 setOn:[values[2] boolValue]];
    [self.switch4 setOn:[values[3] boolValue]];
}

- (BOOL)valueForRow: (int) row {
    if (row == 0) return self.switch1.isOn;
    if (row == 1) return self.switch2.isOn;
    if (row == 2) return self.switch3.isOn;
    if (row == 3) return self.switch4.isOn;
    return NO;
}

- (NSArray *)valuesForAllRows {
    return @[[NSNumber numberWithBool:self.switch1.isOn],
             [NSNumber numberWithBool:self.switch2.isOn],
             [NSNumber numberWithBool:self.switch3.isOn],
             [NSNumber numberWithBool:self.switch4.isOn]];
}

#pragma mark - touch methods

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    [_delegate cancelButtonPressedInSelectorView:self];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [_delegate doneButtonPressedInSelectorView:self];
}

@end

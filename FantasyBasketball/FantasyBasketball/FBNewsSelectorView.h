//
//  FBNewsSelectorView.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/29/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBNewsSelectorView;

@protocol FBNewsSelectorViewDelegate <NSObject>
@required
- (void) cancelButtonPressedInSelectorView: (FBNewsSelectorView *) selectorView;
- (void) doneButtonPressedInSelectorView: (FBNewsSelectorView *) selectorView;
@end

@interface FBNewsSelectorView : UIView

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UISwitch *switch1;
@property (weak, nonatomic) IBOutlet UISwitch *switch2;
@property (weak, nonatomic) IBOutlet UISwitch *switch3;
@property (weak, nonatomic) IBOutlet UISwitch *switch4;

@property (nonatomic) id <FBNewsSelectorViewDelegate> delegate;

+(FBNewsSelectorView *)loadViewFromNib;

- (void)resetValues; //sets all to 1

- (void)setValue: (BOOL) val ForSwitch: (int) row;

- (void)setValuesForAllRows: (NSArray *) values;

- (BOOL)valueForRow: (int) row;

- (NSArray *)valuesForAllRows;

@end

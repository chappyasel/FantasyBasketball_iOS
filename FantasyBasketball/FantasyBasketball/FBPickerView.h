//
//  FBPickerView.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 7/31/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBPickerView;

@protocol FBPickerViewDelegate <NSObject>
@required
- (void) cancelButtonPressedInPickerView: (FBPickerView *) pickerView;
- (void) doneButtonPressedInPickerView: (FBPickerView *) pickerView;
@end

@interface FBPickerView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (nonatomic) id <FBPickerViewDelegate> delegate;

+(FBPickerView *)loadViewFromNib;

- (void) setData: (NSArray *) array ForColumn: (int) col;

- (int) selectedIndexForColumn: (int) col;

- (void) selectIndex: (int) index inColumn: (int) col;

@end

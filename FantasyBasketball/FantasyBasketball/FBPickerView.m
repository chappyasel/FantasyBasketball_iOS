//
//  FBPickerView.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 7/31/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import "FBPickerView.h"

@implementation FBPickerView {
    NSMutableArray <NSArray <NSString *> *> *data; //An array containing arrays of strings
}

+(FBPickerView *)loadViewFromNib{
    return (FBPickerView *)[[[NSBundle mainBundle] loadNibNamed:@"FBPickerView" owner:self options:0] objectAtIndex:0];
}

- (void)layoutSubviews {
    self.backgroundView.layer.cornerRadius = 10;
}

- (void) resetData {
    data = [[NSMutableArray alloc] init];
}

- (void)setData: (NSArray *) array ForColumn: (int) col {
    if (!data) data = [[NSMutableArray alloc] init];
    data[col] = array;
    _pickerView.dataSource = self;
    _pickerView.delegate = self;
    [_pickerView reloadAllComponents];
}

- (int)selectedIndexForColumn:(int)col {
    return (int)[_pickerView selectedRowInComponent:col];
}

- (NSString *)selectedStringForColumn: (int) col {
    return data[col][[_pickerView selectedRowInComponent:col]];
}

- (void)selectIndex:(int)index inColumn:(int)col {
    [_pickerView selectRow:index inComponent:col animated:NO];
}

- (void)selectString:(NSString *)str inColumn:(int)col {
    int index = (int)[data[col] indexOfObject:str];
    [self selectIndex:index inColumn:col];
}

#pragma mark - touch methods

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    [_delegate cancelButtonPressedInPickerView:self];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [_delegate doneButtonPressedInPickerView:self];
}

#pragma mark - delegate Methods

- (void) pickerView:(nonnull UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
}

#pragma mark - dataSource Methods

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.frame.size.width/data.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return data.count;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return data[component].count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return data[component][row];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

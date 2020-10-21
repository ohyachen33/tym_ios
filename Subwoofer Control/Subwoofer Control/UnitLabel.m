//
//  UnitLabel.m
//  SVS16UltraApp
//
//  Created by Lam Yick Hong on 20/10/2015.
//  Copyright © 2015 primax. All rights reserved.
//

#import "UnitLabel.h"

@interface UnitLabel()

@property (nonatomic, strong)  NSNumber* value;

@end

@implementation UnitLabel

- (id)initWithFrame:(CGRect)frame unit:(NSString*)unit
{
    if(self = [super initWithFrame:frame])
    {
        self.unit = unit;
        
        [self loadDefault];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self loadDefault];
}

- (void)loadDefault
{
    self.valueFont = [UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:162];
    self.unitFont = [UIFont fontWithName:@"HelveticaNeueLTStd-UltLt" size:32];
    
    self.valueTextColor = [UIColor whiteColor];
    self.unitTextColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    
    self.valueKern = -9.0f;
    self.unitKern = -2.0f;
    
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    self.numberFormatter.maximumFractionDigits = 0;
    self.numberFormatter.roundingMode = NSNumberFormatterRoundFloor;
    
}

- (NSString*)valueString
{
    return [self.numberFormatter stringFromNumber:_value];
}

- (NSNumber*)value
{
    return _value;
}

- (void)value:(NSNumber*)value_
{
    self.value = value_;
    
    NSString* valueString = [self valueString];
    
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", valueString, self.unit]];
   
    NSRange valueRange = NSMakeRange(0, attributedString.length - self.unit.length);
    NSRange unitRange = NSMakeRange(valueRange.length, self.unit.length);

    NSRange unitKernRange = NSMakeRange(unitRange.location, unitRange.length);

    NSRange kern = NSMakeRange(0, attributedString.length);
    
    if(self.valueString.length > 0)
    {
        [attributedString addAttributes:@{NSFontAttributeName : self.valueFont} range:valueRange];
        [attributedString addAttributes:@{NSForegroundColorAttributeName : self.valueTextColor} range:valueRange];
        
        [attributedString addAttributes:@{NSKernAttributeName : [NSNumber numberWithFloat:self.valueKern]} range:kern];
    }
    
    if(self.unit.length > 0)
    {
        if(self.phaseStyle)
        {
            UIFont* font = [UIFont fontWithName:[self.unitFont fontName] size:[self.unitFont pointSize] + 23];
            //[attributedString addAttributes:@{NSBaselineOffsetAttributeName : [NSNumber numberWithFloat:[self.unitFont pointSize]]} range:unitRange]; // what if some project need to set baseline?
            [attributedString addAttributes:@{NSFontAttributeName : font} range:unitRange];
            
        }else{
        
            [attributedString addAttributes:@{NSFontAttributeName : self.unitFont} range:unitRange];
        }
        
        [attributedString addAttributes:@{NSForegroundColorAttributeName : self.unitTextColor} range:unitRange];
        
        [attributedString addAttributes:@{NSKernAttributeName : [NSNumber numberWithFloat:self.unitKern]} range:unitKernRange];
    }
    
    self.attributedText = attributedString;
}

@end

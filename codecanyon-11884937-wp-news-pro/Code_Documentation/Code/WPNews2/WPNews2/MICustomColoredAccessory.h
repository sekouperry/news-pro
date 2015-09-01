#import <UIKit/UIKit.h>

@interface MICustomColoredAccessory : UIControl

@property (nonatomic, strong) UIColor *accessoryColor;
@property (nonatomic, strong) UIColor *highlightedColor;

+ (MICustomColoredAccessory *)accessoryWithColor:(UIColor *)color;

@end

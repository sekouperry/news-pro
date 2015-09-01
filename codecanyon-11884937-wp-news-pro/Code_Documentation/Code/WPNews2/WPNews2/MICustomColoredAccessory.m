#import "MICustomColoredAccessory.h"

@implementation MICustomColoredAccessory

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.accessoryColor = [UIColor blackColor];
        self.highlightedColor = [UIColor whiteColor];
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

+ (MICustomColoredAccessory *)accessoryWithColor:(UIColor *)color
{
	MICustomColoredAccessory *accessory = [[MICustomColoredAccessory alloc] initWithFrame:CGRectMake(0, 0, 11.0, 15.0)];
	accessory.accessoryColor = color;
    accessory.highlightedColor = color;
    
	return accessory;
}

- (void)drawRect:(CGRect)rect
{
	CGFloat x = CGRectGetMaxX(self.bounds)-3.0;;
	CGFloat y = CGRectGetMidY(self.bounds);
	const CGFloat R = 5.0;
	CGContextRef ctxt = UIGraphicsGetCurrentContext();
	CGContextMoveToPoint(ctxt, x-R, y-R);
	CGContextAddLineToPoint(ctxt, x, y);
	CGContextAddLineToPoint(ctxt, x-R, y+R);
	CGContextSetLineCap(ctxt, kCGLineCapSquare);
	CGContextSetLineJoin(ctxt, kCGLineJoinMiter);
	CGContextSetLineWidth(ctxt, 1.5);
    
	if (self.highlighted)
	{
		[self.highlightedColor setStroke];
	}
	else
	{
		[self.accessoryColor setStroke];
	}
    
	CGContextStrokePath(ctxt);
}

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	[self setNeedsDisplay];
}

@end

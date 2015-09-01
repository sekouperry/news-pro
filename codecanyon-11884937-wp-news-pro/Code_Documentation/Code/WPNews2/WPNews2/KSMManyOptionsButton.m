
#import "KSMManyOptionsButton.h"

@interface KSMManyOptionsButton ()

@property (strong, nonatomic) UIImageView *centerButtonImageView;
@property (strong, nonatomic) UIImageView *leftButtonImageView, *topButtonImageView;
@property (strong, nonatomic) UIView *backgroundCircleView;
@property (readonly, nonatomic) CGRect closedBounds;
@property (readonly, nonatomic) CGRect openBounds;
@property (readonly, nonatomic) CGRect expandedOpenBounds;

- (void)commonInit;
- (void)openMultiSelectMode;
- (void)expandScreenFurtherOut;
- (void)closeMultiSelectMode;
- (void)topButtonSelected:(id)sender;
- (void)leftButtonSelected:(id)sender;
- (CGRect)expandRect:(CGRect)original byNumberOfPoints:(int)pts;
- (CGRect)contractRect:(CGRect)original byNumberOfPoints:(int)pts;

@end

@implementation KSMManyOptionsButton

#pragma mark Constants

#define BUTTON_RADIUS ((BUTTON_DIAMETER * 1.0) / 2)
#define BUTTON_DIAMETER 35

#define CLOSED_SIZE_WIDTH BUTTON_DIAMETER
#define CLOSED_SIZE_HEIGHT BUTTON_DIAMETER
#define CLOSED_SIZE_HALF_WIDTH (CLOSED_SIZE_WIDTH / 2)
#define CLOSED_SIZE_HALF_HEIGHT (CLOSED_SIZE_HEIGHT / 2)

#define OPEN_SIZE_WIDTH 210
#define OPEN_SIZE_HEIGHT OPEN_SIZE_WIDTH
#define OPEN_SIZE_HALF_WIDTH (OPEN_SIZE_WIDTH / 2)
#define OPEN_SIZE_HALF_HEIGHT (OPEN_SIZE_HEIGHT / 2)

#define WIDGET_SPACING 5

#define TIME_TO_OPEN_AND_CLOSE_VIEW 0.5

#pragma mark Initializers
- (instancetype)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
        CGRect frame = self.frame;
        frame.size = CGSizeMake(BUTTON_DIAMETER, BUTTON_DIAMETER);
        self.frame = frame;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
            centerButtonImage:(UIImage *)centerButtonImage
              leftButtonImage:(UIImage *)leftButtonImage
                            topButtonImage:(UIImage *)topButtonImage

{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
        self.leftButtonImage = leftButtonImage;
        self.topButtonImage = topButtonImage;
        self.centerButtonImage = centerButtonImage;
    }
    return self;
}

- (instancetype)initWithCenterButtonImage:(UIImage *)centerButtonImage
                          leftButtonImage:(UIImage *)leftButtonImage
                           topButtonImage:(UIImage *)topButtonImage

{
    CGRect frame = self.frame;
    frame.size = CGSizeMake(BUTTON_DIAMETER, BUTTON_DIAMETER);
    self = [self initWithFrame:frame
             centerButtonImage:centerButtonImage
               leftButtonImage:leftButtonImage
                topButtonImage:topButtonImage];
    [self drawRect:self.bounds];
    return self;
}

- (void)commonInit
{
    self.currentManyOptionsButtonState = KSMManyOptionsButtonStateClosed;

    //  initialize all of the image views
    self.leftButtonImageView   = [UIImageView new];
    self.topButtonImageView    = [UIImageView new];
    self.centerButtonImageView = [UIImageView new];
    // set the size of each of the image view rectangles
    CGRect bounds = CGRectMake(0, 0, BUTTON_DIAMETER, BUTTON_DIAMETER);
    self.leftButtonImageView.bounds   = bounds;
    self.topButtonImageView.bounds    = bounds;
    self.centerButtonImageView.bounds = bounds;
    // set it so when the frame of one of the image view expands, the image stays the same size
    self.leftButtonImageView.contentMode = UIViewContentModeCenter;
    self.topButtonImageView.contentMode = UIViewContentModeCenter;
    self.centerButtonImageView.contentMode = UIViewContentModeScaleAspectFit;
    // set the centers for each of the image view rectangles
    CGPoint center = CGPointMake(0, 0);
    self.leftButtonImageView.center   = center;
    self.topButtonImageView.center    = center;
    
    self.centerButtonImageView.center = center;

    self.clipsToBounds       = YES;
    self.layer.masksToBounds = YES;
    self.bounds = self.closedBounds;

    // set the corner radius of the layer to be the button's radius
    self.layer.cornerRadius = BUTTON_RADIUS;
    self.leftButtonImageView.alpha   = 0;
    self.topButtonImageView.alpha    = 0;
    self.backgroundColor = [UIColor clearColor];
    // set teh default transformation to be the identify transformation
    self.transformForCenterButtonWhenClosed = CGAffineTransformIdentity;

    self.transform  = CGAffineTransformMakeScale(.8, .8);
}

#pragma mark Selectors
- (void)openMultiSelectMode
{
    if (self.currentManyOptionsButtonState != KSMManyOptionsButtonStateOpen) {

        if (self.currentManyOptionsButtonState == KSMManyOptionsButtonStateClosed) {
            self.layer.cornerRadius = BUTTON_RADIUS;
        } else if (self.currentManyOptionsButtonState == KSMManyOptionsButtonStateExpanded) {
            self.layer.cornerRadius = self.expandedOpenBounds.size.height / 2;
        }

        // create the animation to open teh corner radius of teh view.
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        animation.fromValue = @(self.layer.cornerRadius);
        animation.toValue = @(OPEN_SIZE_HALF_HEIGHT);
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.duration = TIME_TO_OPEN_AND_CLOSE_VIEW;

        // get the coordinates to move the extra views to
        int offset = BUTTON_RADIUS + WIDGET_SPACING - OPEN_SIZE_HALF_HEIGHT;
        CGPoint centerForTopImage    = CGPointMake(0      , offset );
        CGPoint centerForLeftImage   = CGPointMake(offset , 0      );
        CGPoint centerForCenterImage = CGPointMake(0      , 0      );


        // animate the opening of the view
        [UIView animateWithDuration:TIME_TO_OPEN_AND_CLOSE_VIEW
                         animations:^{
                             // create the new bounds
                             self.bounds = self.openBounds;

                             // animate the corner radius
                             [self.layer addAnimation:animation forKey:@"cornerRadius"];
                             self.layer.cornerRadius = OPEN_SIZE_HALF_HEIGHT;

                             // animate each of the extra views to their new location
                             self.leftButtonImageView.center   = centerForLeftImage;
                                                          self.topButtonImageView.center    = centerForTopImage;
                             
                             self.centerButtonImageView.center = centerForCenterImage;

                             // make all of the buttons full alpha values
                             self.topButtonImageView.alpha    = 1;
                             
                             self.leftButtonImageView.alpha   = 1;
                             
                             // set the bounds of each of the views to be the larger frame
                             self.leftButtonImageView.bounds   = [self buttonClosedBounds];
                             
                             self.topButtonImageView.bounds    = [self buttonClosedBounds];
                             

                             // set the background circle to have a full opcaity as well
                             self.backgroundColor = [UIColor colorWithWhite:1 alpha:.12];

                             // set the center button to have the identity transformation
                             self.centerButtonImageView.transform = CGAffineTransformIdentity;

                             // set the tranform to be the identity
                             self.transform = CGAffineTransformIdentity;
                         }
                         completion:nil];
        // set the current state of the view to be open
        self.currentManyOptionsButtonState = KSMManyOptionsButtonStateOpen;
    }

}

- (void)expandScreenFurtherOut
{
    if (self.currentManyOptionsButtonState != KSMManyOptionsButtonStateExpanded) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        animation.fromValue = @(self.layer.cornerRadius);
        animation.toValue = @(self.expandedOpenBounds.size.width / 2);
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.duration = TIME_TO_OPEN_AND_CLOSE_VIEW / 2;

        // get the coordinates to move the extra views to
        int offset = (BUTTON_RADIUS / 2) + WIDGET_SPACING - OPEN_SIZE_HALF_HEIGHT;
        CGPoint centerForTopImage    = CGPointMake(0      , offset );
        CGPoint centerForLeftImage   = CGPointMake(offset , 0      );
       
        CGPoint centerForCenterImage = CGPointMake(0      , 0      );



        [UIView animateWithDuration:(TIME_TO_OPEN_AND_CLOSE_VIEW / 2)
                         animations:^{
                             self.bounds = self.expandedOpenBounds;
                             [self.layer addAnimation:animation forKey:@"cornerRadius"];
                             self.layer.cornerRadius = self.expandedOpenBounds.size.height / 2;

                             // animate each of the extra views to their new location
                             self.leftButtonImageView.center   = centerForLeftImage;
                                                          self.topButtonImageView.center    = centerForTopImage;
                                                          self.centerButtonImageView.center = centerForCenterImage;

                             // set the bounds of each of the views to be the larger frame
                             self.leftButtonImageView.bounds   = [self buttonSelectedBounds];
                             
                             self.topButtonImageView.bounds    = [self buttonSelectedBounds];
                            


                             // set the center button to have the identity transformation
                             self.centerButtonImageView.transform = CGAffineTransformIdentity;
                         }
                         completion:nil];
        self.currentManyOptionsButtonState = KSMManyOptionsButtonStateExpanded;

    }
}

- (void)closeMultiSelectMode
{
    if (self.currentManyOptionsButtonState != KSMManyOptionsButtonStateClosed) {
        // create the animation to close the corner radius of the view
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        animation.toValue = @(BUTTON_RADIUS);
        animation.fromValue = @(self.layer.cornerRadius);
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.duration = TIME_TO_OPEN_AND_CLOSE_VIEW;

        // get the center to move everything back to
        CGPoint center = CGPointMake(0, 0);

        // animate everythign to close
        [UIView animateWithDuration:TIME_TO_OPEN_AND_CLOSE_VIEW
                         animations:^{
                             // put the bounds to be the closed bounds
                             self.bounds = self.closedBounds;

                             // add the animation to the layer
                             [self.layer addAnimation:animation forKey:@"cornerRadius"];
                             self.layer.cornerRadius = BUTTON_RADIUS;

                             // move all of the extra views back to the center
                             self.leftButtonImageView.center   = center;
                                                          self.topButtonImageView.center    = center;
                            
                             self.centerButtonImageView.center = center;

                             // make all the buttons 0 alpha values
                             self.topButtonImageView.alpha    = 0;
                             
                             self.leftButtonImageView.alpha   = 0;
                             

                             // set the bounds of each of the views to be the larger frame
                             self.leftButtonImageView.bounds   = [self buttonClosedBounds];
                            
                             self.topButtonImageView.bounds    = [self buttonClosedBounds];
                             
                             // set the center button to have the transformation specified
                             self.centerButtonImageView.transform = self.transformForCenterButtonWhenClosed;

                             self.transform = CGAffineTransformMakeScale(.8, .8);
                             
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 // set the background circle to have no opacity
                                 self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];

                                 // set all of the images back to normal
                                 self.topButtonImageView.image    = self.topButtonImage;
                                 self.leftButtonImageView.image   = self.leftButtonImage;
                             }
                         }];
        // set the current state of the view to be closed
        self.currentManyOptionsButtonState = KSMManyOptionsButtonStateClosed;
    }
}


- (CGRect)expandRect:(CGRect)original byNumberOfPoints:(int)pts
{
    CGRect final = original;
    final.size.width = original.size.width + (2 * pts);
    final.size.height = original.size.height + (2 * pts);
    final.origin.x -= pts;
    final.origin.y -= pts;
    return final;
}

- (CGRect)contractRect:(CGRect)original byNumberOfPoints:(int)pts
{
    CGRect final = original;
    final.size.width = original.size.width - (2 * pts);
    final.size.height = original.size.height - (2 * pts);
    final.origin.x += pts;
    final.origin.y += pts;
    return final;
}

- (CGRect)expandByWidgetSpacing:(CGRect)original
{
    return [self expandRect:original byNumberOfPoints:(BUTTON_RADIUS / 2)];
}

#pragma mark Getters
- (NSArray *)locationsArray
{
    NSMutableArray *locationsArray;

    if (self.topButtonImage)
        [locationsArray addObject:@(KSMManyOptionsButtonLocationTop)];
    
    if (self.leftButtonImage)
        [locationsArray addObject:@(KSMManyOptionsButtonLocationLeft)];

    return [locationsArray copy];
}

- (CGSize)closedSize
{
    return CGSizeMake(BUTTON_DIAMETER, BUTTON_DIAMETER);
}

- (CGRect)closedBounds
{
    return CGRectMake(-BUTTON_RADIUS, -BUTTON_RADIUS, BUTTON_DIAMETER, BUTTON_DIAMETER);
}

- (CGSize)openedSize
{
    return CGSizeMake(OPEN_SIZE_WIDTH, OPEN_SIZE_HEIGHT);
}

- (CGRect)openBounds
{
    return CGRectMake(-OPEN_SIZE_HALF_WIDTH, -OPEN_SIZE_HALF_HEIGHT, OPEN_SIZE_WIDTH, OPEN_SIZE_HEIGHT);
}

- (CGRect)expandedOpenBounds
{
    return CGRectMake(-OPEN_SIZE_HALF_HEIGHT - (BUTTON_RADIUS / 2), -OPEN_SIZE_HALF_HEIGHT - (BUTTON_RADIUS / 2), OPEN_SIZE_WIDTH + BUTTON_RADIUS, OPEN_SIZE_HEIGHT + BUTTON_RADIUS);
}

- (CGRect)buttonSelectedBounds
{
    return [self expandByWidgetSpacing:[self buttonClosedBounds]];
}

- (CGRect)buttonClosedBounds
{
    return CGRectMake(0, 0, BUTTON_DIAMETER, BUTTON_DIAMETER);
}

#pragma mark Setters
- (void)setLeftButtonImage:(UIImage *)leftButtonImage
{
    _leftButtonImage = leftButtonImage;
    self.leftButtonImageView.image = leftButtonImage;
}



- (void)setTopButtonImage:(UIImage *)topButtonImage
{
    _topButtonImage = topButtonImage;
    self.topButtonImageView.image = topButtonImage;
}



- (void)setCenterButtonImage:(UIImage *)centerButtonImage
{
    _centerButtonImage = centerButtonImage;
    self.centerButtonImageView.image = centerButtonImage;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];

    self.backgroundCircleView.frame = bounds;
}

- (void)setTransformForCenterButtonWhenClosed:(CGAffineTransform)transformForCenterButtonWhenClosed
{
    _transformForCenterButtonWhenClosed = transformForCenterButtonWhenClosed;

    if (self.currentManyOptionsButtonState == KSMManyOptionsButtonStateClosed) {
        self.centerButtonImageView.transform = transformForCenterButtonWhenClosed;
    }
}

#pragma mark UIViewDelegate
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    [self addSubview:self.leftButtonImageView];
   
    [self addSubview:self.topButtonImageView];
        [self addSubview:self.centerButtonImageView];
}

#pragma mark UIControlDelegate
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];

    // if it is closed and we jsut started the touch, we need to open the controller
    if (self.currentManyOptionsButtonState == KSMManyOptionsButtonStateClosed) {
        [self openMultiSelectMode];
    } else {
       BOOL expandingNecessary = NO;

        if (CGRectContainsPoint(self.topButtonImageView.frame, touchPoint)) {
            if (self.topButtonImage && self.highlightedTopButtonImage) {
                UIImage *beforeImage = self.topButtonImageView.image;
                UIImage *afterImage = self.highlightedTopButtonImage;

                CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"content"];
                crossFade.duration = 1.0f;
                crossFade.fromValue = (__bridge id)(beforeImage.CGImage);
                crossFade.toValue = (__bridge id)(afterImage.CGImage);
                [self.layer addAnimation:crossFade forKey:@"crossFade"];

                self.topButtonImageView.image = self.highlightedTopButtonImage;


                [self expandScreenFurtherOut];
                expandingNecessary = YES;
            }
        } else {
            if (self.topButtonImage) {
                self.topButtonImageView.image = self.topButtonImage;
            }
        }

        // for the left view
        if (CGRectContainsPoint(self.leftButtonImageView.frame, touchPoint)) {
            if (self.leftButtonImage && self.highlightedLeftButtonImage) {
                self.leftButtonImageView.image = self.highlightedLeftButtonImage;
                [self expandScreenFurtherOut];
                expandingNecessary = YES;
            }
        } else {
            if (self.leftButtonImage) {
                self.leftButtonImageView.image = self.leftButtonImage;
            }
        }

       
       
        if (!expandingNecessary && self.currentManyOptionsButtonState == KSMManyOptionsButtonStateExpanded) {
            [self openMultiSelectMode];
        }
    }

    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];

    if (self.currentManyOptionsButtonState == KSMManyOptionsButtonStateClosed) {

    }

    // we must check if the touch was inside any one of the buttons
    else {
        BOOL expandingNecessary = NO;

        // if the touch is in the center button, we need to close this view
        if (CGRectContainsPoint(self.centerButtonImageView.frame, touchPoint)) {

        }
        
        if (CGRectContainsPoint(self.topButtonImageView.frame, touchPoint)) {
            if (self.topButtonImage && self.highlightedTopButtonImage) {
                UIImage *beforeImage = self.topButtonImageView.image;
                UIImage *afterImage = self.highlightedTopButtonImage;

                CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"content"];
                crossFade.duration = 1.0f;
                crossFade.fromValue = (id)(beforeImage.CGImage);
                crossFade.toValue = (id)(afterImage.CGImage);
                [self.layer addAnimation:crossFade forKey:@"crossFade"];

                self.topButtonImageView.image = self.highlightedTopButtonImage;


                [self expandScreenFurtherOut];
                expandingNecessary = YES;
            }
        } else {
            if (self.topButtonImage && self.currentManyOptionsButtonState == KSMManyOptionsButtonStateExpanded) {
                self.topButtonImageView.image = self.topButtonImage;
            }
        }

        // for the left view
        if (CGRectContainsPoint(self.leftButtonImageView.frame, touchPoint)) {
            if (self.leftButtonImage && self.highlightedLeftButtonImage) {
                self.leftButtonImageView.image = self.highlightedLeftButtonImage;

                [self expandScreenFurtherOut];
                expandingNecessary = YES;
            }
        } else {
            if (self.leftButtonImage && self.currentManyOptionsButtonState == KSMManyOptionsButtonStateExpanded) {
                self.leftButtonImageView.image = self.leftButtonImage;

            }
        }

       if (!expandingNecessary && self.currentManyOptionsButtonState == KSMManyOptionsButtonStateExpanded) {
            [self openMultiSelectMode];
        }
    }
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    
    if (self.currentManyOptionsButtonState == KSMManyOptionsButtonStateOpen) {
        
    }
     if (CGRectContainsPoint(self.centerButtonImageView.frame, touchPoint)) {
        [self closeMultiSelectMode];
    }
    
    else {
        
        if (CGRectContainsPoint(self.topButtonImageView.frame, touchPoint)
            || self.topButtonImageView.image == self.highlightedTopButtonImage) {
            [self topButtonSelected:self];
        }
        if (CGRectContainsPoint(self.leftButtonImageView.frame, touchPoint)
            || self.leftButtonImageView.image == self.highlightedLeftButtonImage) {
            [self leftButtonSelected:self];
        }
        
    }
}

- (void)topButtonSelected:(id)sender
{
    if (self.delegate && self.topButtonImage) {
        self.topButtonImageView.image = self.highlightedTopButtonImage;
        [self.delegate manyOptionsButton:self didSelectButtonAtLocation:KSMManyOptionsButtonLocationTop];
        [self closeMultiSelectMode];
    }
}

- (void)leftButtonSelected:(id)sender
{
    if (self.delegate && self.leftButtonImage) {
        self.leftButtonImageView.image = self.highlightedLeftButtonImage;
        [self.delegate manyOptionsButton:self didSelectButtonAtLocation:KSMManyOptionsButtonLocationLeft];
        [self closeMultiSelectMode];
    }
}


@end

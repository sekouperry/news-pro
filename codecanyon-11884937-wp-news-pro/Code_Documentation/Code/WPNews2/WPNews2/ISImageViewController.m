
#import "ISImageViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MONActivityIndicatorView.h"
#import "KSMManyOptionsButton.h"
#import "UIImageView+WebCache.h"

#define Epsilon 0.000001
#define FLT_EQUAL(a, b) (fabsf(a - b) < Epsilon)



@implementation UIScrollView (ZoomToPoint)

- (void)zoomToPoint:(CGPoint)point scale:(CGFloat)scale animated:(BOOL)animated {
    CGFloat x, y, width, height;
    
    width = self.contentSize.width / self.zoomScale;
    height = self.contentSize.height / self.zoomScale;
    
    CGSize contentSize = (CGSize){width, height};
    
    x = point.x / self.bounds.size.width * contentSize.width;
    y = point.y / self.bounds.size.height * contentSize.height;
    
    CGPoint zoomPoint = (CGPoint){x, y};
    
    width = self.bounds.size.width / scale;
    height = self.bounds.size.height / scale;
    
    CGSize zoomSize = (CGSize){width, height};
    
    x = zoomPoint.x - zoomSize.width / 2.f;
    y = zoomPoint.y - zoomSize.height / 2.f;
    
    width = zoomSize.width;
    height = zoomSize.height;
    
    CGRect zoomRect = (CGRect){x, y, width, height};
    
    [self zoomToRect:zoomRect animated:animated];
}

- (CGFloat)zoomScaleOfSize:(CGSize)zoomViewSize {
    return fminf(self.bounds.size.width / zoomViewSize.width, self.bounds.size.height / zoomViewSize.height) - .000001;
}

- (CGFloat)maximumZoomScaleOfSize:(CGSize)zoomViewSize {
    CGFloat scaleOfZoom = [self zoomScaleOfSize:zoomViewSize];
    CGSize sizeAfterZoom = (CGSize){zoomViewSize.width * scaleOfZoom, zoomViewSize.height * scaleOfZoom};
    
    CGSize contentSize = self.bounds.size;
    
    if (sizeAfterZoom.height / sizeAfterZoom.width > contentSize.height / contentSize.width) {
        
        return scaleOfZoom * fmaxf(contentSize.width / sizeAfterZoom.width, 3.f);
    } else {
        
        return scaleOfZoom * fmaxf(contentSize.height / sizeAfterZoom.height, 3.f);
    }
}

- (CGRect)frameToCenterOfFrame:(CGRect)zoomViewFrame {
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = zoomViewFrame;
    
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2.0;
    } else {
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2.0;
    } else {
        frameToCenter.origin.y = 0;
    }
    
    return frameToCenter;
}

@end

@implementation UIImageView (ScaleOfSize)

- (CGFloat)scaleOfSize:(CGSize)size {
    return fminf(self.bounds.size.width / size.width, self.bounds.size.height / size.height);
}

- (CGSize)displaySizeOfAspectFitMode {
    CGFloat scale = [self scaleOfSize:self.image.size];
    
    return (CGSize){self.image.size.width * scale, self.image.size.height * scale};
}

@end

CGFloat degreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat radiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

@implementation UIImage (Rotate)

- (UIImage *)imageRotatedByRadians:(CGFloat)radians {
    return [self imageRotatedByDegrees:radiansToDegrees(radians)];
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees {
    
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    CGContextRotateCTM(bitmap, degreesToRadians(degrees));
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

@interface ISImageViewController ()<UIScrollViewDelegate, UIGestureRecognizerDelegate, MONActivityIndicatorViewDelegate, KSMManyOptionsButtonDelegate> {
    CGFloat _lastScale;
    CGFloat _lastRotation;
    BOOL _forbidUserRotate;
}

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *playVideoButton;

@property (strong, nonatomic) UIImageView *dummyImageView;
@property (nonatomic) KSMManyOptionsButton *button;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (strong, nonatomic) UIRotationGestureRecognizer *rotationGestureRecognizer;
@property (nonatomic, readonly) MONActivityIndicatorView *monActivity;
@property BOOL zoomEnd;

@end

@implementation ISImageViewController


- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        _zoomEnd = true;
        
        self.view.backgroundColor = [UIColor blackColor];
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.delegate = self;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        _scrollView.showsHorizontalScrollIndicator = _scrollView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_scrollView];
        
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        _imageView.userInteractionEnabled = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_scrollView addSubview:_imageView];
        
        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidDoubleTap:)];
        doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        [_imageView addGestureRecognizer:doubleTapGestureRecognizer];
        
        // pinch
        _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPinch:)];
        _pinchGestureRecognizer.delegate = self;
        [_imageView addGestureRecognizer:_pinchGestureRecognizer];
        
        // rotation
        _rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(userDidRotate:)];
        _rotationGestureRecognizer.delegate = self;
        [_imageView addGestureRecognizer:_rotationGestureRecognizer];
        
        _monActivity = [MONActivityIndicatorView new];
        _monActivity.delegate = self;
        _monActivity.numberOfCircles = 4;
        _monActivity.radius = 5;
        _monActivity.internalSpacing = 5;
        _monActivity.center = self.view.center;
        
        [self.view addSubview:_monActivity];
        [_monActivity startAnimating];
        
        UIImage *center = [UIImage imageNamed:@"center"];
        UIImage *left   = [UIImage imageNamed:@"cancel"];
        UIImage *top    = [UIImage imageNamed:@"send"];
        
        _button = [[KSMManyOptionsButton alloc] initWithCenterButtonImage:center
                                                          leftButtonImage:left
                                                           topButtonImage:top];
        
        _button.highlightedTopButtonImage = [UIImage imageNamed:@"sendSelected"];
        _button.highlightedLeftButtonImage = [UIImage imageNamed:@"cancelSelected"];
        
        _button.transformForCenterButtonWhenClosed = CGAffineTransformMakeRotation(M_PI / 4);
        
        _button.delegate = self;
        _button.center = CGPointMake(CGRectGetMaxX(self.view.bounds) - 25, CGRectGetMaxY(self.view.bounds) - 22);
        [self.view addSubview:_button];
        
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(etImpo) userInfo:nil repeats:NO];
    }
    
    return self;
    
}

- (void)viewWillLayoutSubviews {
   
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.f) {
        
        _imageView.transform = CGAffineTransformIdentity;
        _imageView.frame = _scrollView.bounds;
        
        [self resetScrollViewZoomScales];
    }
}


- (void)etImpo{
    
    NSLog(@"fut");
    _imageView.frame = _scrollView.bounds;
     NSLog(@"%@", _imageURL);
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:_imageURL]
                      placeholderImage:nil
                                   options:SDWebImageProgressiveDownload
                                  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                      [_monActivity startAnimating];
                                  }
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     [_monActivity stopAnimating];
                                     [self resetScrollViewZoomScales];
                                 }];
    
}

- (void)resetScrollViewZoomScales {
    CGSize imageDisplaySize = [_imageView displaySizeOfAspectFitMode];
    
    _scrollView.maximumZoomScale = [_scrollView maximumZoomScaleOfSize:imageDisplaySize];
    _scrollView.minimumZoomScale = [_scrollView zoomScaleOfSize:imageDisplaySize];
    _scrollView.zoomScale = _scrollView.minimumZoomScale;
}

#pragma mark UIScrollViewDelegate methods

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [scrollView.subviews firstObject];
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerImageView];
}


#pragma mark - Interface Orientation Change handler

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                        duration:(NSTimeInterval)duration{
    
    if (_dummyImageView) {
        _rotationGestureRecognizer.enabled = NO;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width*self.scrollView.zoomScale, self.view.bounds.size.height*self.scrollView.zoomScale);
    self.imageView.frame = CGRectMake(0,0 , self.scrollView.contentSize.width,self.scrollView.contentSize.height);
    
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self recoverFromResizing];
    [self centerImageView];
    _button.center = CGPointMake(CGRectGetMaxX(self.view.bounds) - 25, CGRectGetMaxY(self.view.bounds) - 22);
    _monActivity.center = self.view.center;
    //[self resetScrollViewZoomScales];
}

- (void)recoverFromResizing {
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.scrollView.bounds), CGRectGetMidY(self.scrollView.bounds));
    
    CGFloat scaleToRestoreAfterResize = self.scrollView.zoomScale;
    
    self.scrollView.zoomScale = MIN(self.scrollView.maximumZoomScale, MAX(self.scrollView.minimumZoomScale, scaleToRestoreAfterResize));
    
    CGPoint offset = CGPointMake(boundsCenter.x - self.scrollView.bounds.size.width / 2.0,
                                 boundsCenter.y - self.scrollView.bounds.size.height / 2.0);
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
    offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
    self.scrollView.contentOffset = offset;
}

- (CGPoint)maximumContentOffset{
    CGSize contentSize = self.scrollView.contentSize;
    CGSize boundsSize = self.scrollView.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset{
    return CGPointZero;
}

-(void)centerImageView{
    if(self.imageView.image){
        CGRect frame  = AVMakeRectWithAspectRatioInsideRect(self.imageView.image.size,CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height));
        
        if (self.scrollView.contentSize.width==0 && self.scrollView.contentSize.height==0) {
            frame = AVMakeRectWithAspectRatioInsideRect(self.imageView.image.size,self.scrollView.bounds);
        }
        
        CGSize boundsSize = self.scrollView.bounds.size;
        
        CGRect frameToCenter = CGRectMake(0,0 , frame.size.width, frame.size.height);
        
        if (frameToCenter.size.width < boundsSize.width){
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
        }else{
            frameToCenter.origin.x = 0;
        }if (frameToCenter.size.height < boundsSize.height){
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
        }else{
            frameToCenter.origin.y = 0;
        }
        self.imageView.frame = frameToCenter;
    }
}


#pragma mark - UIGestureRecognizerDelegate

#define tolerateScale .03f

#define scaleTolerable (fabsf(_scrollView.zoomScale - _scrollView.minimumZoomScale) / _scrollView.minimumZoomScale < tolerateScale)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == _rotationGestureRecognizer) {
        return ((_dummyImageView || fabs) && !_forbidUserRotate);
    }
    
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


#pragma mark UIImageView GestureRecognizer Handler

- (void)userDidDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    
    if (!_zoomEnd) {
        [_scrollView zoomToPoint:[gestureRecognizer locationInView:_scrollView] scale:_scrollView.minimumZoomScale animated:YES];
        _zoomEnd = true;
    }else{
        [_scrollView zoomToPoint:[gestureRecognizer locationInView:_scrollView] scale:_scrollView.maximumZoomScale animated:YES];
        _zoomEnd = false;
    }
       
   
}


- (void)userDidPinch:(UIPinchGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (!_dummyImageView) {
            if (fabs) {
                [self addDummyImageView];
                BOOL showDummyImageView = (gestureRecognizer.scale < 1.0);
                _dummyImageView.hidden = !showDummyImageView;
                _imageView.hidden = showDummyImageView;
                if (showDummyImageView) {
                    _scrollView.zoomScale = _scrollView.minimumZoomScale;
                    _scrollView.pinchGestureRecognizer.enabled = NO;
                }
            } else {
                _forbidUserRotate = YES;
            }
        }
        
        _lastScale = 1.f;
    } else {
        
        if (_dummyImageView.hidden && gestureRecognizer.scale > 1 + tolerateScale) {
            [_dummyImageView removeFromSuperview];
            _dummyImageView = nil;
            _forbidUserRotate = YES;
        }
        
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            if (_dummyImageView) {
                CGFloat scale = gestureRecognizer.scale / _lastScale;
                _dummyImageView.transform = CGAffineTransformScale(_dummyImageView.transform, scale, scale);
                _lastScale = gestureRecognizer.scale;
            }
        } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
            _forbidUserRotate = NO;
            [self removeDummyImageView];
            _scrollView.pinchGestureRecognizer.enabled = YES;
        }
    }
}

- (void)userDidRotate:(UIRotationGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        if (_dummyImageView) {
            if (_dummyImageView.hidden) {
                _imageView.hidden = !(_dummyImageView.hidden = NO);
            }
        } else if (!_forbidUserRotate) {
            [self addDummyImageView];
            _imageView.hidden = YES;
        }
        
        if (_imageView.hidden) {
                        _scrollView.zoomScale = _scrollView.minimumZoomScale;
            _scrollView.pinchGestureRecognizer.enabled = NO;
        }
        
        _lastRotation = .0f;
    } else {
        
        if (!_dummyImageView) return;
        
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            CGFloat rotation = gestureRecognizer.rotation - _lastRotation;
            _dummyImageView.transform = CGAffineTransformRotate(_dummyImageView.transform, rotation);
            _lastRotation = gestureRecognizer.rotation;
        } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
            [self removeDummyImageView];
            _scrollView.pinchGestureRecognizer.enabled = YES;
        }
    }
}

- (void)addDummyImageView {
    if (!_dummyImageView) {
        _dummyImageView = [[UIImageView alloc] initWithImage:_imageView.image];
        _dummyImageView.contentMode = UIViewContentModeScaleAspectFit;
        _dummyImageView.frame = (CGRect){0, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height};
        _dummyImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_scrollView addSubview:_dummyImageView];
    }
}

- (void)removeDummyImageView {
   
    static BOOL isRemoving = NO;
    if (!isRemoving && _dummyImageView) {
        isRemoving = YES;
        
        void (^completion)() = ^{
            [_dummyImageView removeFromSuperview];
            _dummyImageView = nil;
            _imageView.hidden = NO;
            isRemoving = NO;
            _lastRotation = 0.f;
        };
        
        if (_rotationGestureRecognizer.enabled) {// normal end
            
            CGFloat rotation = [self normalizeRotationOfRotation:_lastRotation];
            
            CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, rotation);
            BOOL shouldChangeImageViewScale = ((int)(fabs(rotation) / (M_PI / 2.f) + Epsilon)) & 0x01;
            // resize to fit super view
            if (shouldChangeImageViewScale) {
                CGSize formerSize = _dummyImageView.image.size;
                CGSize laterSize = (CGSize){formerSize.height, formerSize.width};
                CGFloat scale = [_dummyImageView scaleOfSize:laterSize] / [_dummyImageView scaleOfSize:formerSize];
                transform = CGAffineTransformScale(transform, scale, scale);
            }
            
            if (rotation) {
                UIImage *rotatedImage = [_imageView.image imageRotatedByRadians:rotation];
                _imageView.frame = _scrollView.bounds;
                _imageView.image = rotatedImage;
                [self resetScrollViewZoomScales];
                NSLog(@"fut 45");
            }
            
            [UIView animateWithDuration:.25f animations:^{
                _dummyImageView.transform = transform;
                
            } completion:^(BOOL finished) {
                completion();
            }];
        } else {
            completion();
            _rotationGestureRecognizer.enabled = YES;
        }
    }
}

- (CGFloat)normalizeRotationOfRotation:(CGFloat)currentRotation {
    BOOL isNegativeRotation = (currentRotation < 0);
    if (isNegativeRotation) currentRotation = -currentRotation;
    NSInteger quadrant = ((NSInteger)(currentRotation / (M_PI / 4.f)) + 1) >> 1;
    CGFloat rotation = quadrant * M_PI / 2.f;
    
    return (isNegativeRotation ? -rotation : rotation);
}

#pragma mark -
#pragma mark - MONActivityIndicatorViewDelegate Methods

- (UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView
      circleBackgroundColorAtIndex:(NSUInteger)index {
    return [UIColor colorWithWhite:1.0 alpha:0.5];
}

- (void) share {
    
    NSString *message = _imageURL;
    UIImage *imageToShare = _imageView.image;
    
    NSArray *postItems = @[message, imageToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:postItems
                                            applicationActivities:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        UIPopoverController *popOverPad = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        [popOverPad presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/3, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    } else {
        
        [self presentViewController:activityVC animated:YES completion:nil];
    }

}

#pragma mark KSMManyOptionsButtonDelegate
- (void)manyOptionsButton:(KSMManyOptionsButton *)button didSelectButtonAtLocation:(KSMManyOptionsButtonLocation)location
{
    switch (location) {
        
        case KSMManyOptionsButtonLocationLeft:
            NSLog(@"Close");
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        
        case KSMManyOptionsButtonLocationTop:
            NSLog(@"Share");
            [self share];
            break;
        default:
            break;
    }
}

@end

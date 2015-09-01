
#import <UIKit/UIKit.h>


@interface UIScrollView (ZoomToPoint)

- (void)zoomToPoint:(CGPoint)point scale:(CGFloat)scale animated:(BOOL)animated;

- (CGFloat)zoomScaleOfSize:(CGSize)zoomViewSize;

- (CGFloat)maximumZoomScaleOfSize:(CGSize)zoomViewSize;

- (CGRect)frameToCenterOfFrame:(CGRect)zoomViewFrame;

@end

@interface UIImageView (ScaleOfSize)

- (CGFloat)scaleOfSize:(CGSize)size;

- (CGSize)displaySizeOfAspectFitMode;

@end

@interface UIImage (Rotate)

- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end

@interface ISImageViewController : UIViewController

@property (strong, nonatomic) NSString *imageURL;

@end

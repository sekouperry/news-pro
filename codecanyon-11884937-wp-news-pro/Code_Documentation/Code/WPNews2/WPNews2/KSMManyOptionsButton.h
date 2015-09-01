
#import <UIKit/UIKit.h>

@protocol KSMManyOptionsButtonDelegate;

typedef NS_ENUM(NSUInteger, KSMManyOptionsButtonLocation) {
    KSMManyOptionsButtonLocationTop,
      KSMManyOptionsButtonLocationLeft,
};

typedef NS_ENUM(NSUInteger, KSMManyOptionsButtonState) {
    KSMManyOptionsButtonStateOpen,
    KSMManyOptionsButtonStateClosed,
    KSMManyOptionsButtonStateExpanded
};

@interface KSMManyOptionsButton : UIControl

@property (strong, nonatomic) UIImage *leftButtonImage,
*topButtonImage;

@property (strong, nonatomic) UIImage *highlightedLeftButtonImage,

                                      *highlightedTopButtonImage;

@property (strong, nonatomic) UIImage *centerButtonImage;

@property (nonatomic) KSMManyOptionsButtonState currentManyOptionsButtonState;

@property (readonly, strong, nonatomic) NSArray *locationsArray;

@property (readonly, nonatomic) CGSize closedSize;

@property (readonly, nonatomic) CGSize openedSize;

@property (weak, nonatomic) id<KSMManyOptionsButtonDelegate> delegate;

@property (nonatomic) CGAffineTransform transformForCenterButtonWhenClosed;


- (instancetype)initWithFrame:(CGRect)frame
            centerButtonImage:(UIImage *)centerButtonImage
              leftButtonImage:(UIImage *)leftButtonImage
                topButtonImage:(UIImage *)topButtonImage;

- (instancetype)initWithCenterButtonImage:(UIImage *)centerButtonImage
                          leftButtonImage:(UIImage *)leftButtonImage
                           topButtonImage:(UIImage *)topButtonImage;

@end

@protocol KSMManyOptionsButtonDelegate <NSObject>


- (void)manyOptionsButton:(KSMManyOptionsButton *)button didSelectButtonAtLocation:(KSMManyOptionsButtonLocation)location;

@end

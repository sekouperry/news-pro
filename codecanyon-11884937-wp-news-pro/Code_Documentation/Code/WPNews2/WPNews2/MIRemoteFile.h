
#import <Foundation/Foundation.h>


typedef BOOL (^ValidatorBlock)(NSData *remoteData);


@interface MIRemoteFile : NSObject {
    dispatch_queue_t _queue;
}

@property (nonatomic, strong) NSString *bundlePath;
@property (nonatomic, strong) NSURL *remoteURL;

- (instancetype)initWithBundleResource:(NSString *)name ofType:(NSString *)extension remoteURL:(NSURL *)remoteURL NS_DESIGNATED_INITIALIZER;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSData *data;
- (void)updateWithValidator:(ValidatorBlock)validator;

@end

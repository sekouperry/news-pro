
#import "MIRemoteFile.h"
#import <CommonCrypto/CommonDigest.h>
#import "NINetworkActivity.h"

@implementation MIRemoteFile

- (instancetype)initWithBundleResource:(NSString *)name ofType:(NSString *)extension remoteURL:(NSURL *)remoteURL
{
    if ((self = [super init])) {
        _queue = dispatch_queue_create(NSStringFromClass([self class]).UTF8String, NULL);
        if (name && extension) {
            self.bundlePath = [[NSBundle mainBundle] pathForResource:name ofType:extension];
        }
        self.remoteURL = remoteURL;
    }
    
    return self;
}

- (NSString *)cacheDirectoryPath
{
    NSFileManager *fm = [NSFileManager new];
    NSArray *appSupportURLs = [fm URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *directoryURL = appSupportURLs[0];
    NSString *directoryPath = [directoryURL path];
    if (![fm fileExistsAtPath:directoryPath]) {
       
        [fm createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return directoryPath;
}

- (NSString *)localCachePath
{
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    NSData *data = [[self.remoteURL absoluteString] dataUsingEncoding:NSUTF8StringEncoding];
    CC_SHA1(data.bytes, (int)data.length, digest);
    NSMutableString *filename = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (int ii = 0; ii < CC_SHA1_DIGEST_LENGTH; ii++) {
        [filename appendFormat:@"%02x", digest[ii]];
    }
    return [[self cacheDirectoryPath] stringByAppendingPathComponent:filename];
}

- (NSData *)data
{
    NSFileManager *fm = [NSFileManager new];
    NSString *cachePath = [self localCachePath];
    if ([fm fileExistsAtPath:cachePath]) {
        return [NSData dataWithContentsOfFile:cachePath];
    } else if([fm fileExistsAtPath:self.bundlePath]) {
        return [NSData dataWithContentsOfFile:self.bundlePath];
    } else {
        return nil;
    }
}

- (void)updateWithValidator:(ValidatorBlock)validator
{
    dispatch_async(_queue, ^{
        NINetworkActivityTaskDidStart();
        NSData *data = [NSData dataWithContentsOfURL:self.remoteURL];
        if (data && validator(data)) {
            [data writeToFile:[self localCachePath] atomically:YES];
        }
        NINetworkActivityTaskDidFinish();
    });
}

@end

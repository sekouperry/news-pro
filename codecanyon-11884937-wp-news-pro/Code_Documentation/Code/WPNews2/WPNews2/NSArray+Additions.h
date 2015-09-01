
#import <Foundation/Foundation.h>

@interface NSArray (Additions)

- (NSArray *)partitionedArrayUsingBlock:(id (^)(id))block;
- (NSArray *)filteredArrayUsingBlock:(BOOL (^)(id))block;
- (NSArray *)mappedArrayUsingBlock:(id (^)(id))block;

@end

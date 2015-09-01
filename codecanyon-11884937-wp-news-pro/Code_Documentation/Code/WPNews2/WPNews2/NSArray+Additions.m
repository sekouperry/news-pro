
#import "NSArray+Additions.h"

@implementation NSArray (Additions)

- (NSArray *)partitionedArrayUsingBlock:(id (^)(id))block
{
    NSMutableArray *partitions = [NSMutableArray array];
    id testValue = [[NSObject alloc] init];
    for (id obj in self) {
        id blockValue = block(obj);
        if (![testValue isEqual:blockValue]) {
            testValue = blockValue;
            [partitions addObject:[NSMutableArray array]];
        }
        [(NSMutableArray *)[partitions lastObject] addObject:obj];
    }
    return partitions;
}

- (NSArray *)filteredArrayUsingBlock:(BOOL (^)(id))block
{
    return [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return block(evaluatedObject);
    }]];
}

- (NSArray *)mappedArrayUsingBlock:(id (^)(id))block
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    for (id obj in self) {
        [result addObject:block(obj)];
    }
    return result;
}

@end

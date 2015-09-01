
#import "MIFeedParser.h"
#import "MIXMLUtils.h"

@implementation MIFeedParser

- (instancetype)initWithFeedData:(NSData *)feedData
{
    if ((self = [super init])) {
        self.feedData = feedData;
        self.tagStack = [NSMutableArray array];
    }
    
    return self;
}

NSRegularExpression *_tagPattern;

+ (NSRegularExpression *)tagPattern
{
    if (_tagPattern == nil) {
        _tagPattern = [NSRegularExpression regularExpressionWithPattern:@"<(/|)[^>]*>" options:0 error:nil];
    }
    return _tagPattern;
}

NSRegularExpression *_dupeSpacePattern;

+ (NSRegularExpression *)dupeSpacePattern
{
    if (_dupeSpacePattern == nil) {
        _dupeSpacePattern = [NSRegularExpression regularExpressionWithPattern:@"\\s{2,}" options:0 error:nil];
    }
    return _dupeSpacePattern;
}


- (void)parse:(MIFeedParserCallback)callback {
    self.callbackBlock = callback;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.feedData];
    parser.delegate = self;
    [parser setShouldReportNamespacePrefixes:YES];
    [parser setShouldProcessNamespaces:NO];
    [parser parse];
}

- (NSString *)tagPath {
    NSMutableString *path = [NSMutableString string];
    for (NSDictionary *context in self.tagStack) {
        [path appendFormat:@"/%@", context[@"elementName"]];
    }
    return path;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSDictionary *tag = @{@"elementName": elementName,
                         @"text": [NSMutableString string],
                         @"attributes": attributeDict};
    // push tag onto stack
    [self.tagStack addObject:tag];
    
    if ([[self tagPath] isEqualToString:@"/rss/channel/item"]) {
        self.currentItem = [[MIFeedItem alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [[self.tagStack lastObject][@"text"] appendString:string];
}

- (MIMediaElement *)mediaElementFromAttributes:(NSDictionary *)attrs
{
    MIMediaElement *media = [MIMediaElement new];
    NSString *stringURL = attrs[@"url"];
    media.URL = [NSURL URLWithString:stringURL];
    media.size = CGSizeMake([attrs[@"width"] floatValue], [attrs[@"height"] floatValue]);
    media.type = attrs[@"type"];
    return media;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *tagPath = [self tagPath];
    NSDictionary *context = [self.tagStack lastObject];
    NSDictionary *attrs = context[@"attributes"];
    NSString *text = context[@"text"];

    if ([tagPath isEqualToString:@"/rss/channel/item"]) {
        self.callbackBlock(self.currentItem);
        self.currentItem = nil;
    } else if ([tagPath hasSuffix:@"item/title"]) {
        self.currentItem.title = text;
    } else if ([tagPath hasSuffix:@"item/dc:creator"]) {
        self.currentItem.creator = [MIXMLUtils textFromHTMLString:text xpath:@"*"];
        if (!self.currentItem.creator) {
            self.currentItem.creator = text;
        }
        self.currentItem.creator = [[[self class] tagPattern] stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:@""];
    } else if ([tagPath hasSuffix:@"item/guid"]) {
        self.currentItem.guid = text;
    } else if ([tagPath hasSuffix:@"item/content:encoded"]) {
        self.currentItem.descriptionHTML = text;
        self.currentItem.descriptionText = [MIXMLUtils textFromHTMLString:text xpath:@"//p | //div[not(starts-with(@class, 'field'))]"];
    } else if ([tagPath hasSuffix:@"item/link"]) {
        self.currentItem.link = [NSURL URLWithString:text];
    } else if ([tagPath hasSuffix:@"item/media:thumbnail"]) {
        MIMediaElement *thumbnail = [self mediaElementFromAttributes:attrs];
        if (thumbnail.size.width) {
            [self.currentItem addMediaThumbnail:thumbnail];
        }
    } else if ([tagPath hasSuffix:@"item/media:content"]) {
        [self.currentItem addMediaContent:[self mediaElementFromAttributes:attrs]];
    } else if ([tagPath hasSuffix:@"item/enclosure"]) {
        self.currentItem.enclosureURL = [NSURL URLWithString:context[@"attributes"][@"url"]];
    } else if ([tagPath hasSuffix:@"item/category"]) {
        NSArray *categories = self.currentItem.categories;
        if (categories) {
            self.currentItem.categories = [categories arrayByAddingObject:text];
        } else {
            self.currentItem.categories = @[text];
        }
    } else if ([tagPath hasSuffix:@"item/pubDate"]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc]  initWithLocaleIdentifier:@"en_US_POSIX"];
        [formatter setLocale:locale];
        [formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
        self.currentItem.pubDate = [formatter dateFromString:text];
    }
    
    [self.tagStack removeLastObject];
}

@end

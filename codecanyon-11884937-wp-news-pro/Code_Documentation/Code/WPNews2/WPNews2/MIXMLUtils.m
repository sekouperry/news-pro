
#import "MIXMLUtils.h"
#import <libxml/htmltree.h>
#import <libxml/xpath.h>
#import <libxml/sax.h>

void XPathEach(NSString *xpath, xmlXPathContextPtr ctx, void (^iterator)(xmlNodePtr node))
{
    xmlXPathObjectPtr obj = xmlXPathEval((xmlChar *)[xpath UTF8String], ctx);
    if (!xmlXPathNodeSetIsEmpty(obj->nodesetval)) {
        for (int ii = 0; ii < obj->nodesetval->nodeNr; ii++) {
            xmlNodePtr node = obj->nodesetval->nodeTab[ii];
            iterator(node);
        }
    }
    xmlXPathFreeObject(obj);
}

@implementation MIXMLUtils

+ (NSString *)textFromHTMLString:(NSString *)text xpath:(NSString *)xpath
{
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    
    htmlDocPtr html = htmlReadMemory(data.bytes,(int)data.length, NULL, NULL, 0);
    
    if (html) {
        xmlXPathContextPtr ctx = xmlXPathNewContext((xmlDocPtr)html);
        NSMutableArray *paragraphs = [NSMutableArray array];
        NSCharacterSet *trimChars = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        XPathEach(xpath, ctx, ^(xmlNodePtr node) {
            
            xmlChar *nodeText = xmlNodeGetContent(node);
            
            NSString *nodeString = [[NSString alloc] initWithBytes:nodeText length:xmlStrlen(nodeText) encoding:NSUTF8StringEncoding];
            xmlFree(nodeText);
            
            
            NSString *trimmedString = [nodeString stringByTrimmingCharactersInSet:trimChars];
            if ([trimmedString length]) {
                [paragraphs addObject:trimmedString];
            }
        });
        
        xmlXPathFreeContext(ctx);
        xmlFreeDoc(html);
        
        return [paragraphs componentsJoinedByString:@"\n\n"];
    }
    
    return nil;
}

@end

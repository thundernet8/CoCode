//
//  NSString+AttachmentParser.m
//  CoCode
//
//  Created by wuxueqian on 15/11/29.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "NSString+AttachmentParser.h"
#import "HTMLParser.h"
#import "CCTextAttachment.h"

@implementation NSString(AttachmentParser)

- (NSArray *)attachArray{
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *rawString = self;
    NSError *error = nil;
    
    HTMLParser *parser = [[HTMLParser alloc] initWithString:[NSString stringWithFormat:@"<body>%@</body>", self] error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
    }
    
    HTMLNode *bodyNode = [parser body];
    NSArray *lightBoxNodes = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"lightbox-wrapper" allowPartial:NO];
    for (HTMLNode *lightBoxNode in lightBoxNodes) {
        CCTextAttachmentImage *imageAttach = [[CCTextAttachmentImage alloc] init];
        
        imageAttach.type = CCTextAttachmentTypeImage;
        imageAttach.rawText = [lightBoxNode rawContents];
        imageAttach.text = [lightBoxNode allContents];
        imageAttach.originalUrl = [[NSURL alloc] initWithString:[[lightBoxNode findChildTag:@"a"] getAttributeNamed:@"href"] relativeToURL:[NSURL URLWithString:kBaseUrl]];
        imageAttach.defaultUrl = [[NSURL alloc] initWithString:[[lightBoxNode findChildTag:@"img"] getAttributeNamed:@"src"] relativeToURL:[NSURL URLWithString:kBaseUrl]];
        imageAttach.size = CGSizeMake([[[lightBoxNode findChildTag:@"img"] getAttributeNamed:@"width"] floatValue], [[[lightBoxNode findChildTag:@"img"] getAttributeNamed:@"height"] floatValue]);
        imageAttach.title = [[lightBoxNode findChildTag:@"a"] getAttributeNamed:@"title"];
        
        imageAttach.range = [rawString rangeOfString:imageAttach.rawText];
        
        [array addObject:imageAttach];
    }
    
    NSArray *aNodes = [bodyNode findChildTags:@"a"];
    for (HTMLNode *aNode in aNodes) {
        if (![[aNode getAttributeNamed:@"class"] isEqualToString:@"lightbox"]) {
            
            CCTextAttachmentLink *linkAttach = [[CCTextAttachmentLink alloc] init];
            
            linkAttach.type = CCTextAttachmentTypeLink;
            linkAttach.rawText = [aNode rawContents];
            linkAttach.text = [aNode allContents];
            linkAttach.title = [aNode getAttributeNamed:@"title"];
            linkAttach.url = [[NSURL alloc] initWithString:[aNode getAttributeNamed:@"href"] relativeToURL:[NSURL URLWithString:kBaseUrl]];
            linkAttach.range = [rawString rangeOfString:linkAttach.rawText];
            
            [array addObject:linkAttach];
        }
    }
    
    
    return array;
    
}

@end

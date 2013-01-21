//
//  NPTrayCell.m
//  NikePlus
//
//  Created by Agustin DeCabrera on 12/03/12.
//  Copyright (c) 2012 R/GA. All rights reserved.
//

#import "NPTrayCell.h"
#import "NPTrayItem.h"

#if !__has_feature(objc_arc)
# warning file should be compiled with ARC
#endif


@implementation NPTrayCell

@synthesize object = _object;

- (void)setObject:(NPTrayItem *)item;
{
    _object = item;
    self.textLabel.text = item.title;
    self.imageView.image = item.image;
}

+ (CGFloat)heightForObject:(id)object
{
    return 70;
}

@end

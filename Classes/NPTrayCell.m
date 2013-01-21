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

@synthesize textLabel;
@synthesize imageView;

- (void)configureWithItem:(NPTrayItem*)item
{
    self.textLabel.text = item.title;
    self.imageView.image = item.image;
}

@end

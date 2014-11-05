//
//  Star.m
//  PlummetDown
//
//  Created by Guilherme Oliveira on 16/09/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Star.h"

@implementation Star

@synthesize width;
@synthesize height;
@synthesize boxheight;
@synthesize boxwidth;

- (void)didLoadFromCCB {
    width = 73.f;
    height = 73.f;
    boxwidth = 23.f;
    boxheight = 13.f;
}

@end

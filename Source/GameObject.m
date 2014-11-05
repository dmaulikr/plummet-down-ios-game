//
//  GameObject.m
//  PlummetDown
//
//  Created by Guilherme Oliveira on 18/09/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameObject.h"

@implementation GameObject

static int sort;
static int thePoints;

- (void)initBackground:(CCSprite*)_background resortingBg:(BOOL)resortingBg {
    if (resortingBg) {
        sort = arc4random() % 4;
    }

    NSArray *bg = [NSArray arrayWithObjects:@"bg/fundo1.jpg", @"bg/fundo2.jpg", @"bg/fundo3.jpg", @"bg/fundo4.jpg", nil];
    [_background setSpriteFrame:[CCSpriteFrame frameWithImageNamed:[bg objectAtIndex:sort]]];
}

+ (int)points {
    return thePoints;
}

+ (void)setPoints:(int)p {
    thePoints = p;
}

@end

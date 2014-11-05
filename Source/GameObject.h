//
//  GameObject.h
//  PlummetDown
//
//  Created by Guilherme Oliveira on 18/09/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "AudioHandler.h"
#import "ABGameKitHelper.h"

@interface GameObject : CCNode

- (void)initBackground:(CCSprite*)background resortingBg:(BOOL)resortingBg;
+ (int)points;
+ (void)setPoints:(int)p;

@end

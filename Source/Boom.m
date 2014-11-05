//
//  Boom.m
//  PlummetDown
//
//  Created by Guilherme Oliveira on 03/10/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Boom.h"

@implementation Boom

- (void)didLoadFromCCB {
    CCAnimationManager *animationManager = self.animationManager;
    animationManager.delegate = self;
    [animationManager runAnimationsForSequenceNamed:@"Run"];
}


- (void)completedAnimationSequenceNamed:(NSString *)name {
    [self removeFromParentAndCleanup:YES];
}

- (void)onExit {
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [super onExit];
}

@end

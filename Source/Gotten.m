//
//  Gotten.m
//  PlummetDown
//
//  Created by Guilherme Oliveira on 23/09/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gotten.h"

@implementation Gotten

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

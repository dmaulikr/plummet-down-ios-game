//
//  Blue.m
//  PlummetDown
//
//  Created by Guilherme Oliveira on 24/09/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Blue.h"

@implementation Blue

@synthesize width;
@synthesize height;

- (void)didLoadFromCCB {
    width = 61.f;
    height = 53.f;
}

- (void)playDied {
    CCAnimationManager *animationManager = self.animationManager;
    animationManager.delegate = self;
    [animationManager runAnimationsForSequenceNamed:@"died"];
}

- (void)completedAnimationSequenceNamed:(NSString *)name {
    [self removeFromParentAndCleanup:YES];
    CCScene *scene = [CCBReader loadAsScene:@"GameOver"];
    scene.position = ccp([[CCDirector sharedDirector] viewSize].width / 2, 0);
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)onExit {
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [super onExit];
}
@end

//
//  Blue.h
//  PlummetDown
//
//  Created by Guilherme Oliveira on 24/09/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Blue : CCNode <CCBAnimationManagerDelegate>

@property (nonatomic, readonly) float width;
@property (nonatomic, readonly) float height;

- (void)playDied;

@end

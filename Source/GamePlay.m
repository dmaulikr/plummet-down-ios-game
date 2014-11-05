//
//  GamePlay.m
//  PlummetDown
//
//  Created by Guilherme Oliveira on 16/09/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GamePlay.h"
#import "FlyingSaucer.h"
#import "Star.h"
#import "Blue.h"

@implementation GamePlay {
    Blue *_blue;
    CCNode *_rootNode;
    FlyingSaucer *_flyingSaucer;
    FlyingSaucer *_flyingSaucerTop;
    CCSprite *_tutorial;
    CCSprite *_background;
    
    NSMutableArray *stars;
    NSMutableArray *obstacles;
    NSMutableArray *otherObstaclesLeft;
    NSMutableArray *otherObstaclesRight;
    float velocity;
    float velocityBlue;
    BOOL started;
    BOOL gameOver;
    CCLabelTTF *myLabel;
}

- (void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
    
    velocity = 0.f;
    velocityBlue = 0.f;
    started = FALSE;
    gameOver = FALSE;
    [GameObject setPoints:0];

    myLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", [GameObject points]] fontName:@"EarthNormal" fontSize:28];
    myLabel.position = ccp([[CCDirector sharedDirector] viewSize].width / 2, [[CCDirector sharedDirector] viewSize].height - 20);
    
    stars = [NSMutableArray array];
    obstacles = [NSMutableArray array];
    otherObstaclesLeft = [NSMutableArray array];
    otherObstaclesRight = [NSMutableArray array];
    
    [[AudioHandler sharedAudioHandler] stopBg];
    [[AudioHandler sharedAudioHandler] playBgSpace];
    [super initBackground:_background resortingBg:FALSE];
    [self initFlyingSaucer];
    [self initBlue];
    [self spawnStar];
    [self spawnObstacle];
    [self spawnOtherObstacle];
    
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    [_tutorial removeFromParent];
    started = TRUE;
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    if (_flyingSaucer == nil && !gameOver) {
        CGPoint location = [touch locationInNode:_rootNode];
        _blue.position = ccp(location.x, _blue.position.y);
    }
}

- (void)update:(CCTime)delta {
    if (started) {
        
        velocity += 0.02f;
        velocity = clampf(velocity, 0.f, 10.f);
        
        if (_flyingSaucer != nil) {
            _flyingSaucer.position = ccp(_flyingSaucer.position.x, _flyingSaucer.position.y + velocity);
            _flyingSaucerTop.position = _flyingSaucer.position;
            if (_flyingSaucer.position.y > [[CCDirector sharedDirector] viewSize].height + _flyingSaucer.height) {
                [_rootNode removeChild:_flyingSaucer];
                [_rootNode removeChild:_flyingSaucerTop];
                _flyingSaucer = nil;
                _flyingSaucerTop = nil;
                velocity = 1.f;
                [_rootNode addChild:myLabel];
            }
        } else {
            //Blue
            if (_blue.position.y > 1 * ([[CCDirector sharedDirector] viewSize].height / 4)) {
                velocityBlue += 0.0001f;
                _blue.position = ccp(_blue.position.x, _blue.position.y - velocityBlue);
            }
            
            CGRect boundboxBlue = CGRectMake(_blue.position.x - _blue.width / 2, _blue.position.y - _blue.height / 2, _blue.width, _blue.height);

            //Stars movement
            NSMutableArray *starsToRemove = nil;
            for (Star* _star in stars) {
                _star.position = ccp(_star.position.x, _star.position.y + velocity);
                if (_star.position.y > [[CCDirector sharedDirector] viewSize].height + _star.height) {
                    if (!starsToRemove) {
                        starsToRemove = [NSMutableArray array];
                    }
                    [starsToRemove addObject:_star];
                }
                //Check collisions
                if (!gameOver) {
                    if (![starsToRemove containsObject:_star]) {
                        CGRect boundboxStar = CGRectMake(_star.position.x - _star.boxwidth / 2, _star.position.y - _star.boxheight / 2, _star.boxwidth, _star.boxheight);
                        
                        if (CGRectIntersectsRect(boundboxBlue, boundboxStar)) {
                            CCNode *effect = [CCBReader load:@"Gotten"];
                            effect.position = _star.position;
                            [_star setVisible:FALSE];
                            [_rootNode addChild:effect];
                            [[AudioHandler sharedAudioHandler] playStars];
                            if (!starsToRemove) {
                                starsToRemove = [NSMutableArray array];
                            }
                            [starsToRemove addObject:_star];
                            
                            [GameObject setPoints:([GameObject points] + 1)];
                            [myLabel setString:[NSString stringWithFormat:@"%d", [GameObject points]]];
                        }
                    }
                }
            }
            
            for (CCNode* obj in starsToRemove) {
                [obj removeFromParent];
                [stars removeObject:obj];
                [self spawnStar];
            }
            
            //Obstacles movement
            NSMutableArray *obstaclesToRemove = nil;
            for (CCSprite* _obstacle in obstacles) {
                _obstacle.position = ccp(_obstacle.position.x, _obstacle.position.y + velocity);
                if (_obstacle.position.y > [[CCDirector sharedDirector] viewSize].height + _obstacle.boundingBox.size.height) {
                    if (!obstaclesToRemove) {
                        obstaclesToRemove = [NSMutableArray array];
                    }
                    [obstaclesToRemove addObject:_obstacle];
                }

                //Check collisions
                if (!gameOver) {
                    if (![obstaclesToRemove containsObject:_obstacle]) {
                        if (CGRectIntersectsRect(_obstacle.boundingBox, boundboxBlue)) {
                            gameOver = TRUE;
                            if (!obstaclesToRemove) {
                                obstaclesToRemove = [NSMutableArray array];
                            }
                            [obstaclesToRemove addObject:_obstacle];
                            [_blue playDied];
                            [[AudioHandler sharedAudioHandler] playObstacle];
                        }
                    }
                }
            }
            
            for (CCSprite* obj in obstaclesToRemove) {
                [obj removeFromParent];
                [obstacles removeObject:obj];
                [self spawnObstacle];
            }
            
            //Other Obstacles movement Left
            NSMutableArray *otherObstaclesLeftToRemove = nil;
            for (CCSprite* _obstacle in otherObstaclesLeft) {
                _obstacle.position = ccp(_obstacle.position.x + velocity, _obstacle.position.y + (velocity / 2));
                if (_obstacle.position.y > [[CCDirector sharedDirector] viewSize].height + _obstacle.boundingBox.size.height) {
                    if (!otherObstaclesLeftToRemove) {
                        otherObstaclesLeftToRemove = [NSMutableArray array];
                    }
                    [otherObstaclesLeftToRemove addObject:_obstacle];
                }
                
                //Check collisions
                if (!gameOver) {
                    if (![otherObstaclesLeftToRemove containsObject:_obstacle]) {
                        if (CGRectIntersectsRect(_obstacle.boundingBox, boundboxBlue)) {
                            gameOver = TRUE;
                            if (!otherObstaclesLeftToRemove) {
                                otherObstaclesLeftToRemove = [NSMutableArray array];
                            }
                            [otherObstaclesLeftToRemove addObject:_obstacle];
                            [_blue playDied];
                            [[AudioHandler sharedAudioHandler] playObstacle];
                        }
                    }
                }
            }
            
            for (CCSprite* obj in otherObstaclesLeftToRemove) {
                [obj removeFromParent];
                [otherObstaclesLeft removeObject:obj];
                [self spawnOtherObstacle];
            }
            
            //Other Obstacles movement Right
            NSMutableArray *otherObstaclesRightToRemove = nil;
            for (CCSprite* _obstacle in otherObstaclesRight) {
                _obstacle.position = ccp(_obstacle.position.x - velocity, _obstacle.position.y + (velocity / 2));
                if (_obstacle.position.y > [[CCDirector sharedDirector] viewSize].height + _obstacle.boundingBox.size.height) {
                    if (!otherObstaclesRightToRemove) {
                        otherObstaclesRightToRemove = [NSMutableArray array];
                    }
                    [otherObstaclesRightToRemove addObject:_obstacle];
                }
                
                //Check collisions
                if (!gameOver) {
                    if (![otherObstaclesRightToRemove containsObject:_obstacle]) {
                        if (CGRectIntersectsRect(_obstacle.boundingBox, boundboxBlue)) {
                            gameOver = TRUE;
                            if (!otherObstaclesRightToRemove) {
                                otherObstaclesRightToRemove = [NSMutableArray array];
                            }
                            [otherObstaclesRightToRemove addObject:_obstacle];
                            [_blue playDied];
                            [[AudioHandler sharedAudioHandler] playObstacle];
                        }
                    }
                }
            }
            
            for (CCSprite* obj in otherObstaclesRightToRemove) {
                [obj removeFromParent];
                [otherObstaclesRight removeObject:obj];
                [self spawnOtherObstacle];
            }

        }
    }
}

- (void)spawnStar {
    Star* star = (Star*)[CCBReader load:@"Star"];
    float width = ([[CCDirector sharedDirector] viewSize].width - star.width);
    float x = arc4random() % (int)width;
    x += star.width / 2;
    star.position = ccp(x, -star.height);
    [_rootNode addChild:star];
    [stars addObject:star];
}

- (void)spawnObstacle {
    int sort = arc4random() % 6;
    NSArray *obj = [NSArray arrayWithObjects:@"obj/plataforma1.png", @"obj/plataforma2.png", @"obj/plataforma3.png", @"obj/plataforma4.png", @"obj/plataforma5.png", @"obj/plataforma6.png", nil];
    CCSprite *sp = [CCSprite spriteWithImageNamed:[obj objectAtIndex:sort]];
    float width = ([[CCDirector sharedDirector] viewSize].width - sp.boundingBox.size.width);
    float x = arc4random() % (int)width;
    x += sp.boundingBox.size.width / 2;
    sp.position = ccp(x, -sp.boundingBox.size.height);
    [_rootNode addChild:sp];
    [obstacles addObject:sp];
}

- (void)spawnOtherObstacle {
    int sort = arc4random() % 2;
    if (sort % 2 == 0) {
        [self spawnOtherObstacleLeft];
    } else {
        [self spawnOtherObstacleRight];
    }
}

- (void)spawnOtherObstacleLeft {
    int sort = arc4random() % 3;
    NSArray *obj = [NSArray arrayWithObjects:@"obj/meteoro2.png", @"obj/satelite2.png", @"obj/rocket2.png", nil];
    CCSprite *sp = [CCSprite spriteWithImageNamed:[obj objectAtIndex:sort]];
    float height = ([[CCDirector sharedDirector] viewSize].height - sp.boundingBox.size.height - ([[CCDirector sharedDirector] viewSize].height - _blue.position.x));
    float y = arc4random() % (int)height;
    y += sp.boundingBox.size.height / 2;
    sp.position = ccp(-sp.boundingBox.size.width, y);
    [_rootNode addChild:sp];
    [otherObstaclesLeft addObject:sp];
}

- (void)spawnOtherObstacleRight {
    int sort = arc4random() % 3;
    NSArray *obj = [NSArray arrayWithObjects:@"obj/meteoro1.png", @"obj/satelite1.png", @"obj/rocket1.png", nil];
    CCSprite *sp = [CCSprite spriteWithImageNamed:[obj objectAtIndex:sort]];
    float height = ([[CCDirector sharedDirector] viewSize].height - sp.boundingBox.size.height - ([[CCDirector sharedDirector] viewSize].height - _blue.position.x));
    float y = arc4random() % (int)height;
    y += sp.boundingBox.size.height / 2;
    sp.position = ccp([[CCDirector sharedDirector] viewSize].width + sp.boundingBox.size.width, y);
    [_rootNode addChild:sp];
    [otherObstaclesRight addObject:sp];
}

- (void)initFlyingSaucer {
    _flyingSaucer.position = ccp(_flyingSaucer.position.x, [[CCDirector sharedDirector] viewSize].height - _flyingSaucer.height);
    _flyingSaucerTop.position = _flyingSaucer.position;
}

- (void)initBlue {
    _blue.position = ccp([[CCDirector sharedDirector] viewSize].width / 2, _flyingSaucer.position.y + 20);
}

- (void)onExit {
    //unschedule selectors to get dealloc to fire off
    [_rootNode stopAllActions];
    [self stopAllActions];
    [_rootNode unscheduleAllSelectors];
    [self unscheduleAllSelectors];
    
    for (CCNode *node in obstacles) {
        [node removeFromParentAndCleanup:YES];
    }
    [obstacles removeAllObjects];
    for (CCNode *node in stars) {
        [node removeFromParentAndCleanup:YES];
    }
    [obstacles removeAllObjects];
    for (CCNode *node in otherObstaclesLeft) {
        [node removeFromParentAndCleanup:YES];
    }
    [obstacles removeAllObjects];
    for (CCNode *node in otherObstaclesRight) {
        [node removeFromParentAndCleanup:YES];
    }
    [obstacles removeAllObjects];
    
    myLabel = nil;
    
    [super onExit];
}

@end

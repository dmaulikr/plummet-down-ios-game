//
//  AudioHandler.h
//  ShipHunt
//
//  Created by Guilherme Oliveira on 14/07/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioHandler : NSObject

@property (nonatomic) BOOL mute;

+ (id)sharedAudioHandler;
- (void)preloadStart;
- (void)playBgMenu;
- (void)playBgSpace;
- (void)playSoundClick;
- (void)playObstacle;
- (void)playStars;
- (void)stopEverything;
- (void)stopBg;

@end

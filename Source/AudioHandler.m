//
//  AudioHandler.m
//  ShipHunt
//
//  Created by Guilherme Oliveira on 14/07/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "AudioHandler.h"

@implementation AudioHandler

@synthesize mute;

+ (id)sharedAudioHandler {
    static AudioHandler *sharedAudioHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAudioHandler = [[self alloc] init];
    });
    return sharedAudioHandler;
}

- (id)init {
    if (self = [super init]) {
        mute = TRUE;
    }
    
    return self;
}

- (void)preloadStart {
    if (mute) {
        if (![[OALSimpleAudio sharedInstance] bgPlaying]) {
            [[OALSimpleAudio sharedInstance] preloadBg:@"plummetdown_trilha.mp3"];
            [[OALSimpleAudio sharedInstance] preloadBg:@"space.mp3"];
            [[OALSimpleAudio sharedInstance] preloadEffect:@"click.mp3"];
            [[OALSimpleAudio sharedInstance] preloadEffect:@"stars.mp3"];
            [[OALSimpleAudio sharedInstance] preloadEffect:@"batida.mp3"];
        }
    }
}

- (void)playBgMenu {
    if (mute) {
        if (![[OALSimpleAudio sharedInstance] bgPlaying]) {
            // play sound effect in a loop
            [[OALSimpleAudio sharedInstance] playBg:@"plummetdown_trilha.mp3" loop:TRUE];
        }
    }
}

- (void)playBgSpace {
    if (mute) {
        if (![[OALSimpleAudio sharedInstance] bgPlaying]) {
            // play sound effect in a loop
            [[OALSimpleAudio sharedInstance] playBg:@"space.mp3" loop:TRUE];
        }
    }
}

- (void)playSoundClick {
    if (mute) {
        [[OALSimpleAudio sharedInstance] playEffect:@"click.mp3"];
    }
}

- (void)playObstacle {
    if (mute) {
        [[OALSimpleAudio sharedInstance] playEffect:@"batida.mp3"];
    }
}

- (void)playStars {
    if (mute) {
        [[OALSimpleAudio sharedInstance] playEffect:@"stars.mp3"];
    }
}

- (void)stopEverything {
    if (mute) {
        [[OALSimpleAudio sharedInstance] stopEverything];
        [[OALSimpleAudio sharedInstance] unloadAllEffects];
    }
}

- (void)stopBg {
    if (mute) {
        [[OALSimpleAudio sharedInstance] stopBg];
    }
}

@end

//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "iRate.h"
#import "GameData.h"

static BOOL *tryRestore = FALSE;

@implementation MainScene {
    CCSprite *_background;
    CCNode *_mainNode;
    CCNode *_creditNode;
    CCButton *_btnCredits;
    CCButton *_btnSound;
    CCButton *_removeAds;
    CCSpriteFrame *muteOff;
    CCSpriteFrame *muteOn;
}

- (void)didLoadFromCCB {
    muteOff = [CCSpriteFrame frameWithImageNamed:@"buttons/botao_audiooff1.png"];
    muteOn = [CCSpriteFrame frameWithImageNamed:@"buttons/botao_audioon1.png"];
    [[AudioHandler sharedAudioHandler] playBgMenu];
    [super initBackground:_background resortingBg:TRUE];
    [self isMute];
    [ABGameKitHelper sharedHelper];

}

- (void)play {
    [[AudioHandler sharedAudioHandler] playSoundClick];
    CCScene *gameplay = [CCBReader loadAsScene:@"GamePlay"];
    gameplay.position = ccp(self.boundingBox.size.width / 2, self.boundingBox.size.height / 2);
    [[CCDirector sharedDirector] replaceScene:gameplay];
}

- (void)rate {
    [[iRate sharedInstance] openRatingsPageInAppStore];
}

- (void)rank {
    [[ABGameKitHelper sharedHelper] showLeaderboard:@"plummetDown"];
}

- (void)credits {
    [[AudioHandler sharedAudioHandler] playSoundClick];
    [_mainNode setVisible:FALSE];
    [_btnCredits setVisible:FALSE];
    [_btnSound setVisible:FALSE];
    [_creditNode setVisible:TRUE];
}

- (void)back {
    [[AudioHandler sharedAudioHandler] playSoundClick];
    [_creditNode setVisible:FALSE];
    [_mainNode setVisible:TRUE];
    [_btnCredits setVisible:TRUE];
    [_btnSound setVisible:TRUE];
}

- (void)mute {
    AudioHandler *audio = [AudioHandler sharedAudioHandler];
    if (audio.mute) {
        [audio playSoundClick];
        [audio stopBg];
        audio.mute = FALSE;
        [_btnSound setBackgroundSpriteFrame:muteOff forState:CCControlStateNormal];
    } else {
        [_btnSound setBackgroundSpriteFrame:muteOn forState:CCControlStateNormal];
        audio.mute = TRUE;
        [audio playSoundClick];
        [audio playBgMenu];
    }
}

- (void)isMute {
    AudioHandler *audio = [AudioHandler sharedAudioHandler];
    if (audio.mute) {
        [_btnSound setBackgroundSpriteFrame:muteOn forState:CCControlStateNormal];
    } else {
        [_btnSound setBackgroundSpriteFrame:muteOff forState:CCControlStateNormal];
    }
}

- (void)checkout {
    NSString *iTunesLink = @"https://itunes.apple.com/app/ship-hunt-free/id909632118";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}

- (void)onExit {
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [super onExit];
}
@end

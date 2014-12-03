//
//  GameOver.m
//  PlummetDown
//
//  Created by Guilherme Oliveira on 23/09/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameOver.h"
#import "GameData.h"
#import <RevMobAds/RevMobAds.h>

@implementation GameOver {
    CCButton *_btnBack;
    CCLabelTTF *_score;
    CCLabelTTF *_best;
    CCSprite *_background;
    
    RevMobBannerView *ad;
}

- (void)didLoadFromCCB {
    [super initBackground:_background resortingBg:FALSE];
    
    if ([GameObject points] > [[GameData sharedGameData] best]) {
        [[ABGameKitHelper sharedHelper] reportScore:[GameObject points] forLeaderboard:@"plummetDown"];
    }
    
    _score = [CCLabelTTF labelWithString:@"" fontName:@"EarthNormal" fontSize:50];
    _score.position = ccp(self.boundingBox.size.width / 2, 251);
    [self addChild:_score];
    _best = [CCLabelTTF labelWithString:@"" fontName:@"EarthNormal" fontSize:40];
    _best.position = ccp(self.boundingBox.size.width / 2, 171);
    [self addChild:_best];
    
    _btnBack.position = ccp((320 - [[CCDirector sharedDirector] viewSize].width) / 2, _btnBack.position.y);
    _score.string = [NSString stringWithFormat:@"%d", [GameObject points]];
    [[GameData sharedGameData] setBest:[GameObject points]];
    [[GameData sharedGameData] save];
    _best.string = [NSString stringWithFormat:@"%d", [[GameData sharedGameData] best]];
    [[AudioHandler sharedAudioHandler] stopBg];
    [[AudioHandler sharedAudioHandler] playBgMenu];
    if (![[GameData sharedGameData] areAdsRemoved]) {
        ad = [[RevMobAds session] bannerView]; // you must retain this object
        [ad loadWithSuccessHandler:^(RevMobBannerView *banner) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                CGFloat scale = [[UIScreen mainScreen] scale];
                if (scale > 1.0)
                {
                    //iPad retina screen
                    banner.frame = CGRectMake(0, [[CCDirector sharedDirector] viewSize].height * scale - 114, 768, 114);
                }
                else
                {
                    //iPad screen
                    banner.frame = CGRectMake(0, [[CCDirector sharedDirector] viewSizeInPixels].height - 114, 768, 114);
                }
            } else {
                banner.frame = CGRectMake(0, [[CCDirector sharedDirector] viewSize].height - 50, 320, 50);
            }
            [[[CCDirector sharedDirector] view] addSubview:banner];
            if (ad == nil) {
                [banner removeFromSuperview];
            }
            NSLog(@"Ad loaded");
        } andLoadFailHandler:^(RevMobBannerView *banner, NSError *error) {
            NSLog(@"Ad error: %@",error);
        } onClickHandler:^(RevMobBannerView *banner) {
            NSLog(@"Ad clicked");
        }];
    }
}

- (void)back {
    [[AudioHandler sharedAudioHandler] playSoundClick];
    if (![[GameData sharedGameData] areAdsRemoved]) {
        [ad removeFromSuperview];
    }
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)rank {
    [[ABGameKitHelper sharedHelper] showLeaderboard:@"plummetDown"];
}

- (void)play {
    [[AudioHandler sharedAudioHandler] playSoundClick];
    if (![[GameData sharedGameData] areAdsRemoved]) {
        [ad removeFromSuperview];
    }
    [super initBackground:_background resortingBg:TRUE];
    CCScene *gameplay = [CCBReader loadAsScene:@"GamePlay"];
    gameplay.position = ccp([[CCDirector sharedDirector] viewSize].width / 2, [[CCDirector sharedDirector] viewSize].height / 2);
    [[CCDirector sharedDirector] replaceScene:gameplay];
}

- (void)onExit {
    //unschedule selectors to get dealloc to fire off
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    _score = nil;
    _best = nil;
    ad = nil;
    
    [super onExit];
}

@end

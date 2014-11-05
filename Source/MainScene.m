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
    if (!tryRestore && ![[GameData sharedGameData] areAdsRemoved]) {
        tryRestore = TRUE;
        //[self restore];
    }
    if ([[GameData sharedGameData] areAdsRemoved]) {
        _removeAds.visible = NO;
        _removeAds.enabled = NO;
    }
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

//------------------ IN APP PURCHASE

#define kRemoveAdsProductIdentifier @"com.dmgogames.PlummetDown.pro"

- (void)tapsRemoveAds {
    NSLog(@"User requests to remove ads");
    
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");
        
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kRemoveAdsProductIdentifier]];
        productsRequest.delegate = self;
        [productsRequest start];
        
    }
    else{
        NSLog(@"User cannot make payments due to parental controls");
        //this is called the user cannot make payments, most likely due to parental controls
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    SKProduct *validProduct = nil;
    int count = [response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void)purchase:(SKProduct *)product {
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restore {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        if(SKPaymentTransactionStateRestored){
            NSLog(@"Transaction state -> Restored");
            //called when the user successfully restores a purchase
            [self doRemoveAds];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
        
    }
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for(SKPaymentTransaction *transaction in transactions){
        switch (transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                [self doRemoveAds]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finnish
                if(transaction.error.code != SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}

- (void)doRemoveAds {
    _removeAds.visible = NO;
    _removeAds.enabled = NO;
    [[GameData sharedGameData] setAreAdsRemoved:TRUE];
    [[GameData sharedGameData] save];
}

- (void)dealloc {
    NSLog(@"deadloc ------");
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}
@end

//
//  GameData.h
//  ShipHunt
//
//  Created by Guilherme Oliveira on 16/07/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameData : NSObject <NSCoding>

@property (nonatomic, assign) int best;
@property (nonatomic, assign) BOOL areAdsRemoved;

+ (id)sharedGameData;
- (void)save;
- (void)setBest:(int)points;

@end

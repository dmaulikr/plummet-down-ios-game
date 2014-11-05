//
//  GameData.m
//  ShipHunt
//
//  Created by Guilherme Oliveira on 16/07/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Math.h"
#import "GameData.h"

@implementation GameData

static NSString* const SSGameDataBestKey = @"best";
static NSString* const SSGameDataAdsKey = @"ads";

+ (instancetype)sharedGameData {
    static GameData *sharedMyGameData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyGameData = [self loadInstance];
    });
    return sharedMyGameData;
}

+(NSString*)filePath
{
    static NSString* filePath = nil;
    if (!filePath) {
        filePath =
        [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
         stringByAppendingPathComponent:@"gamedata"];
    }
    return filePath;
}

+(instancetype)loadInstance
{
    NSData* decodedData = [NSData dataWithContentsOfFile: [GameData filePath]];
    if (decodedData) {
        GameData* gameData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        return gameData;
    }
    
    return [[GameData alloc] init];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        _best = [decoder decodeIntForKey:SSGameDataBestKey];
        _areAdsRemoved = [decoder decodeIntForKey:SSGameDataAdsKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt:self.best forKey: SSGameDataBestKey];
    [encoder encodeInt:self.areAdsRemoved forKey: SSGameDataAdsKey];
}

- (void)save
{
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[GameData filePath] atomically:YES];
}


- (void)setBest:(int)points {
    _best = MAX(points, _best);
}

@end

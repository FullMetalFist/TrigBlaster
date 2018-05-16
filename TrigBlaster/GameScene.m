//
//  GameScene.m
//  TrigBlaster
//
//  Created by Michael Vilabrera on 8/18/15.
//  Copyright (c) 2015 Giving Tree. All rights reserved.
//

@import CoreMotion;

#import "GameScene.h"

@implementation GameScene {
    
    CGSize _winSize;
    SKSpriteNode *_playerSprite;
    
    
}

- (id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        // setup scene
        self.backgroundColor = [SKColor colorWithRed:94.0/255.0 green:63.0/255.0 blue:107.0/255.0 alpha:1.0];
        _winSize = CGSizeMake(size.width, size.height);
        
        _playerSprite = [SKSpriteNode spriteNodeWithImageNamed:@"Player"];
        _playerSprite.position = CGPointMake(_winSize.width - 50.0f, 60.0f);
        [self addChild:_playerSprite];
    }
    
    return self;
}

- (void)update:(NSTimeInterval)currentTime {
    // called before each frame is rendered
}

@end

//
//  GameScene.m
//  TrigBlaster
//
//  Created by Michael Vilabrera on 8/18/15.
//  Copyright (c) 2015 Giving Tree. All rights reserved.
//

@import CoreMotion;

#import "GameScene.h"

const float MaxPlayerAccel = 400.0f;
const float MaxPlayerSpeed = 200.0f;

@implementation GameScene {
    
    CGSize _winSize;
    SKSpriteNode *_playerSprite;
    
    UIAccelerationValue _accelerometerX;
    UIAccelerationValue _accelerometerY;
    
    CMMotionManager *_motionManager;
    
    float _playerAccelX;
    float _playerAccelY;
    float _playerSpeedX;
    float _playerSpeedY;
    
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _deltaTime;
}

- (id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        // setup scene
        self.backgroundColor = [SKColor colorWithRed:94.0/255.0 green:63.0/255.0 blue:107.0/255.0 alpha:1.0];
        _winSize = CGSizeMake(size.width, size.height);
        
        _playerSprite = [SKSpriteNode spriteNodeWithImageNamed:@"Player"];
        _playerSprite.position = CGPointMake(_winSize.width - 50.0f, 60.0f);
        [self addChild:_playerSprite];
        
        // activate accelerometer
        _motionManager = [[CMMotionManager alloc] init];
        [self startMonitoringAcceleration];
    }
    
    return self;
}

- (void)updatePlayerAccelerationFromMotionManager {
    const double FilteringFactor = 0.75;
    CMAcceleration acceleration = _motionManager.accelerometerData.acceleration;
    _accelerometerX = acceleration.x * FilteringFactor + _accelerometerX * (1.0 - FilteringFactor);
    _accelerometerY = acceleration.y * FilteringFactor + _accelerometerY * (1.0 - FilteringFactor);
    
    // Y runs from left to right (X axis)
    if (_accelerometerY > 0.05) {
        _playerAccelX = -MaxPlayerAccel;
    }
    else if (_accelerometerY < 0.05) {
        _playerAccelX = MaxPlayerAccel;
    }
    
    // X runs from top to bottom (Y axis)
    if (_accelerometerX > 0.05) {
        _playerAccelY = -MaxPlayerAccel;
    }
    else if (_playerAccelX < 0.05) {
        _playerAccelY = MaxPlayerAccel;
    }
}

- (void)updatePlayer:(NSTimeInterval)dt {
    
    _playerSpeedX += _playerAccelX * dt;
    _playerSpeedY += _playerAccelY * dt;
    
    _playerSpeedX = fmaxf(fminf(_playerSpeedX, MaxPlayerSpeed), -MaxPlayerSpeed);
    _playerSpeedY = fmaxf(fminf(_playerSpeedY, MaxPlayerSpeed), -MaxPlayerSpeed);
    
    float newX = _playerSprite.position.x + _playerSpeedX * dt;
    float newY = _playerSprite.position.y + _playerSpeedY * dt;
    
    newX = MIN(_winSize.width, MAX(newX, 0));
    newY = MIN(_winSize.height, MAX(newY, 0));
    
    _playerSprite.position = CGPointMake(newX, newY);
}

- (void)startMonitoringAcceleration {
    if (_motionManager.accelerometerAvailable) {
        [_motionManager startAccelerometerUpdates];
        NSLog(@"accelerometer updates on");
    }
}

- (void)stopMonitoringAcceleration {
    if (_motionManager.accelerometerAvailable && _motionManager.accelerometerActive) {
        [_motionManager stopAccelerometerUpdates];
        NSLog(@"accelerometer updates off");
    }
}

- (void)update:(NSTimeInterval)currentTime {
    // called before each frame is rendered
    if (_lastUpdateTime) {
        _deltaTime = currentTime - _lastUpdateTime;
    } else {
        _deltaTime = 0;
    }
    _lastUpdateTime = currentTime;
    
    [self updatePlayerAccelerationFromMotionManager];
    [self updatePlayer:_deltaTime];
}



- (void)dealloc {
    [self stopMonitoringAcceleration];
    _motionManager = nil;
}
@end

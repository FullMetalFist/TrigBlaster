//
//  GameScene.m
//  TrigBlaster
//
//  Created by Michael Vilabrera on 8/18/15.
//  Copyright (c) 2015 Giving Tree. All rights reserved.
//

@import CoreMotion;

#import "GameScene.h"

const CGFloat MaxPlayerAccel = 400.0f;
const CGFloat MaxPlayerSpeed = 200.0f;

@implementation GameScene {
    CGSize _winSize;
    SKSpriteNode *_playerSprite;
    UIAccelerationValue _accelerometerX;
    UIAccelerationValue _accelerometerY;
    
    CMMotionManager *_motionManager;
    
    CGFloat _playerAccelX;
    CGFloat _playerAccelY;
    CGFloat _playerSpeedX;
    CGFloat _playerSpeedY;
    
    CFTimeInterval _lastUpdateTime;
    CFTimeInterval _deltaTime;
}


-(instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:94.0/255.0 green:63.0/255.0 blue:107.0/255.0 alpha:1.0];
        
        _winSize = CGSizeMake(size.width, size.height);
        
        _playerSprite = [SKSpriteNode spriteNodeWithImageNamed:@"Player"];
        _playerSprite.position = CGPointMake(_winSize.width - 50.0f, 60.0f);
        [self addChild:_playerSprite];
        
        _motionManager = [[CMMotionManager alloc] init];
        [self startMonitoringAcceleration];
    }
    return self;
}

-(void)updatePlayerAccelerationFromMotionManager {
    const CGFloat FilteringFactor = 0.75;
    
    CMAcceleration acceleration = _motionManager.accelerometerData.acceleration;
    _accelerometerX = acceleration.x * FilteringFactor + _accelerometerX * (1.0 - FilteringFactor);
    _accelerometerY = acceleration.y * FilteringFactor + _accelerometerY * (1.0 - FilteringFactor);
    
    /*
     the following is due to the fact that we are in landscape mode! (X => Y and Y => X)
     */
    if (_accelerometerY > 0.05) {
        _playerAccelX = -MaxPlayerAccel;
    }
    else if (_accelerometerY < -0.05) {
        _playerAccelX = MaxPlayerAccel;
    }
    if (_accelerometerX < 0.05) {
        _playerAccelY = -MaxPlayerAccel;
    }
    else if (_accelerometerX > 0.05) {
        _playerAccelY = MaxPlayerAccel;
    }
}

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    // to compute velocities we need delta time to multiply points per second
    // SpriteKit returns the currentTime, delta is computed as lastTime - currentTime
    if (_lastUpdateTime) {
        _deltaTime = currentTime - _lastUpdateTime;
    } else {
        _deltaTime = 0;
    }
    _lastUpdateTime = currentTime;
    
    [self updatePlayerAccelerationFromMotionManager];
    [self updatePlayer:_deltaTime];
}

-(void)updatePlayer:(CFTimeInterval)dt {
    // 1
    _playerSpeedX += _playerAccelX * dt;
    _playerSpeedY += _playerAccelY * dt;
    
    // 2
    _playerSpeedX = fmaxf(fminf(_playerSpeedX, MaxPlayerSpeed), -MaxPlayerSpeed);
    _playerSpeedY = fmaxf(fminf(_playerSpeedY, MaxPlayerSpeed), -MaxPlayerSpeed);
    
    // 3
    CGFloat newX = _playerSprite.position.x + _playerSpeedX * dt;
    CGFloat newY = _playerSprite.position.y + _playerSpeedY * dt;
    
    // 4
    newX = MIN(_winSize.width, MAX(newX, 0));
    newY = MIN(_winSize.height, MAX(newY, 0));
    
    _playerSprite.position = CGPointMake(newX, newY);
}

-(void)startMonitoringAcceleration {
    if (_motionManager.accelerometerAvailable) {
        [_motionManager startAccelerometerUpdates];
        NSLog(@"accelerometer updates on");
    }
}

-(void)stopMonitoringAcceleration {
    if (_motionManager.accelerometerAvailable && _motionManager.accelerometerActive) {
        [_motionManager stopAccelerometerUpdates];
        NSLog(@"accelerometer updates off");
    }
}

-(void)dealloc{
    [self stopMonitoringAcceleration];
    _motionManager = nil;
}

@end

//
//  GameScene.m
//  TrigBlaster
//
//  Created by Michael Vilabrera on 8/18/15.
//  Copyright (c) 2015 Giving Tree. All rights reserved.
//

@import CoreMotion;

#import "GameScene.h"

#define SK_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f) // PI / 180
#define SK_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f)   // PI * 180

const CGFloat MaxPlayerAccel = 400.0f;
const CGFloat MaxPlayerSpeed = 200.0f;
const CGFloat BorderCollisionDamping = 0.4f;

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
    
    CGFloat _playerAngle;
    CGFloat _lastAngle;
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
//    newX = MIN(_winSize.width, MAX(newX, 0));
//    newY = MIN(_winSize.height, MAX(newY, 0));
    BOOL collidedWithVerticalBorder = NO;
    BOOL collidedWithHorizontalBorder = NO;
    
    if (newX < 0.0f) {
        newX = 0.0f;
        collidedWithVerticalBorder = YES;
    } else if (newX > _winSize.width) {
        newX = _winSize.width;
        collidedWithVerticalBorder = YES;
    }
    
    if (newY < 0.0f) {
        newY = 0.0f;
        collidedWithHorizontalBorder = YES;
    } else if (newY > _winSize.height) {
        newY = _winSize.height;
        collidedWithHorizontalBorder = YES;
    }
    
    if (collidedWithVerticalBorder) {
        _playerAccelX = -_playerAccelX * BorderCollisionDamping;
        _playerSpeedX = -_playerSpeedX * BorderCollisionDamping;
        _playerAccelY = _playerAccelY * BorderCollisionDamping;
        _playerSpeedY = _playerSpeedY * BorderCollisionDamping;
    }
    
    if (collidedWithHorizontalBorder) {
        _playerAccelX = _playerAccelX * BorderCollisionDamping;
        _playerSpeedX = _playerSpeedX * BorderCollisionDamping;
        _playerAccelY = -_playerAccelY * BorderCollisionDamping;
        _playerSpeedY = -_playerSpeedY * BorderCollisionDamping;
    }
    
    _playerSprite.position = CGPointMake(newX, newY);
    
    CGFloat speed = sqrtf(_playerSpeedX * _playerSpeedX + _playerSpeedY * _playerSpeedY);
    if (speed > 40.0f) {
        CGFloat angle = atan2f(_playerSpeedY, _playerSpeedX);
        
        // did the angle flip from +π to -π, or from -π to +π?
        if (_lastAngle < -3.0f && angle > 3.0f) {
            _playerAngle += M_PI * 2.0f;
        }
        else if (_lastAngle > 3.0f && angle < -3.0f) {
            _playerAngle -= M_PI * 2.0f;
        }
        _lastAngle = angle;
        
        const CGFloat RotationBlendFactor = 0.2f;
        _playerAngle = angle * RotationBlendFactor + _playerAngle * (1.0f - RotationBlendFactor);
    }
    _playerSprite.zRotation = _playerAngle - SK_DEGREES_TO_RADIANS(90);
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

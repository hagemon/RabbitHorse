//
//  GameScene.m
//  RabbitHorse
//
//  Created by 一折 on 15/1/24.
//  Copyright (c) 2015年 乐艺泽. All rights reserved.
//

#import "GameScene.h"
#import "GameOverScene.h"
#define MAXTEETH 5
#define MAXBLOOD 10

@import AVFoundation;

const uint32_t teethCategory=0x1<<0;
const uint32_t redCarrotCategory=0x1<<1;
const uint32_t blueCarrotCategory=0x1<<2;
const uint32_t horseCategory=0x1<<3;
const uint32_t groundCategory=0x1<<4;
@interface GameScene()
@property (nonatomic) SKSpriteNode * horse;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval lastCarrotShoot;
@property (nonatomic) NSDate* startTime;
@property (nonatomic) int runTime;
@property (nonatomic) int teethNum;
@property (nonatomic) SKLabelNode *scoreLabel;
@property (nonatomic) SKSpriteNode *blood;
@property (nonatomic) double bloodNum;
@end
@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    NSLog(@"%f,%f",self.frame.size.width,self.frame.size.height);
    /* Setup your scene here */
    self.physicsWorld.contactDelegate=self;
    //设置背景
//    self.backgroundColor=[SKColor whiteColor];
    SKSpriteNode * background=[SKSpriteNode spriteNodeWithImageNamed:@"background"];
    background.position=CGPointMake(self.frame.size.width/2,(self.frame.size.height+90)/2);
    [self addChild:background];
    //添加horse
    _horse=[SKSpriteNode spriteNodeWithImageNamed:@"horse"];
    _horse.position=CGPointMake(60, 100);
    _horse.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:_horse.size];
    _horse.physicsBody.categoryBitMask=horseCategory;
    _horse.physicsBody.collisionBitMask=groundCategory;
    [self addChild:_horse];
    
    //添加ground
    SKSpriteNode * ground =[SKSpriteNode spriteNodeWithImageNamed:@"ground"];
    ground.position=CGPointMake(self.frame.size.width/2, 0);
    ground.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:ground.size];
    ground.physicsBody.dynamic=NO;
    ground.physicsBody.categoryBitMask=groundCategory;
    
    [self addChild:ground];
    //添加sky边界
    SKSpriteNode * sky =[SKSpriteNode spriteNodeWithColor:nil size:CGSizeMake(self.frame.size.width, 1)];
    sky.position=CGPointMake(self.frame.size.width/2, self.frame.size.height);
    sky.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:sky.size];
    sky.physicsBody.dynamic=NO;
    [self addChild:sky];
    
    //添加得分栏
    _scoreLabel=[SKLabelNode labelNodeWithFontNamed:@"YaHei"];
    _scoreLabel.fontSize=30;
    _scoreLabel.fontColor=[SKColor blackColor];
    _scoreLabel.position=CGPointMake(self.frame.size.width-40, self.frame.size.height-40);
    _scoreLabel.text=[NSString stringWithFormat:@"%d",_runTime];
    [self addChild:_scoreLabel];
    
    //添加生命值
    _blood=[SKSpriteNode spriteNodeWithImageNamed:@"blood"];
    _blood.centerRect=CGRectMake(9/19, 9/19, 1/19, 108/120);
    _blood.anchorPoint=CGPointMake(0.5, 0);
    _blood.position=CGPointMake(_scoreLabel.position.x+0.5, _scoreLabel.position.y-150);
    SKSpriteNode * heart=[SKSpriteNode spriteNodeWithImageNamed:@"heart"];
    heart.position=CGPointMake(_blood.position.x+1.5, _blood.position.y-20);
    [self addChild:_blood];
    [self addChild:heart];
    
    //初始化各项数据
    _startTime=[NSDate date];
    _teethNum=MAXTEETH;
    _runTime=0;
    _bloodNum=MAXBLOOD;
}

#pragma 创建

-(void)addCarrot
{
    //萝卜出现位置
    SKSpriteNode *carrot;
    int ranNum=(arc4random()%5);
    if(ranNum<3)
    {
        carrot=[SKSpriteNode spriteNodeWithImageNamed:@"redCarrot"];
        carrot.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:carrot.size];
        carrot.physicsBody.categoryBitMask=redCarrotCategory;
    }
    else
    {
        carrot=[SKSpriteNode spriteNodeWithImageNamed:@"blueCarrot"];
        carrot.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:carrot.size];
        carrot.physicsBody.categoryBitMask=blueCarrotCategory;
    }
    int minY=100+carrot.size.height/2;
    int maxY=self.frame.size.height-carrot.size.height/2;
    int rangeY=maxY-minY;
    int randomY=(arc4random()%rangeY)+minY;
    //创建萝卜
    carrot.position=CGPointMake(self.frame.size.width+carrot.size.width/2, randomY);
    carrot.physicsBody.dynamic=NO;
    //碰撞
    carrot.physicsBody.contactTestBitMask=horseCategory;
    [self addChild:carrot];
    //萝卜的移动
    int minDuration=2;
    int maxDuration=4;
    int duration=maxDuration-minDuration;
    int randomDuartion=(arc4random()%duration)+minDuration;
    SKAction * moveToLeft=[SKAction moveToX:-carrot.size.width/2 duration:randomDuartion];
    SKAction * carrotDisapear=[SKAction removeFromParent];
    [carrot runAction:[SKAction sequence:@[moveToLeft,carrotDisapear]]];
    
}

#pragma 动作

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    bool touchesLeft=0;
    UITouch * touch=[touches anyObject];
    CGPoint location=[touch locationInNode:self];
    if(location.x<self.frame.size.width/2)
        touchesLeft=1;
    if(touchesLeft)
        [self jump];
    else
        [self shoot];
}

-(void)jump{
    [_horse.physicsBody applyImpulse:CGVectorMake(0, 50.0)];
    //卡顿
    [self runAction:[SKAction playSoundFileNamed:@"jumpVoice.wav" waitForCompletion:NO]];
}

-(void)shoot{
    //创建teeth
    if(_teethNum==0)return;
    SKSpriteNode * teeth=[SKSpriteNode spriteNodeWithImageNamed:@"teeth"];
    teeth.position=CGPointMake(_horse.position.x+30, _horse.position.y+6);
    //设置物理特性
    teeth.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:teeth.size];
    teeth.physicsBody.categoryBitMask=teethCategory;
    teeth.physicsBody.contactTestBitMask=0x3<<1;
    teeth.physicsBody.affectedByGravity=NO;
    teeth.physicsBody.usesPreciseCollisionDetection=YES;
    [self addChild:teeth];
    _teethNum--;
    CGPoint teethEnd=CGPointMake(self.frame.size.width, teeth.position.y);
    float duration=2.0;
    SKAction * teethFly=[SKAction moveTo:teethEnd duration:duration];
    SKAction * teethDisapear=[SKAction runBlock:^{[teeth removeFromParent];_teethNum++;}];
    [teeth runAction:[SKAction sequence:@[teethFly,teethDisapear]]];
}
#pragma 碰撞
-(void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    //牙齿吃掉萝卜
    if(firstBody.categoryBitMask&teethCategory)
    {
//        NSLog(@"Carrot disapear!");
        [self teeth:(SKSpriteNode *)firstBody.node didCollideWithCarrot:(SKSpriteNode *)secondBody.node];
        [self runAction:[SKAction playSoundFileNamed:@"eatCarrot.wav" waitForCompletion:NO]];
    }
    //遭遇红萝卜
    else if(firstBody.categoryBitMask&redCarrotCategory)
    {
//        NSLog(@"Eat red carrot!");
        [self carrotDidCollideWithHorse:(SKSpriteNode *)firstBody.node];
        [self runAction:[SKAction playSoundFileNamed:@"eatCarrot.wav" waitForCompletion:NO]];
        //生命值上升
        _bloodNum+=2;
        if(_bloodNum>=10) _bloodNum=10;
//        NSLog(@"blood after eat:%f",_bloodNum);
    }
    //遭遇蓝萝卜
    else if(firstBody.categoryBitMask&blueCarrotCategory)
    {
//        _runTime=[[NSDate date] timeIntervalSinceDate:_startTime];
//        NSLog(@"Eat blue carrot! Game over!");
        NSLog(@"score:%d",_runTime);
        [self carrotDidCollideWithHorse:(SKSpriteNode *)firstBody.node];
        [self gameOver];
    }
}
-(void)teeth:(SKSpriteNode *)teeth didCollideWithCarrot:(SKSpriteNode *)carrot{
    [teeth removeFromParent];
    _teethNum++;
    [carrot removeFromParent];
}
-(void)carrotDidCollideWithHorse:(SKSpriteNode *)carrot{
    [carrot removeFromParent];
}

#pragma 事件

-(void)gameOver
{
    [self runAction:[SKAction playSoundFileNamed:@"horseScream.wav" waitForCompletion:NO]];
    SKAction * overAction=[SKAction runBlock:^{
        SKScene * gameOverScene=[[GameOverScene alloc]initWithSize:self.size runtime:_runTime];
        [self.view presentScene:gameOverScene];
    }];
    [self runAction:overAction];
}

#pragma 更新

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    self.lastCarrotShoot+=timeSinceLast;
    if(self.lastCarrotShoot>0.7)
    {
        self.lastCarrotShoot=0;
        [self addCarrot];
    }
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        _runTime++;
        _bloodNum--;
        NSLog(@"blood now:%f",_bloodNum);
        _scoreLabel.text=[NSString stringWithFormat:@"%d",_runTime];
        [_blood runAction:[SKAction scaleYTo:_bloodNum/MAXBLOOD duration:1]];
        if(_bloodNum==-1) [self gameOver];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1)
    {
        timeSinceLast = 1.0 / 60.0;
    }
    //?
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}

@end

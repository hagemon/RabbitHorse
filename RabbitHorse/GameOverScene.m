//
//  SKScene+GameOverScene.m
//  RabbitHorse
//
//  Created by 一折 on 15/2/5.
//  Copyright (c) 2015年 乐艺泽. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"

@interface GameOverScene()
@property (nonatomic) int score;
@end


@implementation GameOverScene
-(id)initWithSize:(CGSize)size runtime:(double)runtime
{
    _score=runtime;
    return [self initWithSize:size];
}
-(void)didMoveToView:(SKView *)view
{
    self.backgroundColor=[SKColor whiteColor];
    
    NSString * message=@"Game Over";
    NSString * returnMessage=@"Tap To Retrun";
    NSString * scoreMessage=[NSString stringWithFormat:@"Score:%d",_score];
    
    SKLabelNode *label=[SKLabelNode labelNodeWithFontNamed:@"YaHei"];
    SKLabelNode *returnLabel=[SKLabelNode labelNodeWithFontNamed:@"YaHei"];
    SKLabelNode *scoreLabel=[SKLabelNode labelNodeWithFontNamed:@"YaHei"];
    
    label.text=message;
    label.fontSize=40;
    label.fontColor=[SKColor blackColor];
    label.position=CGPointMake(view.frame.size.width/2, view.frame.size.height/2+60);
    
    returnLabel.text=returnMessage;
    returnLabel.fontSize=20;
    returnLabel.fontColor=[SKColor blackColor];
    returnLabel.position=CGPointMake(label.position.x, label.position.y-160);
    
    scoreLabel.text=scoreMessage;
    scoreLabel.fontSize=30;
    scoreLabel.fontColor=[SKColor blackColor];
    scoreLabel.position=CGPointMake(label.position.x, label.position.y-60);
    
    [self addChild:label];
    [self addChild:returnLabel];
    [self addChild:scoreLabel];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self runAction:[SKAction runBlock:^ {
                                              SKTransition *transition=[SKTransition crossFadeWithDuration:0.2];
                                              SKScene *scene=[[GameScene alloc]initWithSize:self.size];
                                              [self.view presentScene:scene transition:transition];
                                          }]];

}
@end

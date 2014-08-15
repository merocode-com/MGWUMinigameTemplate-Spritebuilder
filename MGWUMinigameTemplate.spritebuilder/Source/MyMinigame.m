//
//  MGWUMinigameTemplate
//
//  Created by Zachary Barryte on 6/6/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "MyMinigame.h"
#import "CCPhysics+ObjectiveChipmunk.h"


@implementation MyMinigame
{
    CCPhysicsNode *_physicsNode;
}

-(id)init {
    if ((self = [super init])) {
        // Initialize any arrays, dictionaries, etc in here
        self.instructions = @"These are the game instructions :D";
    }
    return self;
}

-(void)didLoadFromCCB {
    // Set up anything connected to Sprite Builder here
    
    // We're calling a public method of the character that tells it to jump!
//    [self.hero jump];
    
    self.userInteractionEnabled = YES;
    
    _physicsNode.collisionDelegate = self;
    
    self.hero.physicsBody.allowsRotation = FALSE;
}

-(void)onEnter {
    [super onEnter];
    // Create anything you'd like to draw here
    
}

-(void)update:(CCTime)delta {
    // Called each update cycle
    // n.b. Lag and other factors may cause it to be called more or less frequently on different devices or sessions
    // delta will tell you how much time has passed since the last cycle (in seconds)
}

-(void)endMinigame {
    // Be sure you call this method when you end your minigame!
    // Of course you won't have a random score, but your score *must* be between 1 and 100 inclusive
    [self endMinigameWithScore:arc4random()%100 + 1];
}

#pragma mark - CCPhysicsCollisionDelegate Callback

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair typeA:(CCNode *)nodeA typeB:(CCNode *)nodeB
{
    
}

#pragma mark - Touch Methods

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:self];
    CGPoint touchLocationInWorld = [self convertToWorldSpace:touchLocation];
    CGPoint touchLocationInHeroNode = [self.hero.parent convertToNodeSpace:touchLocationInWorld];

    self.hero.position = ccp(touchLocationInHeroNode.x, self.hero.position.y);
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

// DO NOT DELETE!
-(MyCharacter *)hero {
    return (MyCharacter *)self.character;
}
// DO NOT DELETE!

@end

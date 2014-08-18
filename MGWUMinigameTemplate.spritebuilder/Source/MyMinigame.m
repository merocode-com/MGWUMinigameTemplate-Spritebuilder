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
    CCLabelTTF *_scoreLabel;
    NSMutableArray *_rocksArray;
    NSMutableArray *_statuesArray;
    
    BOOL _gameOver;
    int _score;
}

-(id)init {
    if ((self = [super init])) {
        // Initialize any arrays, dictionaries, etc in here
        self.instructions = @"Save as many pharaohs as possible \n\n Game ends if : \n  Crashing by big rocks \n OR \n Collecting 100 points";
        
        _gameOver = NO;
        _score = 0;
        _rocksArray = [NSMutableArray array];
        _statuesArray = [NSMutableArray array];
    }
    return self;
}

-(void)didLoadFromCCB {
    // Set up anything connected to Sprite Builder here
    
    self.userInteractionEnabled = YES;
    
    _physicsNode.collisionDelegate = self;
}

-(void)onEnter {
    [super onEnter];
    // Create anything you'd like to draw here
    
    [self schedule:@selector(spawnStatue) interval:2.f];       // Spawn a new statue every .35 seconds
    [self schedule:@selector(spawnRock) interval:5.f];       // Spawn a new rock every 5 seconds
    [self schedule:@selector(updateScoreLabel) interval:0.1f];  // Update the score label every 0.1 seconds
}

- (void)cleanup {
    
    //  cleanup is called before our minigame gets deallocated (which happens after we call endMinigameWithScore)
    //  So we need  to tell the Cocos2d scheduler that we don't need our spawnEnemy and updateScoreLabel methods called anymore
    [self unscheduleAllSelectors];
}

-(void)updateScoreLabel
{
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _score];
}

-(void)spawnStatue
{
    CCSprite *statue;
    statue = (CCSprite *)[CCBReader load:@"amiraelmansyStatue"];
    
    // Spawn statue on the top of the screen, at a random width
    statue.position = ccp(self.contentSizeInPoints.width * CCRANDOM_0_1(), self.contentSizeInPoints.height);
    
    // Statues have a random scale between 50% and 80%
    // Here clampf makes sure the random value is between 0.5f and 0.8f
    statue.scale = clampf(CCRANDOM_0_1(), 0.5f, 0.8f);
    
    // Add the statue to the physics node
    [_physicsNode addChild:statue];
    
    //  Add the statue to our statues array so we can track them
    [_statuesArray addObject:statue];
    
    //  Make the statue spin with a random angular impulse
    //    [rock.physicsBody applyAngularImpulse:CCRANDOM_MINUS1_1() * 15000.0f];
}

-(void)spawnRock
{
    CCSprite *rock;
    rock = (CCSprite *)[CCBReader load:@"amiraelmansyRock"];
    
    // Spawn rocks on the top of the screen, at a random width
    rock.position = ccp(self.contentSizeInPoints.width * CCRANDOM_0_1(), self.contentSizeInPoints.height);
    
    // Rocks have a random scale between 50% and 100%
    // Here clampf makes sure the random value is between 0.5f and 1.0f
    rock.scale = clampf(CCRANDOM_0_1(), 0.5f, 1.0f);
    
    // Add the rock to the physics node
    [_physicsNode addChild:rock];
    
    //  Add the rock to our rocks array so we can track them
    [_rocksArray addObject:rock];
    
    //  Make the rock spin with a random angular impulse
//    [rock.physicsBody applyAngularImpulse:CCRANDOM_MINUS1_1() * 15000.0f];
}

-(void)removeStatue:(CCSprite *)statue withParticles:(BOOL)particles
{
    if (particles)
    {
        // load particle effect
        CCParticleSystem *crash = (CCParticleSystem *)[CCBReader load:@"amiraelmansyStatueCrash"];
        
        // make the particle effect clean itself up, once it is completed
        crash.autoRemoveOnFinish = TRUE;
        
        // place the particle effect on the statue position
        crash.position = statue.position;
        
        // add the particle effect to the same node the statue is on
        [statue.parent addChild:crash];
    }
    
    [statue removeFromParent];
}

-(void)removeRock:(CCSprite *)rock withParticles:(BOOL)particles
{
    if (particles)
    {
        // load particle effect
        CCParticleSystem *crash = (CCParticleSystem *)[CCBReader load:@"amiraelmansyRockCrash"];
        
        // make the particle effect clean itself up, once it is completed
        crash.autoRemoveOnFinish = TRUE;
        
        // place the particle effect on the rock position
        crash.position = rock.position;
        
        // add the particle effect to the same node the rock is on
        [rock.parent addChild:crash];
    }
    
    [rock removeFromParent];
}

-(void)update:(CCTime)delta {
    // Called each update cycle
    // n.b. Lag and other factors may cause it to be called more or less frequently on different devices or sessions
    // delta will tell you how much time has passed since the last cycle (in seconds)
    
    if (_gameOver)
    {
        [self endMinigame];
    }
}

-(void)endMinigame {
    // Be sure you call this method when you end your minigame!
    // Of course you won't have a random score, but your score *must* be between 1 and 100 inclusive
    NSLog(@"Game Over with Score = %d", _score);
    [self endMinigameWithScore:_score];
}

#pragma mark - CCPhysicsCollisionDelegate Callback

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair HeroCollision:(CCNode *)hero StatueCollision:(CCNode *)statue
{
    [[_physicsNode space] addPostStepBlock:^{
                                                [self removeStatue:(CCSprite *)statue withParticles:NO];
                                            }
                                            key:statue];
    
    _score += 10;
    if (_score == 100)
    {
        _gameOver = YES;
    }
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair HeroCollision:(CCNode *)hero RockCollision:(CCNode *)rock
{
    [[_physicsNode space] addPostStepBlock:^{
                                                [self removeRock:(CCSprite *)rock withParticles:NO];
                                            }
                                            key:rock];
    
    //  If we hit a rock, it's game over!
    _gameOver = YES;
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair groundCollision:(CCNode *)ground RockCollision:(CCNode *)rock
{
    [[_physicsNode space] addPostStepBlock:^{
                                                [self removeRock:(CCSprite *)rock withParticles:YES];
                                            }
                                            key:rock];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair groundCollision:(CCNode *)ground StatueCollision:(CCNode *)statue
{
    [[_physicsNode space] addPostStepBlock:^{
                                                [self removeStatue:(CCSprite *)statue withParticles:YES];
                                            }
                                            key:statue];
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

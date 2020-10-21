//
//  PannableViewController.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 5/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "PannableViewController.h"

#define kThresholdVelocity 500.0
#define kSlideAnimationDuration 0.25

@interface PannableViewController ()

@end

@implementation PannableViewController

static CGPoint awayCenter;
static CGPoint originCenter;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanned:)];
    [panGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    ////init as window size
    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    self.view.frame = CGRectMake(0, 0, windowSize.width, windowSize.height);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    awayCenter = CGPointMake(self.view.frame.size.width * 1.3, self.view.center.y);
    originCenter = self.view.center;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)panAway
{
    [UIView animateWithDuration:kSlideAnimationDuration animations:^{
        self.view.center = awayCenter;
    }];
}

- (void)panBack
{
    [UIView animateWithDuration:kSlideAnimationDuration animations:^{
        self.view.center = originCenter;
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:self.view];
    
    UIView* touchedView = [self.view hitTest:location withEvent:nil];
    
    if([touchedView isKindOfClass:[UIControl class]])
    {
        return NO;
    }
    
    return YES;
}


- (void)onPanned:(UIPanGestureRecognizer*)panGestureRecognizer
{
    static CGPoint beganCenter;
    
    switch (panGestureRecognizer.state) {
            
        case UIGestureRecognizerStateBegan:
        {
            beganCenter = panGestureRecognizer.view.center;
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [panGestureRecognizer translationInView:self.view];
            
            if(([self isSamePoint:beganCenter point:originCenter] && translation.x > 0) || //from origin to the right
               ([self isSamePoint:beganCenter point:awayCenter] && translation.x < 0) || //from origin to the left
               (beganCenter.x > originCenter.x && beganCenter.x < awayCenter.x) // everything in between
               )
            {
                //pan!
                panGestureRecognizer.view.center = CGPointMake(beganCenter.x + translation.x, beganCenter.y);
                
                //NSLog(@"beganCenter.x %f", beganCenter.x);
                //NSLog(@"translation.x %f", translation.x);
                
            }
            
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            //NSLog(@"State: %ld", panGestureRecognizer.state);
            
            CGPoint destinationPoint = self.view.center;
            
            CGPoint translation = [panGestureRecognizer translationInView:self.view];
            
            if([self isSamePoint:beganCenter point:originCenter])
            {
                //from origin to the right
                
                if(translation.x > 0)
                {
                    destinationPoint = awayCenter;
                    
                }else{
                    
                    //no pan
                    destinationPoint = originCenter;
                }
                
            }else if([self isSamePoint:beganCenter point:awayCenter]){
                
                //if away pan to the left
                
                if(translation.x < 0)
                {
                    destinationPoint = originCenter;
                    
                }else{
                    
                    //no pan
                    destinationPoint = awayCenter;
                }
            }else{
                
                //began point is not either
                CGFloat distantAway = fabs(self.view.center.x - awayCenter.x);
                CGFloat distantOrigin = fabs(self.view.center.x - originCenter.x);
                
                if(distantAway < distantOrigin)
                {
                    destinationPoint = awayCenter;
                    
                }else{
                    destinationPoint = originCenter;
                }
            }
            
            BOOL velocityValid = NO;
            
            CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
            //NSLog(@"velocity %f", velocity.x);
            
            if(fabs(velocity.x) > kThresholdVelocity)
            {
                velocityValid = YES;
                
            }else{
                
                velocityValid = NO;
            }
            
            BOOL locationValid = NO;
            
            //move enough
            if(fabs(translation.x) > fabs(awayCenter.x - originCenter.x) / 2)
            {
                locationValid = YES;
            }
            
            
            if(locationValid || velocityValid)
            {
                //valid
                [UIView animateWithDuration:kSlideAnimationDuration animations:^{
                    
                    panGestureRecognizer.enabled = NO;
                    panGestureRecognizer.view.center = destinationPoint;
                    
                } completion:^(BOOL finish){

                    panGestureRecognizer.enabled = YES;
                }];
                
            }else{
                
                //invalid
                [UIView animateWithDuration:kSlideAnimationDuration animations:^{
                    
                    panGestureRecognizer.enabled = NO;
                    panGestureRecognizer.view.center = beganCenter;

                } completion:^(BOOL finish){

                    panGestureRecognizer.enabled = YES;
                }];
            }
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)isSamePoint:(CGPoint)point point:(CGPoint)anotherPoint
{
    return (point.x == anotherPoint.x) && (point.y == anotherPoint.y);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

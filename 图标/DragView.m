#import "DragView.h"
#import "Base64.h"

@implementation DragView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (CGRectGetWidth(frame) <= 0 ||
        CGRectGetHeight(frame) <= 0) {
        frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 70, 130, 60, 60);
    }
    
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        //self.layer.borderWidth = 0.95f;
        //self.backgroundColor = [UIColor blackColor];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
        self.alpha = 50.0f;
        
        //3秒后触发图片png，延时
     
      
        NSString *menuButtonBase64 = LOGConfig;
       
            NSData* data = [[NSData alloc] initWithBase64EncodedString:menuButtonBase64 options:0];
            UIImage* menuButtonImage = [UIImage imageWithData:data];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            self.layer.contents = (id)menuButtonImage.CGImage;
        });
        
    
        
        
        
//        NSString *path = @"/Library/MobileSubstrate/DynamicLibraries/HK/HK.png";
//        UIImage *decodedImage = [UIImage imageWithContentsOfFile:path];
        
    }
    return self;
}

#pragma mark - override

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.superview];
    self.center = point;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self shouldResetFrame];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self shouldResetFrame];
}

#pragma mark - private

- (void)shouldResetFrame
{
    CGFloat midX = CGRectGetWidth(self.superview.frame)*0.5;
    CGFloat midY = CGRectGetHeight(self.superview.frame)*0.5;
    CGFloat maxX = midX*2;
    CGFloat maxY = midY*2;
    CGRect frame = self.frame;

    if (CGRectGetMinX(frame) < 0 ||
        CGRectGetMidX(frame) <= midX) {
        frame.origin.x = 0;
    }else if (CGRectGetMidX(frame) > midX ||
              CGRectGetMaxX(frame) > maxX) {
        frame.origin.x = maxX - CGRectGetWidth(frame);
    }

    if (CGRectGetMinY(frame) < 0) {
        frame.origin.y = 0;
    }else if (CGRectGetMaxY(frame) > maxY) {
        frame.origin.y = maxY - CGRectGetHeight(frame);
    }

    [UIView animateWithDuration:0.25 animations:^{
        //CGFloat width = MAX([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
        //self.frame = CGRectMake(width-70, 100, 65, 65);
        //self.frame = frame;
    }];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end

#import "ViewController.h"
#import "DragView.h"
#import "metalbiew.h"
#import "DrawData.h"

@interface ViewController ()
@property (nonatomic, strong) metalbiew *vna;


@end
UILabel *Ttime;
UIDevice *myDevice;
NSDateFormatter *ttime;

@implementation ViewController


static BOOL MenDeal;
static ViewController *extraInfo;


+(void)load
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        extraInfo =  [ViewController new];
        [extraInfo initTapGes];
        [extraInfo iniview];
        NSLog(@"启动");
    });
    
}


-(void)initTapGes
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.numberOfTapsRequired = 2; // 点击次数
    tap.numberOfTouchesRequired = 2; // 手指数
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0].rootViewController.view addGestureRecognizer:tap];
    [tap addTarget:self action:@selector(onConsoleButtonTapped:)];
}

-(void)绘制菜单{
    [DrawData Menu];
}

-(void)onConsoleButtonTapped:(id)sender
{
    if (!_vna) {
        metalbiew *vc = [[metalbiew alloc] init];
        _vna = vc;
    }
    [metalbiew showChange:true:false:false];
    [[UIApplication sharedApplication].windows[0].rootViewController.view addSubview:_vna.view];
}

- (void)iniview
{
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    Ttime = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 4 - 5, 0, [UIScreen mainScreen].bounds.size.width / 2 + 10, 20)];
    Ttime.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:15.0];
    Ttime.backgroundColor = [UIColor clearColor]; // 设置背景为空白
    Ttime.layer.cornerRadius = 12;
    Ttime.textAlignment = NSTextAlignmentCenter;
    Ttime.layer.masksToBounds = true;
    
    // 初始字体颜色为黑色
    Ttime.textColor = [UIColor blackColor];
    
    [mainWindow addSubview:Ttime];

    // 开启定时器，每秒更新一次字体颜色
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateFontColor) userInfo:nil repeats:YES];
}

- (void)updateFontColor
{
    myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];
    double batLeft = (float)[myDevice batteryLevel] * 100;
    // 时间
    ttime = [[NSDateFormatter alloc] init];
    [ttime setDateFormat:@"yyyy/MM/dd • hh:mm:ss"];
    // 随机生成字体颜色
    CGFloat red = arc4random_uniform(256) / 255.0;
    CGFloat green = arc4random_uniform(256) / 255.0;
    CGFloat blue = arc4random_uniform(256) / 255.0;
    Ttime.textColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    Ttime.text = [NSString stringWithFormat:@"二指双击打开菜单 %@  %0.0f🧸 ", [ttime stringFromDate:[NSDate date]], batLeft];
}




@end

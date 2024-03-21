#import "metalbiew.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#include "imgui.h"
#import "Font.h"
#import "baidu_font.h"
#include "imgui_impl_metal.h"
#include <JRMemory/MemScan.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <ViewController.h>
#include "memory_tools.h"

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height


#define iPhone8P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
@interface metalbiew ()<MTKViewDelegate>
@property (nonatomic, strong) IBOutlet MTKView *mtkView;
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;

@property long baseAddres1;
@property long baseAddres2;

@end
@implementation metalbiew
//内存读写
MemoryTools memoryTools;
metalbiew * Metalbiew;
static bool MenDeal = false;
static bool 绘制开关 = false;
static bool 射线开关 = false;
static bool 蜡烛绘制开关 = false;
static bool 金人绘制开关 = false;
static bool 原点绘制开关 = false;
static bool 能量开关 = false;
static bool 加速开关 = false;
static bool 窥屏开关 =false;
static bool 自燃扎花开关 =false;
static bool 吸火开关 =false;
static bool 登陆安卓 = false;
static bool ID登陆 = false;
static int chibang_num = 4;
static float speed_size = 1;
float 能量修改=15;
float 自燃修改=1;
float 炸花修改=0;
//static int 原地传送序号 = 0;
static uintptr_t moudule_base;
int optionItemCurrent = 1;


- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];
    if (!self.device) abort();
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;
    ImGui::StyleColorsDarkMode();
    io.Fonts->AddFontFromMemoryTTF((void *)baidu_font_data, baidu_font_size, 25.0f, NULL,io.Fonts->GetGlyphRangesChineseFull());
    ImGui_ImplMetal_Init(_device);
    _mtkView.preferredFramesPerSecond = 120;
    return self;
}
+(void)showChange:(BOOL)open :(BOOL)A :(BOOL)B//三指调用
{
    MenDeal = open;
    moudule_base = _dyld_get_image_vmaddr_slide(0);
}
- (MTKView *)mtkView
{
    return (MTKView *)self.view;
}
- (void)loadView
{
    
    self.view = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
    
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.mtkView.device = self.device;
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.mtkView.clipsToBounds = YES;
}
#pragma mark - Interaction

// 在touchesBegan、touchesMoved、touchesEnded和touchesCancelled方法中更新触摸状态
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self updateIOWithTouchEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self updateIOWithTouchEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self updateIOWithTouchEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self updateIOWithTouchEvent:event];
}

// 更新每个触摸点的状态
- (void)updateIOWithTouchEvent:(UIEvent *)event {
    ImGuiIO &io = ImGui::GetIO();
    memset(io.MouseDown, 0, sizeof(io.MouseDown));
    
    for (UITouch *touch in event.allTouches) {
        CGPoint touchLocation = [touch locationInView:self.view];
        io.MousePos = ImVec2(touchLocation.x, touchLocation.y);
        
        NSInteger touchIndex = [event.allTouches.allObjects indexOfObject:touch];
        if (touchIndex >= 0 && touchIndex < IM_ARRAYSIZE(io.MouseDown)) {
            if (touch.phase == UITouchPhaseBegan || touch.phase == UITouchPhaseMoved) {
                io.MouseDown[touchIndex] = true;
            } else {
                io.MouseDown[touchIndex] = false;
            }
        }
    }
}
#pragma mark - MTKViewDelegate
- (void)drawInMTKView:(MTKView*)view
{
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;
    
    CGFloat framebufferScale = view.window.screen.scale ?: UIScreen.mainScreen.scale;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    io.DeltaTime = 1 / float(view.preferredFramesPerSecond ?: 65);
    
    if (iPhone8P){
        io.DisplayFramebufferScale = ImVec2(2.60, 2.60);
    }else{
        io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    }
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    if (MenDeal == true) {
        [self.view setUserInteractionEnabled:YES];
    } else if (MenDeal == false) {
        [self.view setUserInteractionEnabled:NO];
    }
    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil)
    {
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder pushDebugGroup:@"ImGui Jane"];
        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui::NewFrame();
        
        ImFont* font = ImGui::GetFont();
        font->Scale = 12.f / font->FontSize;
        //大小改这里
        CGFloat x = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width) - 380) / 2;
        CGFloat y = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height) - 240) / 2;
        ImGui::SetNextWindowPos(ImVec2(x, y), ImGuiCond_FirstUseEver);
        ImGui::SetNextWindowSize(ImVec2(380, 240), ImGuiCond_FirstUseEver);
#pragma mark - 菜单
        if (MenDeal == true)
        {
            //ImGuiWindowFlags_AlwaysAutoResize == 自动布局
            ImGui::Begin("Sky[国服]", &MenDeal,ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_AlwaysAutoResize);
            if (ImGui::BeginTabBar("选项卡", ImGuiTabBarFlags_NoTooltip))
            {
                if (ImGui::BeginTabItem("主页"))
                {
                    ImGui::TextColored(ImColor(0,255,255),"遇境点击初始化等几秒,没效果再点或者重进");
                            ImGui::Separator();
                            if (ImGui::Button("遇境初始化")) {
                                [self chushihua];
                            }
                            ImGui::Separator();
                            ImGui::Checkbox("无限能量",&能量开关);
                            ImGui::SameLine();
                            ImGui::Checkbox("自然炸花",&自燃扎花开关);
                            ImGui::SameLine();
                            ImGui::Checkbox("吸火",&吸火开关);
                            ImGui::Separator();
                            ImGui::Checkbox("加速", &加速开关);
                            ImGui::SameLine();
                            ImGui::SliderFloat("速度", &speed_size, 1, 10);
                            ImGui::Separator();
                    
                            ImGui::TextColored(ImColor(0,255,255),"本插件研究参考,禁止用于售卖等违法行为。");
                            ImGui::TextColored(ImColor(0,255,255),"In 2024 By:Menus [ %.1fMs / %.1fFps ]", 1000 / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);
                    ImGui::EndTabItem();//结束
                }
                if (ImGui::BeginTabItem("HOOK"))
                {
                    ImGui::TextColored(ImColor(0,255,255),"HOOK功能");
                    ImGui::Checkbox("登陆安卓",&登陆安卓);
                    ImGui::SameLine();
                    ImGui::Checkbox("ID登陆",&ID登陆);
                    ImGui::EndTabItem();//结束
                }
                if (ImGui::BeginTabItem("绘制"))
                {
                    ImGui::TextColored(ImColor(0,255,255),"无处遁形!!!");
                    ImGui::Separator();
                    ImGui::Checkbox("绘制",&绘制开关);
                    ImGui::SameLine();
                    ImGui::Checkbox("射线",&射线开关);
                    ImGui::SameLine();
                    ImGui::Checkbox("金人",&金人绘制开关);
                    ImGui::SameLine();
                    ImGui::Checkbox("原点",&原点绘制开关);
                    ImGui::EndTabItem();//结束
                }
                ImGui::EndTabBar();//结束
            }
            ImGui::End();
        }
        
        ImDrawList*MsDrawList = ImGui::GetForegroundDrawList();//读取整个菜单元素
        [self Draw:MsDrawList];
        
#pragma mark - 方法锁定区(imgui原生循环)
        
        if(窥屏开关){//不知道为啥不加NSLog,我的ipad在Rootless环境中读写地址有问题?可能地址读不对?
            NSLog(@"金人地址:%lu",金人地址);
            NSLog(@"地址:%lu",my坐标地址);
            NSLog(@"能量地址:%lu",能量地址);
            NSLog(@"自燃地址:%lu",自燃地址);
            NSLog(@"炸花地址:%lu",炸花地址);
        }
        
        //这两个功能不要想,我不会开源的
        
//        if(登陆安卓){
//            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"adLogin"];
//        }else{
//            [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"adLogin"];
//        }
//
//        if(ID登陆){
//            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"idLogin"];
//        }else{
//            [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"idLogin"];
//        }
        if (加速开关) {
            memoryTools.writeMemory(速度地址,  sizeof(float), &speed_size);
        }
        if(自燃扎花开关){
            for(int i =0;i<800;i++){
                memoryTools.writeMemory(自燃地址+i*448, sizeof(float), &自燃修改);
            }
            for(int i =0;i<400;i++){
                memoryTools.writeMemory(炸花地址+i*4, sizeof(float), &炸花修改);
            }
        }
        if (能量开关) {
            memoryTools.writeMemory(能量地址,  sizeof(float), &能量修改);
        }
        
        if(吸火开关){
            [self 吸火];
        }
         
#pragma mark - 尾
        ImGui::Render();
        ImDrawData* draw_data = ImGui::GetDrawData();
        ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);
        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    [commandBuffer commit];
    
    
    
    
}
#pragma mark - 其他类

//绘制文字
static void DrawText(ImDrawList* drawList, const char* text, float font_size, const ImVec2& pos, ImColor color, bool center)
{
    // 计算文本大小
    ImVec2 text_size = ImGui::GetFont()->CalcTextSizeA(font_size, FLT_MAX, 0.0f, text);
    
    // 计算文本起始位置
    ImVec2 text_pos = pos;
    if (center)
    {
        text_pos.x -= text_size.x * 0.5f;
        text_pos.y -= text_size.y * 0.5f;
    }
    
    // 绘制文本
    drawList->AddText(ImGui::GetFont(), font_size, text_pos, color, text);
}

typedef struct _cvector2{
    float x;
    float y;
}CVector2;

struct Vector3{
    float X;
    float Y;
    float Z;
};


static float matrix[16];//自己完善,换了个越狱后问题太多放弃封装了
static CVector2 转换屏幕坐标(Vector3 worldPos){
    for (int i = 0; i <= 16; i++) {
        matrix[i]=memoryTools.readFloat(矩阵地址+i*4);
    }
    CVector2 screen;
    float camera = matrix[3] * worldPos.X + matrix[7] * worldPos.Y + matrix[11] * worldPos.Z + matrix[15];
    if (camera < 0.01)
    screen.x = kWidth / 2 + (matrix[0] * worldPos.X + matrix[4] * worldPos.Y + matrix[8] * worldPos.Z + matrix[12]) / camera * kWidth / 2;
    screen.y = kHeight / 2 - (matrix[1] * worldPos.X + matrix[5] * (worldPos.Y + 1.5) + matrix[9] * worldPos.Z + matrix[13]) / camera * kHeight / 2;
    return screen;
}


#pragma mark - 方法修改类
static ImVec4 原点颜色 = ImVec4(1.0f, 0.7f, 1.0f, 1.0f);
static ImVec4 金人颜色 = ImVec4(0.0f, 1.0f, 1.0f, 1.0f); // 青色
static ImVec4 方框颜色 = ImVec4(0.0f, 1.0f, 0.0f, 1.0f);
static ImVec4 圆圈颜色 = ImVec4(1.0f, 0.0f, 1.0f, 1.0f); // 粉色
static ImVec4 my颜色 =  ImVec4(0.0f, 1.0f, 0.0f, 1.0f); // 绿色
static ImVec4 未获取颜色 =  ImVec4(0.8f, 0.2f, 0.8f, 1.0f); // 紫红色
static ImVec4 获取未知颜色 =  ImVec4(1.0f, 1.0f, 0.0f, 1.0f); // 黄色
static ImVec4 蜡烛颜色 = ImVec4(1.0f, 0.0f, 0.0f, 1.0f); // 红色
- (void)Draw:(ImDrawList*)MsDrawList{
    if(绘制开关){
        for (int i = 0; i <= 16; i++) {
            matrix[i]=memoryTools.readFloat(矩阵地址+i*4);
        }
        float myX=memoryTools.readFloat(my坐标地址);
        float myY=memoryTools.readFloat(my坐标地址+4);
        float myZ=memoryTools.readFloat(my坐标地址+8);
        float 距离 = matrix[3] * myX + matrix[7] * myY + matrix[11] * myZ + matrix[15];
        float 自己X = kWidth / 2 + (matrix[0] *myX + matrix[4] * myY + matrix[8] * myZ + matrix[12]) / 距离 * kWidth / 2;
        float 自己Y = kHeight / 2 - (matrix[1] * myX + matrix[5] *myY + matrix[9] * myZ + matrix[13]) / 距离 * kHeight / 2;
        if (距离 > 1){
            DrawText(MsDrawList, "帅哥", 20, ImVec2(自己X, 自己Y-50), ImColor(my颜色), true);
        }
        
        if(金人绘制开关){
            for(int i = 0; i <= memoryTools.readInt(金人地址+3608+320)-1; i++){
                float 金人X=memoryTools.readFloat(金人地址+152+i*320);
                float 金人Y=memoryTools.readFloat(金人地址+152+4+i*320);
                float 金人Z=memoryTools.readFloat(金人地址+152+8+i*320);
                float camera = matrix[3] * 金人X + matrix[7] * 金人Y + matrix[11] * 金人Z + matrix[15];
                float screenX = kWidth / 2 + (matrix[0] *金人X + matrix[4] * 金人Y + matrix[8] * 金人Z + matrix[12]) / camera * kWidth / 2;
                float screenY = kHeight / 2 - (matrix[1] * 金人X + matrix[5] *金人Y+ matrix[9] * 金人Z + matrix[13]) / camera * kHeight / 2;
                float toux= screenX;
                float touy= screenY;
                if (toux > 0 || touy > 0 || toux < kWidth || touy < kHeight) {
                    if (camera > 1){
                        NSString * 拿取;
                        int 金人拿取判断 = memoryTools.readInt((金人地址+320)+48+i*320);
                        if(金人拿取判断==65537){
                            拿取=@"已获取";
                            const char *金人名称=(char*) [[NSString stringWithFormat:@"金人[%d]\n[%dm][%@]",i+1,(int)camera-2,拿取] cStringUsingEncoding:NSUTF8StringEncoding];
                            DrawText(MsDrawList, 金人名称, 12, ImVec2(toux, touy), ImColor(金人颜色), true);
                        }else if(金人拿取判断==16777473){
                            拿取=@"已获取";
                            const char *金人名称=(char*) [[NSString stringWithFormat:@"金人[%d]\n[%dm][%@]",i+1,(int)camera-2,拿取] cStringUsingEncoding:NSUTF8StringEncoding];
                            DrawText(MsDrawList, 金人名称, 12, ImVec2(toux, touy), ImColor(金人颜色), true);
                        }else  if(金人拿取判断==65793){
                            拿取=@"未获取";
                            const char *金人名称=(char*) [[NSString stringWithFormat:@"金人[%d]\n[%dm][%@]",i+1,(int)camera-2,拿取] cStringUsingEncoding:NSUTF8StringEncoding];
                            DrawText(MsDrawList, 金人名称, 12, ImVec2(toux, touy), ImColor(未获取颜色), true);
                            if (射线开关) {
                                MsDrawList->AddLine(ImVec2(自己X, 自己Y+10), ImVec2(toux,touy-5), ImColor(未获取颜色));
                            }
                        }else  if(金人拿取判断==65536){
                            拿取=@"隐藏";
                            const char *金人名称=(char*) [[NSString stringWithFormat:@"金人[%d]\n[%dm][%@]",i+1,(int)camera-2,拿取] cStringUsingEncoding:NSUTF8StringEncoding];
                            DrawText(MsDrawList, 金人名称, 12, ImVec2(toux, touy), ImColor(获取未知颜色), true);
                            if (射线开关) {
                                MsDrawList->AddLine(ImVec2(自己X, 自己Y+10), ImVec2(toux,touy-5), ImColor(获取未知颜色));
                            }
                        }else{
                            拿取=@"升级";
                            const char *金人名称=(char*) [[NSString stringWithFormat:@"金人[%d]\n[%dm][%@]",i+1,(int)camera-2,拿取] cStringUsingEncoding:NSUTF8StringEncoding];
                            DrawText(MsDrawList, 金人名称, 12, ImVec2(toux, touy), ImColor(方框颜色), true);
                        }
                    }
                }
            }
        }
        
        if(原点绘制开关){
            Vector3 worldPos;
            worldPos.X=0;
            worldPos.Y=0;
            worldPos.Z=0;
            float camera = matrix[3] * worldPos.X + matrix[7] * worldPos.Y + matrix[11] * worldPos.Z + matrix[15];
            float screenX = kWidth / 2 + (matrix[0] * worldPos.X + matrix[4] * worldPos.Y + matrix[8] * worldPos.Z + matrix[12]) / camera * kWidth / 2;
            float screenY = kHeight / 2 - (matrix[1] * worldPos.X + matrix[5] * worldPos.Y + matrix[9] * worldPos.Z + matrix[13]) / camera * kHeight / 2;
            float toux= screenX;
            float touy= screenY;
            if (toux > 0 || touy > 0 || toux < kWidth || touy < kHeight) {
                if (camera > 1){
                    const char *金人名称=(char*) [[NSString stringWithFormat:@"原点[%dm]",(int)camera-2] cStringUsingEncoding:NSUTF8StringEncoding];
                    DrawText(MsDrawList, 金人名称, 12, ImVec2(toux, touy), ImColor(原点颜色), true);
                    if (射线开关) {
                        MsDrawList->AddLine(ImVec2(自己X, 自己Y+10), ImVec2(toux,touy-5), ImColor(原点颜色));
                    }
                }
            }
        }
        
    }
}

-(void)主页菜单{
    if (ImGui::BeginTabItem("主页"))
    {
        ImGui::TextColored(ImColor(0,255,255),"遇境点击初始化等几秒,没效果再点或者重进");
        ImGui::Separator();
        if (ImGui::Button("遇境初始化")) {
            [self chushihua];
        }
                ImGui::Separator();
        
                ImGui::Checkbox("无限能量",&能量开关);
                ImGui::SameLine();
                ImGui::Checkbox("自然炸花",&自燃扎花开关);
                ImGui::SameLine();
                ImGui::Checkbox("吸火",&吸火开关);
                ImGui::Separator();
                ImGui::Checkbox("加速", &加速开关);
                ImGui::SameLine();
                ImGui::SliderFloat("速度", &speed_size, 1, 10);
                ImGui::Separator();
                ImGui::TextColored(ImColor(0,255,255),"HOOK功能");
                ImGui::Checkbox("登陆安卓",&登陆安卓);
                ImGui::Separator();
        
                ImGui::TextColored(ImColor(0,255,255),"本插件研究参考,禁止用于售卖等违法行为。");
                ImGui::TextColored(ImColor(0,255,255),"In 2024 By:Menu [ %.1fMs / %.1fFps ]", 1000 / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);
        ImGui::EndTabItem();//结束
    }
    if (ImGui::BeginTabItem("绘制"))
    {
        ImGui::TextColored(ImColor(0,255,255),"无处遁形!!!");
        ImGui::Separator();
        ImGui::Checkbox("绘制",&绘制开关);
        ImGui::SameLine();
        ImGui::Checkbox("射线",&射线开关);
        ImGui::SameLine();
        ImGui::Checkbox("金人",&金人绘制开关);
        ImGui::SameLine();
        ImGui::Checkbox("原点",&原点绘制开关);
        ImGui::EndTabItem();//结束
    }
}
-(void)绘制菜单{
    
}

-(void)chushihua{//这里其实可以换成指针写法,但是我懒的每次都去扫所以直接特征定位吧!
    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{//启动一个异步线程,在线程里面进行定位
        [self aaaa];
        [self bbbbb];
        [self ccccc];
        [self ffff];
        [self lzzzzz];
        [self zhhhhhh];
        [self ddddd];
    });
}

static long 矩阵地址;
-(void)aaaa{
    JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
    AddrRange range = (AddrRange){0x000000000,0x200000000};
    float search = 0.05;
    engine.JRScanMemory(range, &search, 4);
    float search1 = -1;
    engine.JRNearBySearch(0x20,&search1,4);
    engine.JRScanMemory(range, &search, 4);
    vector<void*>results = engine.getAllResults();
        for(int i = 0;i<results.size();i++){
            if (memoryTools.readFloat((long)results[i]-12) == -1 || memoryTools.readFloat((long)results[i]+4) == 0) {
                矩阵地址=(long)results[i]+8;
                NSLog(@"矩阵地址:%lu",矩阵地址);
                break;
            }
        };
}

//金人数量-3608等于吸金人1 如果吸金人地址等于1则未获取等于8则已获取 +152为坐标
static long 金人地址;
-(void)bbbbb{
    JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
    AddrRange range = (AddrRange){0x000000000,0x200000000};
    uint64_t search = 1480;
    engine.JRScanMemory(range, &search, 8);
    vector<void*>results = engine.getAllResults();
        for(int i = 0;i<results.size();i++){
            if (金人地址==0) {
                if (memoryTools.readInt((long)results[i]-16) == 4 && memoryTools.readInt((long)results[i]+224-4) == 1) {
                    金人地址=(long)results[i]+224-320;
                    NSLog(@"金人地址:%lu",金人地址);
                    break;
                }
            }else{
                break;
            }
        };
}


static long my坐标地址;
-(void)ccccc{
    JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
    AddrRange range = (AddrRange){0x000000000,0x200000000};
    int search = -1061397986;
    engine.JRScanMemory(range, &search, 4);
    vector<void*>results = engine.getAllResults();
    for(int i = 0;i<results.size();i++){
            NSString *str1 =[NSString stringWithFormat:@"%zx", (long)results[i]];
            if([str1 hasSuffix:@"374"] )
            {
                my坐标地址 = (long)results[i]-148;
                NSLog(@"坐标地址:%lu",my坐标地址);
                break;
            }
    }
}

static long 速度地址;
-(void)ddddd{
    JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
    AddrRange range = (AddrRange){0x000000000,0x200000000};
    int search = 1023969417;
    engine.JRScanMemory(range, &search, 4);
    vector<void*>results = engine.getAllResults();
    for(int i = 0;i<results.size();i++){
        if(memoryTools.readFloat((long)results[i]+24) == 1 && memoryTools.readFloat((long)results[i]+16) == 0)
        {
        速度地址 = (long)results[i]+24;
        NSLog(@"速度地址:%lu",速度地址);
        break;
        }
    }
}

static long 能量地址;
-(void)ffff{
    JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
    AddrRange range = (AddrRange){0x000000000,0x200000000};
    float search = 1.25;
    engine.JRScanMemory(range, &search, 4);
    vector<void*>results = engine.getAllResults();
    for(int i = 0;i<results.size();i++){
        if(memoryTools.readFloat((long)results[i]-16) == 1 && memoryTools.readFloat((long)results[i]+56) == 3 && memoryTools.readFloat((long)results[i]+72) == 1)
        {
        能量地址 = (long)results[i]-136;
        NSLog(@"能量地址:%lu",能量地址);
        break;
        }
    }
}


static long 自燃地址;
-(void)lzzzzz{
    JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
    AddrRange range = (AddrRange){0x000000000,0x200000000};
    uint64_t search = 4723375290045169668;
    engine.JRScanMemory(range, &search, 8);
    vector<void*>results = engine.getAllResults();
    for(int i = 0;i<results.size();i++){
        if(memoryTools.readFloat((long)results[i]+472) == 1)
        {
        自燃地址 = (long)results[i]+472;
        NSLog(@"自燃地址:%lu",自燃地址);
        break;
        }
    }
}

static long 炸花地址;
-(void)zhhhhhh{
    JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
    AddrRange range = (AddrRange){0x000000000,0x200000000};
    float search = 300;
    engine.JRScanMemory(range, &search, 4);
    int search1 = 3;
    engine.JRNearBySearch(0x10,&search1,4);
    float search2 = 1;
    engine.JRNearBySearch(0x10,&search2,4);
    engine.JRScanMemory(range, &search, 4);
    vector<void*>results = engine.getAllResults();
    for(int i = 0;i<results.size()-1;i++){
        if(memoryTools.readFloat((long)results[i]+8) == 1 && memoryTools.readInt((long)results[i]-4) == 3)
        {
        炸花地址 = (long)results[i]+8;
        NSLog(@"炸花地址:%lu",炸花地址);
        break;
        }
    }
}
bool 吸火判断 = false;
-(void)吸火{//这里emmm怎么说呢,不建议一直吸哦
    if (吸火判断==false) {
        吸火判断=true;
        dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(queue, ^{
            JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
            AddrRange range = (AddrRange){0x100000000,0x170000000};    // 搜索范围
            float search = 3.5;//搜索
            engine.JRScanMemory(range, &search, JR_Search_Type_UInt); // 搜索
            float search1 = -1;//联合f32  0.096
            engine.JRNearBySearch(0x1,&search1,JR_Search_Type_UInt); //
            float search2 = 3.5;// 搜索f32的3.5
            engine.JRScanMemory(range, &search2,JR_Search_Type_Float); //搜索
            vector<void*>results = engine.getAllResults(); //搜索到刚刚取消联合的
            float modify = 99999999; // 修改成
            for(int i = 0;i<results.size();i++){
                NSString *str1 =[NSString stringWithFormat:@"%zx", (long)results[i]];
                if([str1 hasSuffix:@"c"] )//判断地址16进制结尾是否是C结尾,如果是则进行下一步
                {
                    if(memoryTools.readFloat((long)results[i]+8) == -1)
                    {
                        engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);
                    }
                }
            }
            sleep(2);//延时2秒
            吸火判断=false;
        });
    }
}



@end



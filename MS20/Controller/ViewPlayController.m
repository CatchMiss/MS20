//
//  PlayView.m
//  TestDemo
//
//  Created by Multak on 2018/6/13.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import "ViewPlayController.h"
#import "UIView+Extension.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define USE_DEPTH_BUFFER 1
#define DEGREES_TO_RADIANS(__ANGLE) ((__ANGLE) / 180.0 * M_PI)



//顶点属性
const GLfloat Vertices2[] = {
    0.5, -0.5, 0.0f,    1.0f, 0.0f, 0.0f, //右下(x,y,z坐标 + rgb颜色)
    -0.5, 0.5, 0.0f,    0.0f, 1.0f, 0.0f, //左上
    -0.5, -0.5, 0.0f,   0.0f, 0.0f, 1.0f, //左下
};


@interface ViewPlayController ()

@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UIView *buttomBarView;
//@property (weak, nonatomic) IBOutlet GLKView *playForm;

@property (nonatomic, assign) CGRect parentViewRect;
@property (nonatomic, assign) PlayViewState state;

@property (nonatomic, strong) EAGLContext* mContext;//OpenGL 上下文
@property (nonatomic, strong) GLKBaseEffect* mEffect;//OpenGL 着色器
//@property (nonatomic, assign) int mCount;
//@property (nonatomic, assign) GLint backingWidth;
//@property (nonatomic, assign) GLint backingHeight;
//@property (nonatomic, assign) GLuint viewRenderbuffer, viewFramebuffer;
//@property (nonatomic, assign) GLuint depthRenderbuffer;
//@property (nonatomic, strong) NSTimer *animationTimer;
//@property (nonatomic, assign) NSTimeInterval animationInterval;

@end


@implementation ViewPlayController

+ (instancetype)playView
{
   return [[[NSBundle mainBundle] loadNibNamed:@"PlayView" owner:nil options:nil] lastObject];
}



- (void)showWithsuperRect:(CGRect)supViewRect
{
    self.parentViewRect = supViewRect;

    [self enterFullscreen];
    
    [self showStatusBar:YES];
}

- (IBAction)hide
{
    [self showStatusBar:NO];
    
    [self exitFullscreen];
}


//#pragma mark -- 全屏 animation 1
//- (void)enterFullscreen {
//
//    if (self.state != PlayViewStateSmall) {
//        return;
//    }
//
//    self.state = PlayViewStateAnimating;
//
//    /*
//     * 记录进入全屏前的parentView和frame
//     */
//    self.parentView = self.superview;
//    self.movieViewFrame = self.frame;
//
//    /*
//     * movieView移到window上
//     */
//    CGRect rectInWindow = [self convertRect:self.bounds toView:[UIApplication sharedApplication].keyWindow];
//    [self removeFromSuperview];
//    self.frame = rectInWindow;
//    [[UIApplication sharedApplication].keyWindow addSubview:self];
//
//    /*
//     * 执行动画
//     */
//    [UIView animateWithDuration:0.5 animations:^{
//        self.transform = CGAffineTransformMakeRotation(M_PI_2);
//        self.bounds = CGRectMake(0, 0, CGRectGetHeight(self.superview.bounds), CGRectGetWidth(self.superview.bounds));
//        self.center = CGPointMake(CGRectGetMidX(self.superview.bounds), CGRectGetMidY(self.superview.bounds));
//    } completion:^(BOOL finished) {
//        self.state = PlayViewStateFullscreen;
//    }];
//
//    [self refreshStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
//}
//
//#pragma mark -- 退出全屏 animation
//
//- (void)exitFullscreen
//{
//    if (self.state != PlayViewStateFullscreen) {
//        return;
//    }
//
//    self.state = PlayViewStateAnimating;
//
//    CGRect frame = [self.parentView convertRect:self.movieViewFrame toView:[UIApplication sharedApplication].keyWindow];
//
//    [UIView animateWithDuration:0.5 animations:^{
//        self.transform = CGAffineTransformIdentity;
//        self.frame = frame;
//    } completion:^(BOOL finished) {
//        /*
//         * movieView回到小屏位置
//         */
//        [self removeFromSuperview];
//        self.frame = self.movieViewFrame;
//        [self.parentView addSubview:self];
//        self.state = PlayViewStateSmall;
//    }];
//
//    [self refreshStatusBarOrientation:UIInterfaceOrientationPortrait];
//}
//


#pragma mark -- 全屏 animation
- (void)enterFullscreen
{
    
    if (self.state != PlayViewStateSmall) {
        return;
    }
    
    self.state = PlayViewStateAnimating;
    self.view.hidden = NO;
    
    /*
     * 移到window上
     */
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.view.frame = self.parentViewRect;
    [window addSubview:self.view];
    
    /*
     * 执行动画
     */
    [UIView animateWithDuration:0.5 animations:^{
        self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.view.frame = window.bounds;
    } completion:^(BOOL finished) {
        self.state = PlayViewStateFullscreen;
    }];
    
    //[self refreshStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
}

- (void)normalPush
{
    // 1. 拿到Window
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    // 2. 设置当前控制器的frame
    self.view.frame = window.bounds;

    // 3. 将当前控制器的view添加到Window上
    [window addSubview:self.view];
    self.view.hidden = NO;
    
    // 禁用交互功能
    window.userInteractionEnabled = NO;
    
    // 4.执行动画, 让控制器的view从下面转出来
    self.view.x = window.bounds.size.width;
    [UIView animateWithDuration:1 animations:^{
        // 执行动画
        self.view.x = 0;
    } completion:^(BOOL finished) {
        // 开启交互
        window.userInteractionEnabled = YES;
    
    }];
}

#pragma mark -- 退出全屏 animation
- (void)exitFullscreen
{
    if (self.state != PlayViewStateFullscreen) {
        return;
    }
    
    self.state = PlayViewStateAnimating;
    
    /*
        [view1 convertRect:view2.fream toView:view3];
        转换坐标系
        view1 是 view2 父视图
        view3 是 view1 父视图
    */
    //UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //CGRect frame = [self.parentView convertRect:self.parentViewRect toView:window];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.view.transform = CGAffineTransformIdentity;
        self.view.frame = self.parentViewRect;
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
        self.state = PlayViewStateSmall;
    }];
    
    //[self refreshStatusBarOrientation:UIInterfaceOrientationPortrait];
}

- (void)normalHide
{
    // 1. 拿到Window
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    // 禁用交互功能
    window.userInteractionEnabled = NO;
    
    // 2.执行退出动画
    [UIView animateWithDuration:1 animations:^{
        self.view.x = window.bounds.size.width;
    
    } completion:^(BOOL finished) {
    
        // 隐藏控制器的view
        self.view.hidden = YES;
    
        // 开启交互
        window.userInteractionEnabled = YES;
    }];
}


#pragma mark -- 控制栏
- (void)showStatusBar:(BOOL)show
{
    if(show)
    {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        window.userInteractionEnabled = NO;

        self.topBarView.y = -96;
        self.buttomBarView.y = 375;
        
        self.topBarView.hidden = NO;
        self.buttomBarView.hidden = NO;
        
        [UIView animateWithDuration:1 animations:^{
            self.topBarView.y = 0;
            self.buttomBarView.y = 261;
        } completion:^(BOOL finished) {
            window.userInteractionEnabled = YES;
        }];
    }
    else
    {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        window.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:0.1 animations:^{
            self.topBarView.y = -96;
            self.buttomBarView.y = 375;
            
        } completion:^(BOOL finished) {
            self.topBarView.hidden = YES;
            self.buttomBarView.hidden = YES;
            
            window.userInteractionEnabled = YES;
        }];
    }
}


#pragma mark -- 更新状态栏方向
//- (void)refreshStatusBarOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    [[UIApplication sharedApplication] setStatusBarOrientation:interfaceOrientation animated:YES];
//}

//- (BOOL)shouldAutorotate
//{
//    return NO;
//}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupContext];
    
    [self setupVBOs];
    [self setupBaseEffect];
    
    //[self test];
    //[self setupView];
    //[self drawView];
}

- (void)setupContext
{
    self.mContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.mContext) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.mContext;
    //颜色缓冲区格式
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    //self.context为OpenGL的"当前激活的Context"。之后所有"GL"指令均作用在这个Context上。
    if (![EAGLContext setCurrentContext:self.mContext]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

/**
 创建Vertex Buffer 对象
 */
- (void)setupVBOs
{
    GLuint verticesBuffer;
    glGenBuffers(1, &verticesBuffer);//申请缓存
    glBindBuffer(GL_ARRAY_BUFFER, verticesBuffer);//绑定缓存:缓存类型,:缓存数据
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices2), Vertices2, GL_STATIC_DRAW);//绑定的buffer初始化数据
    
    //开启对应的顶点属性
    glEnableVertexAttribArray(GLKVertexAttribPosition); //顶点数组缓存
    glEnableVertexAttribArray(GLKVertexAttribColor); //颜色
    
    //为vertex shader的Position和GLKVertexAttribColor配置合适的值
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (GLfloat *)NULL + 0);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (GLfloat *)NULL + 3);
}

//创建着色器效果
- (void)setupBaseEffect
{
    self.mEffect = [[GLKBaseEffect alloc] init];
}

#pragma mark - GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //启动着色器
    [self.mEffect prepareToDraw];
    
    glClearColor(0.3f, 0.6f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //绘制
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}









//- (void)test
//{
//    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
//    if(!self.mContext){
//        NSLog(@"failed to create ES context");
//    }
//
//    GLKView *view = (GLKView*)self.playForm;//stroyboard中要添加
//    view.context = self.mContext;
//    view.drawableDepthFormat = GLKViewDrawableColorFormatRGBA8888;
//    [EAGLContext setCurrentContext:self.mContext];
//    //glEnable(GL_DEPTH_TEST);
//
//    //顶点数据,三个顶点坐标,两个纹理坐标
//    GLfloat squareVertexData[] = {
//        0.5, -0.5, 0.0f, 1.0f, 0.0f,    //右下
//        -0.5, 0.5, 0.0f, 0.0f, 1.0f,    //左上
//        -0.5, -0.5, 0.0f, 0.0f, 0.0f,   //左下
//        //0.5, 0.5, -0.0f, 1.0f, 1.0f,    //右上
//    };
//
//    //顶点索引
//    GLuint indices[] = {
//        0, 1, 2,
//    };
//
//    self.mCount = sizeof(indices) / sizeof(GLuint);
//
//    //顶点索引
//    GLuint buffer;
//    glGenBuffers(1, &buffer);
//    glBindBuffer(GL_ARRAY_BUFFER, buffer);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
//
//    GLuint index;
//    glGenBuffers(1, &index);
//    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
//
//    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL+0);
//
//    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"dzq" ofType:@"jpg"];
//    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];
//
//    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
//
//    self.mEffect = [[GLKBaseEffect alloc] init];
//    self.mEffect.texture2d0.enabled = GL_TRUE;
//    self.mEffect.texture2d0.name = textureInfo.name;
//
//}


//- (void)setupView {
//
//    const GLfloat zNear = 0.1, zFar = 1000.0, fieldOfView = 60.0;
//    GLfloat size;
//
//    glEnable(GL_DEPTH_TEST);
//    glMatrixMode(GL_PROJECTION);
//    size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
//
//    // This give us the size of the iPhone display
//    CGRect rect = self.playForm.bounds;
//    glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), zNear, zFar);
//    glViewport(0, 0, rect.size.width, rect.size.height);
//
//    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
//}

//- (void)drawView
//{
//    const GLfloat triangleVertices[] = {
//        0.0, 1.0, -6.0,
//        -1.0, -1.0, -6.0,
//        1.0, -1.0, -6.0,
//    };
//
//    glViewport(0, 0, self.backingWidth, self.backingHeight);
//
//    //Begin new code
//    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//    glVertexPointer(3, GL_FLOAT, 0, triangleVertices);
//    glEnableClientState(GL_VERTEX_ARRAY);
//    glDrawArrays(GL_TRIANGLES, 0, 3);
//    //End new code
//
//    glBindRenderbufferOES(GL_RENDERBUFFER_OES, self.viewRenderbuffer);
//    [self.mContext presentRenderbuffer:GL_RENDERBUFFER_OES];
//    [self checkGLError:NO];
//}

//- (void)checkGLError:(BOOL)visibleCheck {
//    GLenum error = glGetError();
//
//    switch (error) {
//        case GL_INVALID_ENUM:
//            NSLog(@"GL Error: Enum argument is out of range");
//            break;
//        case GL_INVALID_VALUE:
//            NSLog(@"GL Error: Numeric value is out of range");
//            break;
//        case GL_INVALID_OPERATION:
//            NSLog(@"GL Error: Operation illegal in current state");
//            break;
//        case GL_STACK_OVERFLOW:
//            NSLog(@"GL Error: Command would cause a stack overflow");
//            break;
//        case GL_STACK_UNDERFLOW:
//            NSLog(@"GL Error: Command would cause a stack underflow");
//            break;
//        case GL_OUT_OF_MEMORY:
//            NSLog(@"GL Error: Not enough memory to execute command");
//            break;
//        case GL_NO_ERROR:
//            if (visibleCheck) {
//                NSLog(@"No GL Error");
//            }
//            break;
//        default:
//            NSLog(@"Unknown GL Error");
//            break;
//    }
//}



@end

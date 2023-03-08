//
//  SHGLView.m
//  OpenGLDemo
//
//  Created by Ray on 2023/3/8.
//

#import "SHGLTool.h"
#import <OpenGLES/ES3/gl.h>
#import "SHGLView.h"

@interface SHGLView ()
{
    EAGLContext* myContext;
    GLuint myColorFrameBuffer;
    GLuint myColorRenderBuffer;
    GLuint myProgram;
    GLuint positionSlot;
    GLuint colorSlot;
}
@end


@implementation SHGLView

+ (Class)layerClass
{
    return  [CAEAGLLayer classForCoder];
}


- (void)setUpLayer{
    //    self.backgroundColor = [UIColor clearColor];
        CAEAGLLayer *myLayer = (CAEAGLLayer *)self.layer;
    
        /// 默认是透明的，设置为不透明
    
        myLayer.opaque=YES;
    
        // 设置draw属性
    
        myLayer.drawableProperties = @{
        
                                           kEAGLDrawablePropertyRetainedBacking:@NO,
        
                                           kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
        
                                           };
    
}

-(void)destoryRenderAndFrameBuffer {
    //        当 UIView 在进行布局变化之后，由于 layer 的宽高变化，导致原来创建的 renderbuffer不再相符，我们需要销毁既有 renderbuffer 和 framebuffer。下面，我们依然创建私有方法 destoryRenderAndFrameBuffer 来销毁生成的 buffer
    glDeleteFramebuffers(1, &myColorFrameBuffer);
    myColorFrameBuffer = 0;
    glDeleteRenderbuffers(1, &myColorRenderBuffer);
    myColorRenderBuffer = 0;
}

/// 设置上下文
-(void)setUpContext {
    myContext = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES3];
    // 绑定上下文
    //    [EAGLContext setCurrentContext:_context];
    /// 设置成当前的上下文
    
        if (![EAGLContext setCurrentContext:myContext]) {
        
                NSLog(@"context设置失败");
        
                return;
        
            }
}

-(void)setUpBuffer {
    //    创建绘制缓冲区
    GLuint buffer = 0;
    glGenRenderbuffers(1, &buffer);
    myColorRenderBuffer = buffer;
    //    绑定绘制缓存区到渲染管线
    glBindRenderbuffer(GL_RENDERBUFFER, myColorRenderBuffer);
    //    glBindBuffer(GL_RENDERBUFFER, myColorRenderBuffer);
    //    为绘制缓冲区分配存储区，此处将CAEAGLLayer的绘制存储区作 为绘制缓冲区的存储区：
    [myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    
    
    
    
    //    创建帧缓冲区：
    
    glGenFramebuffers(1, &myColorFrameBuffer);
    //    绑定帧缓冲区到渲染管线
    glBindFramebuffer(GL_FRAMEBUFFER, myColorFrameBuffer);
    
    //    将绘制缓冲区绑定到帧缓冲区：
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, myColorRenderBuffer);
}
//
- (void)setupProgram {
    NSString * vertext = [[NSBundle mainBundle] pathForResource:@"shaderv.glsl" ofType:@""];
    NSString * frgment = [[NSBundle mainBundle] pathForResource:@"shaderf.glsl" ofType:@""];
    myProgram =  [SHGLTool loadShaders:vertext frag:frgment];
    //    myProgram = [GLESUtils loadProgram:@"shaderv.glsl" fragShader:@"shaderf.glsl"];
    
        if(myProgram==0) {
        
                return;
        
            }
    
        glUseProgram(myProgram);
    
        positionSlot = glGetAttribLocation(myProgram, "vPosition");
    
        colorSlot = glGetAttribLocation(myProgram, "a_Color");
    
}

- (void)render

{
    
        glClearColor(0,1.0,0,1.0);
    
        glClear(GL_COLOR_BUFFER_BIT);
    
        glViewport(0, 0, (GLsizei)self.frame.size.width, (GLsizei)self.frame.size.height);
    
        /// 顶点的坐标系统是在正中心
    
        GLfloat vertices[] = {
        
              0.0f, 0.5f, 0.0f, 1,
        
              -0.5f, -0.5f,0.0f,1,
        
              0.5f, -0.5f, 0.0f,1
        
            };
    
        GLfloat colors[] = {
        
                1.0f, 0.0f, 0.0f, 1.0f,
        
                0.0f, 1.0f, 0.0f, 1.0f,
        
                0.0f, 0.0f, 1.0f, 1.0f,
        
            };
    
        /// 加载顶点数据
    
        glVertexAttribPointer(positionSlot,4,GL_FLOAT,GL_FALSE,0, vertices);
    
        glEnableVertexAttribArray(positionSlot);
        /// 加载颜色数据
        glVertexAttribPointer(colorSlot,4,GL_FLOAT,GL_FALSE,0, colors);
    
        glEnableVertexAttribArray(colorSlot);
        /// 绘制
        glDrawArrays(GL_TRIANGLES, 0, 3);
    
        [myContext presentRenderbuffer:GL_RENDERBUFFER];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setUpLayer];
    [self setUpContext];
    [self destoryRenderAndFrameBuffer];
    [self setUpBuffer];
    [self setupProgram];
    [self render];
}






@end

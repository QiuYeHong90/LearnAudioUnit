//
//  SHGLView.m
//  OpenGLTextures
//
//  Created by Ray on 2023/3/9.
//
#import <OpenGLES/ES3/gl.h>
#import "SHGLTool.h"
#import "SHGLView.h"

@interface SHGLView ()
{
    /// 上下文
    EAGLContext* myContext;
    /// 定点缓存数据
    GLuint myColorFrameBuffer;
    /// 片原数据
    GLuint myColorRenderBuffer;
    /// 当前程序
    GLuint myProgram;
    /// 属性vPosition的位置
    GLuint positionSlot;
    /// 属性a_Color 的位置
    GLuint colorSlot;
}
@end

@implementation SHGLView

+ (Class)layerClass {
    return  [CAEAGLLayer class];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setConfig];
    [self setupBuffer];
    [self loadShader];
    [self render];
    
}

-(void)setConfig {
    CAEAGLLayer * eagLayer = (CAEAGLLayer *)self.layer;
    eagLayer.drawableProperties = @{
        kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8,
        kEAGLDrawablePropertyRetainedBacking: @NO,
    };
    eagLayer.opaque = YES;
    if (myContext = nil) {
        myContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        [EAGLContext setCurrentContext: myContext];
    }
    
    
}

-(void)setupBuffer {
    GLuint buffer = 0;
    // 创建渲染缓冲区
    glGenRenderbuffers(1, &buffer);
    myColorRenderBuffer = buffer;
//    绑定冲区到渲染管线：
    glBindRenderbuffer(GL_RENDERBUFFER, buffer);
    
    [myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    glGenFramebuffers(1, &buffer);
//    绑定帧缓冲区到渲染管线：
    glBindFramebuffer(GL_FRAMEBUFFER, buffer);
    myColorFrameBuffer = buffer;
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, myColorRenderBuffer);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER); if(status != GL_FRAMEBUFFER_COMPLETE){
        // failed to make complete frame buffer object
        NSLog(@"有问题");
    }
}

-(void)loadShader {
    NSString * vertexFile = [[NSBundle mainBundle] pathForResource:@"shaderv.glsl" ofType:@""];
    NSString * fragmentFile = [[NSBundle mainBundle] pathForResource:@"shaderf.glsl" ofType:@""];
    self->myProgram = [SHGLTool loadShaders:vertexFile frag:fragmentFile];
    
    glUseProgram(myProgram);
    
    
}

-(void)render{
    
}

@end

//
//  SHGLTool.m
//  OpenGLDemo
//
//  Created by Ray on 2023/3/8.
//


#import "SHGLTool.h"

@implementation SHGLTool

/**
 *  c语言编译流程：预编译、编译、汇编、链接
 *  glsl的编译过程主要有glCompileShader、glAttachShader、glLinkProgram三步；
 *  @param vert 顶点着色器
 *  @param frag 片元着色器
 *
 *  @return 编译成功的shaders
 */
+ (GLuint)loadShaders:(NSString *)vertFilePath frag:(NSString *)fragFilePath {
    NSString* vertContent = [NSString stringWithContentsOfFile:vertFilePath encoding:NSUTF8StringEncoding error:nil];
    NSString* fragContent = [NSString stringWithContentsOfFile:fragFilePath encoding:NSUTF8StringEncoding error:nil];
    return [self loadShaders:vertContent fragContent:fragContent];
}
/**
 *  c语言编译流程：预编译、编译、汇编、链接
 *  glsl的编译过程主要有glCompileShader、glAttachShader、glLinkProgram三步；
 *  @param vert 顶点着色器
 *  @param frag 片元着色器
 *
 *  @return 编译成功的shaders
 */
+ (GLuint)loadShaders:(NSString *)vertContent fragContent:(NSString *)fragContent {
    GLuint verShader, fragShader;
    GLint program = glCreateProgram();
    //编译
    [self compileShader:&verShader type:GL_VERTEX_SHADER content:vertContent];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER content:fragContent];
    
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    glLinkProgram(program);
    
    //释放不需要的shader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
}
+ (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    //读取字符串
    NSString* content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    
    [self compileShader:shader type:type content:content];

}

+ (void)compileShader:(GLuint *)shader type:(GLenum)type content:(NSString *)content {
    const GLchar* source = (GLchar *)[content UTF8String];
    *shader = glCreateShader(type);
    if (*shader == 0) {
        NSLog(@"Error: failed to create shader.");
    }
    // Load the shader source
    glShaderSource(*shader, 1, &source, NULL);
    // Compile the shader
    glCompileShader(*shader);
    // Check the compile status
    GLint compiled = 0;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &compiled);
    if (!compiled) {
//        编译没通过
        GLint infoLen = 0;
        glGetShaderiv (*shader, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 1) {
            char * infoLog = malloc(sizeof(char) * infoLen);
            glGetShaderInfoLog (shader, infoLen, NULL, infoLog);
            NSLog(@"Error compiling shader:\n%s\n", infoLog );
            free(infoLog);
        }
        glDeleteShader(*shader);
        *shader = 0;
    }

}


@end

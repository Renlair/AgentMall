package com.example.campus.common;

/** 可向用户直接展示的业务错误，控制台捕获后继续接收指令。 */
public final class BusinessException extends RuntimeException {
    public BusinessException(String message) { super(message); }
}

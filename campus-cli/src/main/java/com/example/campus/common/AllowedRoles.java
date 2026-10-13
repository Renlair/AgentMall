package com.example.campus.common;

import com.example.campus.entity.User.Role;
import java.lang.annotation.*;

/** 命令元数据用于动态菜单和命令入口鉴权；服务仍独立检查权限。 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface AllowedRoles { Role[] value(); }

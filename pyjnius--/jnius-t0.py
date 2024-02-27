#!/usr/bin/env python3
# coding=utf-8
# date 2024-02-27 18:38:48
# author calllivecn <c-all@qq.com>

# 测试ok

from jnius import autoclass
# 使用 autoclass 函数获取 java.lang.System 类
System = autoclass('java.lang.System')
# 调用 System 类的 out.println 方法打印 'Hello world'
System.out.println('Hello world')

# 获取 java.util.Stack 类
Stack = autoclass('java.util.Stack')
# 创建 Stack 类的实例
stack = Stack()
# 调用 push 方法添加元素
stack.push('hello')
stack.push('world')
# 调用 pop 方法移除并返回栈顶元素
print(stack.pop())  # 输出: world
print(stack.pop())  # 输出: hello


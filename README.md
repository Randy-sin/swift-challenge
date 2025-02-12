# Oceanus - 情绪潮汐调节站 🌊

## 项目概述
Oceanus（海王星主题）是一个专注于情绪调节和冥想的互动体验项目。用户通过呼吸练习来调节虚拟海洋的潮汐，在平静的深海环境中获得心灵的宁静。

## 核心功能
- 动态海洋环境
- 呼吸引导系统
- 交互式海洋生物
- 情绪反馈机制

## 场景设计

### 视觉环境
- 深邃的海洋渐变背景
- 动态水面效果和光影折射
- 荧光海洋生物（水母、鲸鱼等）
- 呼吸相关的气泡效果

### 声音设计
- 动态海浪白噪音
- 深海生物声效
- 432Hz冥想背景音乐
- 呼吸引导音效

## 技术实现

### 1. 水面效果实现
#### 主要技术：SceneKit + Shader
```swift
// 基础实现思路
- SCNGeometry 创建水面网格
- Metal Shader 实现水波动画
- Perlin Noise 生成自然波浪
- CubeMap 环境反射
- Fresnel 效果处理透明度
- Normal Map 实现水波纹理
```

### 2. 海洋生物系统
#### 主要技术：SceneKit + 骨骼动画
```swift
// 核心组件
- SCNNode 基础结构
- 骨骼动画系统
- 粒子系统（荧光效果）
- Boids 算法（群体行为）
- 实例化渲染优化
```

### 3. 呼吸引导系统
#### 主要技术：Core Animation + SpriteKit
```swift
// 实现方案
- CAShapeLayer 呼吸环
- CABasicAnimation 动画过渡
- CADisplayLink 帧率同步
- Timer 精确控制呼吸周期
```

## 项目结构
```
OceanusScene/
├── Core/
│   ├── SceneController
│   ├── AnimationSystem
│   └── ResourceManager
├── Water/
│   ├── WaterSurface
│   ├── WaveGenerator
│   └── ReflectionSystem
├── Creatures/
│   ├── CreatureController
│   ├── JellyfishSystem
│   └── FishSchoolSystem
└── Breathing/
    ├── BreathingGuide
    ├── VisualizationSystem
    └── FeedbackController
```

## 性能优化
1. **渲染优化**
   - LOD系统
   - 视锥体剔除
   - Shader优化
   - 纹理图集

2. **内存管理**
   - 资源池
   - 动态加载/卸载
   - AutoreleasePool

## 交互流程
1. 用户进入深海场景
2. 跟随呼吸引导进行冥想
3. 通过呼吸节奏影响海洋环境
4. 达到平静状态触发特殊效果
5. 完成冥想获得反馈报告

## 教育价值
- 呼吸科学知识
- 情绪管理技巧
- 正念冥想方法
- 海洋生物知识

## 后续开发计划
1. 实现基础水面效果
2. 添加海洋生物动画
3. 完善呼吸引导系统
4. 优化视觉效果
5. 添加教育内容

## 技术要求
- iOS 15.0+
- Swift 5.0+
- Metal/SceneKit
- Core Animation
- SpriteKit 
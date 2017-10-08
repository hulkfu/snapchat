# Snapchat

 一个模仿 Snapchat 的随机聊天软件。

 演示地址在：http://qrdiy.com:4000

 可以用多个浏览器进行配对测试。

# module

- matcher 配对服务进程。
- user 每个在线的用户对应一个 user 进程。
- websocket_handle 使用 cowboy 处理 websocket。

# 运行

```bash
mix deps.get
iex -S mix
```

# TODO
- Production 的自动部署
- 进程的监控
- user 的详细信息
  - name
  - avatar
- 消息的多样化
  - 图片
  - 流媒体

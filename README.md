# Snapchat

 一个模仿 Snapchat 的随机聊天软件。

# module

- matcher 配对服务进程。
- user 每个在线的用户对应一个 user 进程。
- websocket_handle 使用 cowboy 处理 websocket。

# 运行

```bash
mix deps.get
iex -S mix
```

# xray新协议gRPC使用体验，性能优异，未来或可全面替代ws

最近xray又更新了，未来还会有更多惊喜哦，相比v2ray近期比较稳定，适合不爱折腾的小伙伴。

xray本次更新带来了 WebSocket 0-RTT 还有 gRPC Transport，详细的内容还是看官方的 [release note](https://github.com/XTLS/Xray-core/releases/tag/v1.4.0) 吧。个人才疏学浅，仅使用体验而已。

## WebSocket 0-RTT

对于 WebSocket 0-RTT，就是在原有 ws（websocket）协议上更进一步的优化提升，服务端配置不变，客户端仅做小小修改即可体验新特性带来的速度提升。

比如 path 原来是 /test 现在添加个参数变成 /test?ed=2048

```json
{
  "log": {"loglevel": "none"},
  "inbounds": [{
    "port": 1080,
    "protocol": "socks",
    "settings": {
      "ip": "127.0.0.1",
      "udp": true
    }
  }],
  "outbounds": [{
    "protocol": "vless",
    "settings": {
      "vnext": [{
        "address": "==YOUR DOMAIN==",
        "port": 443,
        "users": [{
          "id": "==YOUR USER ID==",
          "encryption": "none"
        }]
      }]
    },
    "streamSettings": {
      "network": "ws",
      "security": "tls",
      "wsSettings": {"path": "/test?ed=2048"}
    }
  }]
}
```

## gRPC Transport

体验完 WebSocket 0-RTT 后，自然不能放过更具未来的 gRPC 协议，因为是新加入的协议，没有什么可以参考，就参照着官方简明扼要的文档自己摸索，调试一番之后，成功起飞。

服务器上是 nginx 前置，针对不同的应用进行分发。对于 gPRC 通过 grpc_pass 明文传递给 xray 进行处理。之前 v2ray 可以支持 h2c 来的流量，但是 nginx 不支持 h2c，配置 caddy 可以使用 h2c 正常工作，但是使用一段时间后发现有时会出现网络不通，重启服务后又正常，看上去不太稳定，只能换回 nginx + ws 的方式。对于官方大力推荐的回落模式，个人一直有点不大感冒，还是比较偏爱 nginx 分流这种。此次 xray 更新带来了 gRPC 协议，刚好弥补此处的空缺，实测下来相比于之前的 ws 方式，gRPC 在速度上优势还是很明显的，毕竟可以享受到 http/2 的很多好处。虽然 gRPC 协议刚刚加入，但是后生可畏，个人觉得未来大有可期，全面取代霸屏已久的 ws 不是没有可能，静观其变。

服务端配置

```json
{
  "log": {"loglevel": "none"},
  "inbounds": [{
    "port": 12345,
    "protocol": "vless",
    "settings": {
      "decryption": "none",
      "clients": [{"id": "==YOUR USER ID=="}]
    },
    "streamSettings": {
      "network": "grpc",
      "security": "none",
      "grpcSettings": {"serviceName": "/test"}
    }
  }],
  "outbounds": [{"protocol": "freedom", "settings": {}}]
}
```

服务端 nginx 部分配置

```bash
server {
  listen 443 ssl http2;
  server_name ==YOUR DOMAIN==;
  ssl_certificate /path/to/tls.pem;
  ssl_certificate_key /path/to/tls.key;

  location /test {
    grpc_pass grpc://localhost:12345;
  }
}
```

客户端配置

```json
{
  "log": {"loglevel": "none"},
  "inbounds": [{
    "port": 1080,
    "protocol": "socks",
    "settings": {
      "ip": "127.0.0.1",
      "udp": true
    }
  }],
  "outbounds": [{
    "protocol": "vless",
    "settings": {
      "vnext": [{
        "address": "==YOUR DOMAIN==",
        "port": 443,
        "users": [{
          "id": "==YOUR USER ID==",
          "encryption": "none"
        }]
      }]
    },
    "streamSettings": {
      "network": "grpc",
      "security": "tls",
      "grpcSettings": {"serviceName": "/test"}
    }
  }]
}
```

# xray-openwrt

v2ray 官方移除了 xtls，[xray](https://github.com/XTLS/Xray-core) 独立发布，重点关注性能提升，需要的走起~~~

* [release下获取xray文件](https://github.com/felix-fly/xray-openwrt/releases)

用法不再赘述，详细可参考之前的 **[openwrt中使用v2ray的简单流程](https://github.com/felix-fly/v2ray-openwrt)**

xray 更新加入了 gRPC 协议，点击下面了解一下？

[**xray 新协议 gRPC 使用体验，性能优异，未来或可全面替代 ws**](./grpc.md)

## 自行构建ipk安装包

看到小伙伴有这个想法，花了点时间，弄了个脚本，可以自行构建 ipk 包，方便到 openwrt 中安装

先克隆项目到某个 linux 环境下，windows 的 wsl 未做测试，理论上应该也可以

```bash
git clone https://github.com/felix-fly/xray-openwrt.git
```

进入项目目录，运行脚本，参数为 CPU 平台，版本不指定默认为最新版

```bash
./package.sh amd64
```

生成的 ipk 包在当前路径下，形如 **xray-xxx.ipk** 

路由安装后需要自行修改配置文件

```bash
/etc/xray/config.json
```

对路由操作不熟悉的可以在打包前先修改

> ./package/data/etc/xray/config.json

需要使用 xray 路由策略也可以自行在此路径下加入 site.dat 等文件

可选的平台参数：

* 386
* amd64
* armv5
* armv6
* armv7
* arm64
* mips
* mipsle
* mips64
* mips64le
* ppc64
* ppc64le

参考配置文件：

* [客户端配置](./client.json) 
* [服务端配置](./server.json)

## 更新记录
2021-03-18
* 增加 gRPC 协议

2020-12-22
* 增加 ipk 打包脚本

2020-12-08
* 初版
